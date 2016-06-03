#!/bin/sh
#
# 20090427

set -x

type glibtoolize 2>/dev/null >/dev/null && LIBTOOLIZE=glibtoolize || LIBTOOLIZE=libtoolize
$LIBTOOLIZE --force --copy --automake
rm -f aclocal.m4; aclocal -I autoconf
autoheader --force
automake --force --copy --foreign --add-missing --foreign --add-missing
rm -f aclocal.m4; aclocal -I autoconf
autoconf --force
