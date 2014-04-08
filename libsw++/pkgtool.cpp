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

#include "pkgtool.hpp"
#include <iostream>
#include <sstream>
#include <iterator>
#include <algorithm>
#include <cstdio>
#include <cstring>
#include <cerrno>
#include <csignal>
#include <ext/stdio_filebuf.h>
#include <pwd.h>
#include <grp.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/file.h>
#include <sys/param.h>
#include <unistd.h>
#include <fcntl.h>
#include <libgen.h>

#include "config.h"
#include "pkgdb_text.hpp"

#ifdef HAVE_ZLIB
#include <zlib.h>
#endif /* HAVE_ZLIB */

#ifdef HAVE_BZLIB
#include <bzlib.h>
#endif /* HAVE_BZLIB */

using __gnu_cxx::stdio_filebuf;

#ifdef HAVE_ZLIB
static tartype_t gztype = {
	(openfunc_t)unistd_gzopen,
	(closefunc_t)gzclose,
	(readfunc_t)gzread,
	(writefunc_t)gzwrite
};
#endif /* HAVE_ZLIB */

#ifdef HAVE_BZLIB
static tartype_t bz2type = {
	(openfunc_t)unistd_bz2open,
	(closefunc_t)BZ2_bzclose,
	(readfunc_t)BZ2_bzread,
	(writefunc_t)BZ2_bzwrite
};
#endif /* HAVE_BZLIB */

pkgtool::pkgtool(const string& name)
	: utilname(name)
{
  // Initialize DB
  m_db = new pkgdb_text();
  
	// Ignore signals
	struct sigaction sa;
	memset(&sa, 0, sizeof(sa));
	sa.sa_handler = SIG_IGN;
	sigaction(SIGHUP, &sa, 0);
	sigaction(SIGINT, &sa, 0);
	sigaction(SIGQUIT, &sa, 0);
	sigaction(SIGTERM, &sa, 0);
}

pair<string, pkgdb::pkginfo_t> pkgtool::pkg_open(const string& filename) const
{
	pair<string, pkgdb::pkginfo_t> result;
	unsigned int i;
	TAR* t;

	// Extract name and version from filename
	string basename(filename, filename.rfind('/') + 1);
	string name(basename, 0, basename.find(VERSION_DELIM));
	string version(basename, 0, basename.rfind(PKG_EXT));
	version.erase(0, version.find(VERSION_DELIM) == string::npos ? string::npos : version.find(VERSION_DELIM) + 1);
   
	if (name.empty() || version.empty())
		throw runtime_error("could not determine name and/or version of " + basename + ": Invalid package name");

	result.first = name;
	result.second.version = version;

	if (tar_open(&t, const_cast<char*>(filename.c_str()), pkg_gettype(filename), O_RDONLY, 0, TAR_GNU) == -1)
		throw runtime_error_with_errno("could not open " + filename);

	for (i = 0; !th_read(t); ++i) {
		string archive_filename = th_get_pathname(t);
		
		/* skip when path begins with a capital letter */
		if(isupper(archive_filename[0]))
		{
			tar_skip_regfile(t);
			continue;
		}
		
		result.second.files.insert(result.second.files.end(), th_get_pathname(t));
		if (TH_ISREG(t) && tar_skip_regfile(t))
			throw runtime_error_with_errno("could not read " + filename);
	}
   
	if (i == 0) {
		if (errno == 0)
			throw runtime_error("empty package");
		else
			throw runtime_error("could not read " + filename);
	}

	tar_close(t);

	return result;
}

tartype_t *pkgtool::pkg_gettype(const string& filename) const
{
	char *fname, *ext;
	tartype_t *type = NULL;

	fname = const_cast<char*>(filename.c_str());
  
	if((ext = strrchr(fname, '.')))
	{
		ext++;
		
#ifdef HAVE_ZLIB
		if(!strcmp(ext, "gz"))
			type = &gztype;
#endif /* HAVE_ZLIB */
#if defined(HAVE_ZLIB) && defined(HAVE_BZLIB)
		else
#endif
#ifdef HAVE_BZLIB
			if(!strcmp(ext, "bz2"))
				type = &bz2type;
#endif
	}
	
	return type;
}

