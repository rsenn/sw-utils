//
//  pkgtools
// 
//  Copyright (c) 2000-2005 Per Liden
// 
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, 
//  USA.
//

#include <string>
#include <unistd.h>
#include <fcntl.h>
#include <iostream>
#include <sstream>
#include <iterator>
#include <algorithm>
#include <cstdio>
#include <cstring>
#include <cerrno>
#include <csignal>
//#include <ext/stdio_filebuf.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/file.h>
#include <sys/param.h>
#include <unistd.h>
#include <fcntl.h>
#include <libgen.h>

#include "pkgdb_text.hpp"
#include "pkgtool.hpp"
#include "config.h"

using namespace std;

//using __gnu_cxx::stdio_filebuf;

pkgdb_text::pkgdb_text() {}
pkgdb_text::~pkgdb_text() {}
  
void pkgdb_text::open(const string& path, bool exclusive)
{
  pkgdb::lock(new pkgdb_text_lock(path, exclusive));
  
	// Read database
	m_root = trim_filename(path + "/");
	const string filename = m_root + PKG_DB_TEXT;

	int fd = ::open(filename.c_str(), O_RDONLY|O_CREAT, 0644);
	if (fd == -1)
		throw runtime_error_with_errno("could not open " + filename);

	stdio_filebuf<char> filebuf(fd, ios::in, getpagesize());
	istream in(&filebuf);
	if (!in)
		throw runtime_error_with_errno("could not read " + filename);

	while (!in.eof()) {
		// Read record
		string name;
		pkginfo_t info;
		getline(in, name);
		getline(in, info.version);
		for (;;) {
			string file;
			getline(in, file);
         
			if (file.empty())
				break; // End of record
         
			info.files.insert(info.files.end(), file);
		}
		if (!info.files.empty())
			m_packages[name] = info;
	}

#ifdef DEBUG
	cerr << m_packages.size() << " packages found in database" << endl;
#endif
}

void pkgdb_text::commit()
{
	const string dbfilename = m_root + PKG_DB;
	const string dbfilename_new = dbfilename + ".incomplete_transaction";
	const string dbfilename_bak = dbfilename + ".backup";

	// Remove failed transaction (if it exists)
	if (unlink(dbfilename_new.c_str()) == -1 && errno != ENOENT)
		throw runtime_error_with_errno("could not remove " + dbfilename_new);

	// Write new database
	int fd_new = creat(dbfilename_new.c_str(), 0444);
	if (fd_new == -1)
		throw runtime_error_with_errno("could not create " + dbfilename_new);

	stdio_filebuf<char> filebuf_new(fd_new, ios::out, getpagesize());
	ostream db_new(&filebuf_new);
	for (packages_t::const_iterator i = m_packages.begin(); i != m_packages.end(); ++i) {
		if (!i->second.files.empty()) {
			db_new << i->first << "\n";
			db_new << i->second.version << "\n";
			copy(i->second.files.begin(), i->second.files.end(), ostream_iterator<string>(db_new, "\n"));
			db_new << "\n";
		}
	}

	db_new.flush();

	// Make sure the new database was successfully written
	if (!db_new)
		throw runtime_error("could not write " + dbfilename_new);

	// Synchronize file to disk
	if (fsync(fd_new) == -1)
		throw runtime_error_with_errno("could not synchronize " + dbfilename_new);

	// Relink database backup
	if (unlink(dbfilename_bak.c_str()) == -1 && errno != ENOENT)
		throw runtime_error_with_errno("could not remove " + dbfilename_bak);	
	if (link(dbfilename.c_str(), dbfilename_bak.c_str()) == -1)
		throw runtime_error_with_errno("could not create " + dbfilename_bak);

	// Move new database into place
	if (rename(dbfilename_new.c_str(), dbfilename.c_str()) == -1)
		throw runtime_error_with_errno("could not rename " + dbfilename_new + " to " + dbfilename);

#ifdef DEBUG
	cerr << m_packages.size() << " packages written to database" << endl;
#endif
}

void pkgdb_text::add_pkg(const string& name, const pkginfo_t& info)
{
	m_packages[name] = info;
}

bool pkgdb_text::find_pkg(const string& name)
{
	return (m_packages.find(name) != m_packages.end());
}

void pkgdb_text::rm_pkg(const string& name)
{
	set<string> files = m_packages[name].files;
	m_packages.erase(name);

#ifdef DEBUG
	cerr << "Removing package phase 1 (all files in package):" << endl;
	copy(files.begin(), files.end(), ostream_iterator<string>(cerr, "\n"));
	cerr << endl;
#endif

	// Don't delete files that still have references
	for (packages_t::const_iterator i = m_packages.begin(); i != m_packages.end(); ++i)
		for (set<string>::const_iterator j = i->second.files.begin(); j != i->second.files.end(); ++j)
			files.erase(*j);

#ifdef DEBUG
	cerr << "Removing package phase 2 (files that still have references excluded):" << endl;
	copy(files.begin(), files.end(), ostream_iterator<string>(cerr, "\n"));
	cerr << endl;
#endif

	// Delete the files
	for (set<string>::const_reverse_iterator i = files.rbegin(); i != files.rend(); ++i) {
		const string filename = m_root + *i;
		if (file_exists(filename) && remove(filename.c_str()) == -1) {
			const char* msg = strerror(errno);
			cerr << /*utilname << FIXME */": could not remove " << filename << ": " << msg << endl;
		}
	}
}

