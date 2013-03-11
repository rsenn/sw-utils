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
#include <ext/stdio_filebuf.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/file.h>
#include <sys/param.h>
#include <unistd.h>
#include <fcntl.h>
#include <libgen.h>

#include "pkgdb_dbm.hpp"
#include "pkgtool.hpp"
#include "config.h"

using namespace std;

using __gnu_cxx::stdio_filebuf;

pkgdb_dbm::pkgdb_dbm() {}
pkgdb_dbm::~pkgdb_dbm() {}
  
void pkgdb_dbm::open(const string& path, bool exclusive)
{
  pkgdb::lock(new pkgdb_dbm_lock(path, exclusive));
  
	// Read database
	m_root = trim_filename(path + "/");
	const string filename = m_root + PKG_DB_DBM;

	m_db = ::dbm_open
    (filename.c_str(), DB_RDONLY|DB_CREATE|(exclusive?DB_EXCL:0), 0644);

	if(m_db == 0)
		throw runtime_error_with_errno("could not open " + filename);
}

void pkgdb_dbm::commit()
{
}

void pkgdb_dbm::add_pkg(const string& name, const pkginfo_t& info)
{
}

bool pkgdb_dbm::find_pkg(const string& name)
{
}

void pkgdb_dbm::rm_pkg(const string& name)
{
}

void pkgdb_dbm::rm_pkg(const string& name, const set<string>& keep_list)
{
}

void pkgdb_dbm::rm_files(set<string> files, const set<string>& keep_list)
{
}

set<string> pkgdb_dbm::find_conflicts(const string& name, const pkginfo_t& info)
{
}

pkgdb_dbm_lock::pkgdb_dbm_lock(const string& root, bool exclusive)
	: m_dir(0)
{
}

pkgdb_dbm_lock::~pkgdb_dbm_lock()
{
}
