#!/bin/sh
#
# 20090427


libtoolize --force --copy --automake
rm -f aclocal.m4; aclocal -I autoconf
autoheader --force
automake --force --copy --foreign --add-missing --foreign --add-missing
rm -f aclocal.m4; aclocal -I autoconf
autoconf --force
