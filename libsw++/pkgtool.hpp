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

#ifndef SWXX_PKGTOOL_H
#define SWXX_PKGTOOL_H

#include <string>
#include <set>
#include <map>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <cerrno>
#include <cstring>
#include <stdint.h>
#include <sys/types.h>
#include <dirent.h>
#include <libtar.h>

#include "pkgdb.hpp"

#define PKG_EXT         ".pkg.tar.gz"
#define PKG_DB          PKG_DIR"/db"
#define PKG_REJECTED    PKG_DIR"/rejected"
#define VERSION_DELIM   '#'
#define LDCONFIG        SBINDIR"/ldconfig"
#define LDCONFIG_CONF   SYSCONFDIR"/ld.so.conf"

using namespace std;

class pkgtool {
public:
	explicit pkgtool(const string& name);
	virtual ~pkgtool() {}
	virtual void run(int argc, char** argv) = 0;
	virtual void print_help() const = 0;
	void print_version() const;

protected:
	// Tar.gz
	pair<string, pkgdb::pkginfo_t> pkg_open(const string& filename) const;
	tartype_t *pkg_gettype(const string& filename) const;
	void pkg_install(const string& filename, const set<string>& keep_list) const;
	void pkg_footprint(string& filename) const;
	void ldconfig() const;
  void script_load(const string& filename, string& buffer) const;
  void script_load(const string& archive, const string& filename, string& buffer) const;
  void script_exec(const string& script) const;
	void script(const string& filename, const string& script) const;

	string utilname;
//	packages_t packages;
	string root;
  pkgdb *m_db;
};

class runtime_error_with_errno : public runtime_error {
public:
	explicit runtime_error_with_errno(const string& msg) throw()
		: runtime_error(msg + string(": ") + strerror(errno)) {}
};

// Utility functions
void assert_argument(char** argv, int argc, int index);
string itos(unsigned int value);
string mtos(mode_t mode);
intptr_t unistd_gzopen(char* pathname, int flags, mode_t mode);
ssize_t unistd_bz2open(char* pathname, int flags, mode_t mode);
string trim_filename(const string& filename);
bool file_exists(const string& filename);
bool file_empty(const string& filename);
bool file_equal(const string& file1, const string& file2);
bool permissions_equal(const string& file1, const string& file2);
void file_remove(const string& basedir, const string& filename);

#endif /* SWXX_PKGTOOL_H */