void pkgdb_text::rm_pkg(const string& name, const set<string>& keep_list)
{
	set<string> files = m_packages[name].files;
	m_packages.erase(name);

#ifdef DEBUG
	cerr << "Removing package phase 1 (all files in package):" << endl;
	copy(files.begin(), files.end(), ostream_iterator<string>(cerr, "\n"));
	cerr << endl;
#endif

	// Don't delete files found in the keep list
	for (set<string>::const_iterator i = keep_list.begin(); i != keep_list.end(); ++i)
		files.erase(*i);

#ifdef DEBUG
	cerr << "Removing package phase 2 (files that is in the keep list excluded):" << endl;
	copy(files.begin(), files.end(), ostream_iterator<string>(cerr, "\n"));
	cerr << endl;
#endif

	// Don't delete files that still have references
	for (packages_t::const_iterator i = m_packages.begin(); i != m_packages.end(); ++i)
		for (set<string>::const_iterator j = i->second.files.begin(); j != i->second.files.end(); ++j)
			files.erase(*j);

#ifdef DEBUG
	cerr << "Removing package phase 3 (files that still have references excluded):" << endl;
	copy(files.begin(), files.end(), ostream_iterator<string>(cerr, "\n"));
	cerr << endl;
#endif

	// Delete the files
	for (set<string>::const_reverse_iterator i = files.rbegin(); i != files.rend(); ++i) {
		const string filename = m_root + *i;
		if (file_exists(filename) && remove(filename.c_str()) == -1) {
			if (errno == ENOTEMPTY)
				continue;
			const char* msg = strerror(errno);
			cerr << /*utilname << FIXME */ ": could not remove " << filename << ": " << msg << endl;
		}
	}
}

void pkgdb_text::rm_files(set<string> files, const set<string>& keep_list)
{
	// Remove all references
	for (packages_t::iterator i = m_packages.begin(); i != m_packages.end(); ++i)
		for (set<string>::const_iterator j = files.begin(); j != files.end(); ++j)
			i->second.files.erase(*j);
   
#ifdef DEBUG
	cerr << "Removing files:" << endl;
	copy(files.begin(), files.end(), ostream_iterator<string>(cerr, "\n"));
	cerr << endl;
#endif

	// Don't delete files found in the keep list
	for (set<string>::const_iterator i = keep_list.begin(); i != keep_list.end(); ++i)
		files.erase(*i);

	// Delete the files
	for (set<string>::const_reverse_iterator i = files.rbegin(); i != files.rend(); ++i) {
		const string filename = m_root + *i;
		if (file_exists(filename) && remove(filename.c_str()) == -1) {
			if (errno == ENOTEMPTY)
				continue;
			const char* msg = strerror(errno);
			cerr << /*utilname << FIXME */ ": could not remove " << filename << ": " << msg << endl;
		}
	}
}

set<string> pkgdb_text::find_conflicts(const string& name, const pkginfo_t& info)
{
	set<string> files;
   
	// Find conflicting files in database
	for (packages_t::const_iterator i = m_packages.begin(); i != m_packages.end(); ++i) {
		if (i->first != name) {
			set_intersection(info.files.begin(), info.files.end(),
					 i->second.files.begin(), i->second.files.end(),
					 inserter(files, files.end()));
		}
	}
	
#ifdef DEBUG
	cerr << "Conflicts phase 1 (conflicts in database):" << endl;
	copy(files.begin(), files.end(), ostream_iterator<string>(cerr, "\n"));
	cerr << endl;
#endif

	// Find conflicting files in filesystem
	for (set<string>::iterator i = info.files.begin(); i != info.files.end(); ++i) {
		const string filename = m_root + *i;
		if (file_exists(filename) && files.find(*i) == files.end())
			files.insert(files.end(), *i);
	}

#ifdef DEBUG
	cerr << "Conflicts phase 2 (conflicts in filesystem added):" << endl;
	copy(files.begin(), files.end(), ostream_iterator<string>(cerr, "\n"));
	cerr << endl;
#endif

	// Exclude directories
	set<string> tmp = files;
	for (set<string>::const_iterator i = tmp.begin(); i != tmp.end(); ++i) {
		if ((*i)[i->length() - 1] == '/')
			files.erase(*i);
	}

#ifdef DEBUG
	cerr << "Conflicts phase 3 (directories excluded):" << endl;
	copy(files.begin(), files.end(), ostream_iterator<string>(cerr, "\n"));
	cerr << endl;
#endif

	// If this is an upgrade, remove files already owned by this package
	if (m_packages.find(name) != m_packages.end()) {
		for (set<string>::const_iterator i = m_packages[name].files.begin(); i != m_packages[name].files.end(); ++i)
			files.erase(*i);

#ifdef DEBUG
		cerr << "Conflicts phase 4 (files already owned by this package excluded):" << endl;
		copy(files.begin(), files.end(), ostream_iterator<string>(cerr, "\n"));
		cerr << endl;
#endif
	}

	return files;
}

pkgdb_text_lock::pkgdb_text_lock(const string& root, bool exclusive)
	: m_dir(0)
{
	m_dirname = trim_filename(root + string("/") + PKG_DIR);

	if(!(m_dir = opendir(m_dirname.c_str())))
		throw runtime_error_with_errno("could not read directory " + m_dirname);

	if(flock(dirfd(m_dir), (exclusive ? LOCK_EX : LOCK_SH) | LOCK_NB) == -1)
  {
		if(errno == EWOULDBLOCK)
			throw runtime_error("package database is currently locked by another process");
		else
			throw runtime_error_with_errno("could not lock directory " + m_dirname);
	}
}

pkgdb_text_lock::~pkgdb_text_lock()
{
	if(m_dir) {
		flock(dirfd(m_dir), LOCK_UN);
		closedir(m_dir);
    m_dir = 0;
	}
}
