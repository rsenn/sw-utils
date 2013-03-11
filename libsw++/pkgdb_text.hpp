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

#ifndef SWXX_PKGDB_TEXT_H
#define SWXX_PKGDB_TEXT_H

#include <dirent.h>

#include "pkgdb.hpp"

#define PKG_DB_TEXT PKG_DIR"/db"

using namespace std;

class pkgdb_text : public pkgdb {
public:
	explicit pkgdb_text();
	virtual ~pkgdb_text();

protected:
  string m_root;

public:
  virtual void open(const string& path, bool exclusive = true);
  virtual void commit();
  virtual void add_pkg(const string& name, const pkginfo_t& info);
  virtual bool find_pkg(const string& name);
  virtual void rm_pkg(const string& name);
  virtual void rm_pkg(const string& name, const set<string>& keep_list);
  virtual void rm_files(set<string> files, const set<string>& keep_list);
  virtual set<string> find_conflicts(const string& name, const pkginfo_t& info);
};

class pkgdb_text_lock : public pkgdb_lock
{
public:
	explicit pkgdb_text_lock(const string& root, bool exclusive = true);
	virtual ~pkgdb_text_lock();

private:
	DIR* m_dir;
  string m_dirname;
};

#endif /* SWXX_PKGDB_TEXT_H */