void pkgtool::pkg_install(const string& filename, const set<string>& keep_list) const
{
	TAR* t;
	unsigned int i;
  
	if (tar_open(&t, const_cast<char*>(filename.c_str()), pkg_gettype(filename), O_RDONLY, 0, TAR_GNU) == -1)
		throw runtime_error_with_errno("could not open " + filename);

	for (i = 0; !th_read(t); ++i) {
		string archive_filename = th_get_pathname(t);
		string reject_dir = trim_filename(root + string("/") + string(PKG_REJECTED));
		string original_filename = trim_filename(root + string("/") + archive_filename);
		string real_filename = original_filename;

		/* skip when path begins with a capital letter */
		if(isupper(archive_filename[0]))
		{
			tar_skip_regfile(t);
			continue;
		}
		
		// Check if file should be rejected
		if (file_exists(real_filename) && keep_list.find(archive_filename) != keep_list.end())
			real_filename = trim_filename(reject_dir + string("/") + archive_filename);

		// Extract file
		if (tar_extract_file(t, const_cast<char*>(real_filename.c_str()))) {
			// If a file fails to install we just print an error message and
			// continue trying to install the rest of the package.
			const char* msg = strerror(errno);
			cerr << utilname << ": could not install " + archive_filename << ": " << msg << endl;
			continue;
		}

		// Check rejected file
		if (real_filename != original_filename) {
			bool remove_file = false;

			// Directory
			if (TH_ISDIR(t))
				remove_file = permissions_equal(real_filename, original_filename);
			// Other files
			else
				remove_file = permissions_equal(real_filename, original_filename) &&
					(file_empty(real_filename) || file_equal(real_filename, original_filename));

			// Remove rejected file or signal about its existence
			if (remove_file)
				file_remove(reject_dir, real_filename);
			else
				cout << utilname << ": rejecting " << root << "/" << archive_filename << ", keeping existing version" << endl;
		}
	}

	if (i == 0) {
		if (errno == 0)
			throw runtime_error("empty package");
		else
			throw runtime_error("could not read " + filename);
	}

	tar_close(t);
}

void pkgtool::ldconfig() const
{
	// Only execute ldconfig if /etc/ld.so.conf exists
	if (file_exists(root + LDCONFIG_CONF)) {
		pid_t pid = fork();

		if (pid == -1)
			throw runtime_error_with_errno("fork() failed");

		if (pid == 0) {
      ::close(STDERR_FILENO);
      ::open("/dev/null", O_WRONLY);
			::execl(LDCONFIG, LDCONFIG, "-r", root.c_str(), 0);
			const char* msg = strerror(errno);
			cerr << utilname << ": could not execute " << LDCONFIG << ": " << msg << endl;
			exit(EXIT_FAILURE);
		} else {
			if (waitpid(pid, 0, 0) == -1)
				throw runtime_error_with_errno("waitpid() failed");
		}
	}
}

void pkgtool::script_load(const string& filename, string& buffer) const
{
  ifstream::pos_type size;
  ifstream input(filename.c_str(), ios::ate);;
 
  if(input.is_open())
  {
    char *buf;
    size = input.tellg();
    buf = new char[size];
    input.seekg(0, ios::beg);
    input.read(buf, size);
    input.close();
    buffer.assign(buf, size);
    delete[] buf;
  }
}

void pkgtool::script_exec(const string& script) const
{
  pid_t pid;
  
  pid = fork();
  if(pid == -1)
    throw runtime_error_with_errno("fork() failed");
  
  if(pid == 0)
  {
    execl(SHELL, "-c", script.c_str(), NULL);
    throw runtime_error_with_errno("could not execute script");
  }
  
  int status;
  if(waitpid(pid, &status, 0) == -1)
    throw runtime_error_with_errno("waitpid() failed");
  
  if(WEXITSTATUS(status))
  {
    stringstream code;
    code << WEXITSTATUS(status);
    string codestr(code.str());
    throw runtime_error("script failed with exit code " + codestr);
  }
}

void pkgtool::script(const string& filename, const string& script) const
{
	TAR* t;
	unsigned int i;
	
	if(tar_open(&t, const_cast<char*>(filename.c_str()), pkg_gettype(filename), O_RDONLY, 0, TAR_GNU) == -1)
		throw runtime_error_with_errno("could not open " + filename);
	
	for(i = 0; !th_read(t); ++i)
	{
		string archive_filename = th_get_pathname(t);
		
		/* abort on the first filename that begins with non-caps */
/*		if(islower((const_cast<char*>(archive_filename.c_str()))[0]))
		{
			tar_close(t);
			return;
		}*/
		
		if(archive_filename == script)
		{
			char *tempfile = tempnam("/tmp", "sw");
			pid_t pid;

			if(tar_extract_file(t, const_cast<char*>(tempfile)))
        throw runtime_error_with_errno("could not read " + archive_filename);
			
			cerr << utilname << ": executing " << archive_filename << "..." << endl;
			
			pid = fork();

			if(pid == -1)
				throw runtime_error_with_errno("fork() failed");
			
			if(pid == 0)
			{
				execl(SHELL, const_cast<char*>(script.c_str()), const_cast<char*>(tempfile), 0);
        throw runtime_error_with_errno("could not execute" + script);
				exit(EXIT_FAILURE);
			} else {
				int status;
				if(waitpid(pid, &status, 0) == -1)
					throw runtime_error_with_errno("waitpid() failed");
				
				if(WEXITSTATUS(status))
        {
          stringstream code;
          code << WEXITSTATUS(status);
          string codestr(code.str());
          throw runtime_error("script " + script + " failed (exitcode " + codestr + ")");
        }
        
			}
		}
	}

	tar_close(t);
}

