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

#ifndef SWXX_PKGDB_H
#define SWXX_PKGDB_H

#include <set>
#include <map>

using namespace std;

class pkgdb_lock 
{  
public:
  virtual ~pkgdb_lock() {} // disengages lock
};

class pkgdb
{
public:
	struct pkginfo_t
  {
		string version;
		set<string> files;
	};

  typedef map<string, pkginfo_t> packages_t;
	
  explicit pkgdb() : m_lock(0) {}
	virtual ~pkgdb()
  {
    if(m_lock)
      delete m_lock;
  }

  virtual void open(const string& path, bool exclusive = true) = 0;
  virtual void commit() = 0;
  virtual void add_pkg(const string& name, const pkginfo_t& info) = 0;
  virtual bool find_pkg(const string& name) = 0;
  virtual void rm_pkg(const string& name) = 0;
  virtual void rm_pkg(const string& name, const set<string>& keep_list) = 0;
  virtual void rm_files(set<string> files, const set<string>& keep_list) = 0;
  virtual set<string> find_conflicts(const string& name, const pkginfo_t& info) = 0;

  packages_t& packages() { return m_packages; }
  packages_t const& packages() const { return m_packages; }
  
protected:
  void lock(pkgdb_lock *lock)
  {
    m_lock = lock;
  }
  
  pkgdb_lock *m_lock;
  packages_t m_packages;
};

#endif /* SWXX_PKGDB_H */
