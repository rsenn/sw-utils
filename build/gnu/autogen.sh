#!/bin/sh
#
# 20081120

thisdir=`dirname "$0"`
topdir=$thisdir/../..

cd "$topdir"

set -x

libtoolize --force --copy --automake
rm -f aclocal.m4; aclocal  -I m4 -I build/gnu
autoheader --force
automake --force --copy --foreign --add-missing --foreign
rm -f aclocal.m4; aclocal -I m4 -I build/gnu
autoconf --force

#([ -d objconv ] && cd objconv && exec sh -x autogen.sh) || exit $?
(cd libtar && exec ${BASH:-sh} autogen.sh) || exit $?
(cd libswsh && exec ${BASH:-sh} build/gnu/autogen.sh) || exit $?
