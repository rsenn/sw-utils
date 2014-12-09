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

includedirs=$(for DIR in build/gnu ../build/gnu m4 ../m4; do test -d "$DIR/" && echo -I "$DIR"; done)
m4find() {
  for dir in {,../}{build/gnu,autoconf,m4}; do
    [ -d "$dir" ] && echo "-I
$dir"
  done
}

cd "${1-$topdir}"
m4dirs=`m4find`
set -x

type glibtoolize 2>/dev/null >/dev/null && LIBTOOLIZE=glibtoolize || LIBTOOLIZE=libtoolize
$LIBTOOLIZE --force --copy --automake
rm -f aclocal.m4; aclocal $includedirs
autoheader --force
automake --force --copy --foreign --add-missing --foreign
rm -f aclocal.m4; aclocal $includedirs
autoconf --force $includedirs

subdir() {
	if [ -d "$1" -a -f "$1/$2" ]; then
		echo "Entering directory $1 ..." 1>&2
		(cd "$1" && exec ${BASH:-sh} ${2-autogen.sh} .) || RET=$?
		echo "Leaving directory $1 ..." 1>&2
  fi
	return ${RET-0}
}
R=0
subdir libtar autogen.sh || R=`expr $R + $?`
subdir libswsh build/gnu/autogen.sh || R=`expr $R + $?`

exit $R
