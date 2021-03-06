//
//  pkgtools
// 
//  Copyright (c) 2000-2005 Per Liden
//  
//  Changes for pkgtools by Roman Senn
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

#ifndef PKGRM_H
#define PKGRM_H

#include "pkgtool.hpp"

#define PKGRM_LIBDIR LIBDIR"/pkgrm"

class pkgrm : public pkgtool {
public:
	pkgrm() : pkgtool("pkgrm") {}
	virtual void run(int argc, char** argv);
	virtual void print_help() const;
};

#endif /* PKGRM_H */
