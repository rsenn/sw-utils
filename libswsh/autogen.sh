#!/bin/sh
#
# 20190425

libtoolize --force --copy --automake 
aclocal -I . -I build/gnu -I m4 
automake --force --copy --foreign --add-missing --add-missing
aclocal --force -I . -I build/gnu -I m4 
autoconf --force