void pkgtool::pkg_footprint(string& filename) const
{
	unsigned int i;
	TAR* t;

	if (tar_open(&t, const_cast<char*>(filename.c_str()), pkg_gettype(filename), O_RDONLY, 0, TAR_GNU) == -1)
		throw runtime_error_with_errno("could not open " + filename);

	for (i = 0; !th_read(t); ++i) {
		string archive_filename = th_get_pathname(t);

		/* skip when path begins with a capital letter */
		if(isupper(archive_filename[0]))
		{
			tar_skip_regfile(t);
			continue;
		}
		
		// Access permissions
		if (TH_ISSYM(t)) {
			// Access permissions on symlinks differ among filesystems, e.g. XFS and ext2 have different.
			// To avoid getting different footprints we always use "lrwxrwxrwx".
			cout << "lrwxrwxrwx";
		} else {
			cout << mtos(th_get_mode(t));
		}

		cout << '\t';

		// User
		uid_t uid = th_get_uid(t);
		struct passwd* pw = getpwuid(uid);
		if (pw)
			cout << pw->pw_name;
		else
			cout << uid;

		cout << '/';

		// Group
		gid_t gid = th_get_gid(t);
		struct group* gr = getgrgid(gid);
		if (gr)
			cout << gr->gr_name;
		else
			cout << gid;

		// Filename
		cout << '\t' << th_get_pathname(t);

		// Special cases
		if (TH_ISSYM(t)) {
			// Symlink
			cout << " -> " << th_get_linkname(t);
		} else if (TH_ISCHR(t) || TH_ISBLK(t)) {
			// Device
			cout << " (" << th_get_devmajor(t) << ", " << th_get_devminor(t) << ")";
		} else if (TH_ISREG(t) && !th_get_size(t)) {
			// Empty regular file
			cout << " (EMPTY)";
		}

		cout << '\n';
		
		if (TH_ISREG(t) && tar_skip_regfile(t))
			throw runtime_error_with_errno("could not read " + filename);
	}
	
	if (i == 0) {
		if (errno == 0)
			throw runtime_error("empty package");
		else
			throw runtime_error("could not read " + filename);
	}
	
	tar_close(t);
}

void pkgtool::print_version() const
{
	cout << utilname << " (pkgtools) " << PACKAGE_VERSION << endl;
}

void assert_argument(char** argv, int argc, int index)
{
	if (argc - 1 < index + 1)
		throw runtime_error("option " + string(argv[index]) + " requires an argument");
}

string itos(unsigned int value)
{
	static char buf[20];
	sprintf(buf, "%u", value);
	return buf;
}

string mtos(mode_t mode)
{
	string s;

	// File type
	switch (mode & S_IFMT) {
        case S_IFREG:  s += '-'; break; // Regular
        case S_IFDIR:  s += 'd'; break; // Directory
        case S_IFLNK:  s += 'l'; break; // Symbolic link
        case S_IFCHR:  s += 'c'; break; // Character special
        case S_IFBLK:  s += 'b'; break; // Block special
        case S_IFSOCK: s += 's'; break; // Socket
        case S_IFIFO:  s += 'p'; break; // Fifo
        default:       s += '?'; break; // Unknown
        }

	// User permissions
        s += (mode & S_IRUSR) ? 'r' : '-';
        s += (mode & S_IWUSR) ? 'w' : '-';
        switch (mode & (S_IXUSR | S_ISUID)) {
        case S_IXUSR:           s += 'x'; break;
        case S_ISUID:           s += 'S'; break;
        case S_IXUSR | S_ISUID: s += 's'; break;
        default:                s += '-'; break;
        }

        // Group permissions
	s += (mode & S_IRGRP) ? 'r' : '-';
        s += (mode & S_IWGRP) ? 'w' : '-';
        switch (mode & (S_IXGRP | S_ISGID)) {
        case S_IXGRP:           s += 'x'; break;
        case S_ISGID:           s += 'S'; break;
	case S_IXGRP | S_ISGID: s += 's'; break;
        default:                s += '-'; break;
        }

        // Other permissions
        s += (mode & S_IROTH) ? 'r' : '-';
        s += (mode & S_IWOTH) ? 'w' : '-';
        switch (mode & (S_IXOTH | S_ISVTX)) {
        case S_IXOTH:           s += 'x'; break;
        case S_ISVTX:           s += 'T'; break;
        case S_IXOTH | S_ISVTX: s += 't'; break;
        default:                s += '-'; break;
        }

	return s;
}

