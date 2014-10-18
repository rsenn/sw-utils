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


cmd libtoolize --force --copy --automake
rm -f aclocal.$topdir/m4; cmd aclocal  $(test -d $topdir/m4 && echo -I $topdir/m4) $(test -d $topdir/build/gnu && echo -I $topdir/build/gnu)
cmd autoheader --force
cmd automake --force --copy --foreign --add-missing --foreign
rm -f aclocal.$topdir/m4; cmd aclocal $(test -d $topdir/m4 && echo -I $topdir/m4) $(test -d $topdir/build/gnu && echo -I $topdir/build/gnu)
cmd autoconf --force  $(test -d $topdir/m4 && echo -I $topdir/m4) $(test -d $topdir/build/gnu && echo -I $topdir/build/gnu)

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
