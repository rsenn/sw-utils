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
autoconf --force -I m4 -I build/gnu


subdir() {
	echo "Entering directory $1 ..." 1>&2
	(cd "$1" && exec ${BASH:-sh} ${2-autogen.sh}) || RET=$?
	echo "Leaving directory $1 ..." 1>&2
	return $RET
}

subdir libtar ../build/gnu/autogen.sh || exit $?
subdir libswsh build/gnu/autogen.sh || exit $?
#([ -d objconv ] && cd objconv && exec sh -x autogen.sh) || exit $?
#(cd libtar && exec ${BASH:-sh} autogen.sh) || exit $?
#(cd libswsh && exec ${BASH:-sh} build/gnu/autogen.sh) || exit $?