#ifdef HAVE_ZLIB
intptr_t unistd_gzopen(char* pathname, int flags, mode_t mode)
{
	const char* gz_mode;
   
	switch (flags & O_ACCMODE) {
	case O_WRONLY:
		gz_mode = "w";
		break;

	case O_RDONLY:
		gz_mode = "r";
		break;

	case O_RDWR:
	default:
		errno = EINVAL;
		return -1;
	}

	int fd;
	gzFile gz_file;

	if ((fd = open(pathname, flags, mode)) == -1)
		return -1;
   
	if ((flags & O_CREAT) && fchmod(fd, mode))
		return -1;
   
	if (!(gz_file = gzdopen(fd, gz_mode))) {
		errno = ENOMEM;
		return -1;
	}
   
	return (intptr_t)gz_file;
}
#endif /* HAVE_ZLIB */

#ifdef HAVE_BZLIB
ssize_t unistd_bz2open(char* pathname, int flags, mode_t mode)
{
	const char* bz2_mode;
   
	switch (flags & O_ACCMODE) {
	case O_WRONLY:
		bz2_mode = "w";
		break;

	case O_RDONLY:
		bz2_mode = "r";
		break;

	case O_RDWR:
	default:
		errno = EINVAL;
		return -1;
	}

	int fd;
	BZFILE *BZ2_file;

	if ((fd = open(pathname, flags, mode)) == -1)
		return -1;
   
	if ((flags & O_CREAT) && fchmod(fd, mode))
		return -1;
   
	if (!(BZ2_file = BZ2_bzdopen(fd, bz2_mode))) {
		errno = ENOMEM;
		return -1;
	}
   
	return (ssize_t)BZ2_file;
}
#endif /* HAVE_BZLIB */

string trim_filename(const string& filename)
{
	string search("//");
	string result = filename;

	for (string::size_type pos = result.find(search); pos != string::npos; pos = result.find(search))
		result.replace(pos, search.size(), "/");

	return result;
}

bool file_exists(const string& filename)
{
	struct stat buf;
	return !lstat(filename.c_str(), &buf);
}

bool file_empty(const string& filename)
{
	struct stat buf;

	if (lstat(filename.c_str(), &buf) == -1)
		return false;
	
	return (S_ISREG(buf.st_mode) && buf.st_size == 0);
}

bool file_equal(const string& file1, const string& file2)
{
	struct stat buf1, buf2;

	if (lstat(file1.c_str(), &buf1) == -1)
		return false;

	if (lstat(file2.c_str(), &buf2) == -1)
		return false;

	// Regular files
	if (S_ISREG(buf1.st_mode) && S_ISREG(buf2.st_mode)) {
		ifstream f1(file1.c_str());
		ifstream f2(file2.c_str());
	
		if (!f1 || !f2)
			return false;

		while (!f1.eof()) {
			char buffer1[4096];
			char buffer2[4096];
			f1.read(buffer1, 4096);
			f2.read(buffer2, 4096);
			if (f1.gcount() != f2.gcount() ||
			    memcmp(buffer1, buffer2, f1.gcount()) ||
			    f1.eof() != f2.eof())
				return false;
		}

		return true;
	}
	// Symlinks
	else if (S_ISLNK(buf1.st_mode) && S_ISLNK(buf2.st_mode)) {
		char symlink1[MAXPATHLEN];
		char symlink2[MAXPATHLEN];

		memset(symlink1, 0, MAXPATHLEN);
		memset(symlink2, 0, MAXPATHLEN);

		if (readlink(file1.c_str(), symlink1, MAXPATHLEN - 1) == -1)
			return false;

		if (readlink(file2.c_str(), symlink2, MAXPATHLEN - 1) == -1)
			return false;

		return !strncmp(symlink1, symlink2, MAXPATHLEN);
	}
	// Character devices
	else if (S_ISCHR(buf1.st_mode) && S_ISCHR(buf2.st_mode)) {
		return buf1.st_dev == buf2.st_dev;
	}
	// Block devices
	else if (S_ISBLK(buf1.st_mode) && S_ISBLK(buf2.st_mode)) {
		return buf1.st_dev == buf2.st_dev;
	}

	return false;
}

bool permissions_equal(const string& file1, const string& file2)
{
	struct stat buf1;
	struct stat buf2;

	if (lstat(file1.c_str(), &buf1) == -1)
		return false;

	if (lstat(file2.c_str(), &buf2) == -1)
		return false;
	
	return(buf1.st_mode == buf2.st_mode) &&
		(buf1.st_uid == buf2.st_uid) &&
		(buf1.st_gid == buf2.st_gid);
}

void file_remove(const string& basedir, const string& filename)
{
	if (filename != basedir && !remove(filename.c_str())) {
		char* path = strdup(filename.c_str());
		file_remove(basedir, dirname(path));
		free(path);
	}
}
