#!/bin/sh
#
# 20090427


libtoolize --force --copy --automake
aclocal --force -I autoconf
autoheader --force
automake --force --copy --foreign --add-missing --foreign --add-missing
aclocal --force -I autoconf
autoconf --force
