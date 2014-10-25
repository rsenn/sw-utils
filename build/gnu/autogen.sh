#!/bin/sh
#
# 20081120

thisdir=`dirname "$0"`
topdir=$thisdir/../..

cmd() {
(IFS=" "
	CMD="$*"
	echo "+ $CMD" 1>&2
	eval "$CMD")
}
cd "${1-$topdir}"

set -x
type glibtoolize 2>/dev/null >/dev/null && LIBTOOLIZE=glibtoolize || LIBTOOLIZE=libtoolize
$LIBTOOLIZE --force --copy --automake
rm -f aclocal.m4; aclocal  -I m4 -I build/gnu
autoheader --force
automake --force --copy --foreign --add-missing --foreign
rm -f aclocal.m4; aclocal -I m4 -I build/gnu
autoconf --force -I m4 -I build/gnu

subdir() {
	if [ -d "$1" -a -f "$1/$2" ]; then
		echo "Entering directory $1 ..." 1>&2
		(cd "$1" && exec ${BASH:-sh} ${2-autogen.sh} .) || RET=$?
		echo "Leaving directory $1 ..." 1>&2
  fi
	return ${RET-1}
}

subdir libtar ../build/gnu/autogen.sh || exit $?
subdir libswsh build/gnu/autogen.sh || exit $?
