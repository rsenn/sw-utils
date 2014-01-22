#!/bin/sh

while [ "$#" -gt 0 ]; do
  case $1 in
    --prefix) PREFIX="$2" ; shift ;; --prefix=*) PREFIX="${1#*=}" ;;
  esac
  shift
done

IFS="$IFS:"
SHELL=/bin/sh
MYDIR=`dirname "$0"`
MYNAME=`basename "$0"`
ABSDIR=`cd "$MYDIR" && pwd`
ABSPATH="$ABSDIR/$MYNAME"

for NAME in bash dash ash ksh; do
  for DIR in $PATH; do
    if [ -x "$DIR/$NAME" ]; then
      SHELL="$DIR/$NAME"
      break 2
    fi
  done
done

HOST=`${CC-gcc} -dumpmachine 2>/dev/null`

case $HOST in
  *--*) HOST=`echo "$HOST" | sed "s,--,-unknown-,g"` ;;
esac

if [ -z "$PREFIX" ]; then
	case $HOST in
	  *-netbsdelf*) PREFIX=/usr/local ;;
	  *)
	    PREFIX=`
	      ${CC-gcc} -print-search-dirs 2>/dev/null | 
	      sed -ne '/^install:/ s|^install: \([^ ]\+\)/lib/.*|\1| p'
	    `
	  ;;
	esac
fi

echo "Configuring for host $HOST and installation in $PREFIX ..." 1>&2
echo 1>&2

case $PREFIX in 
  "/usr") sysconfdir="/etc" localstatedir="/var" bindir="/bin" ;;
esac
depdendency_tracking="disable"
maintainer_mode="disable"

set -x 
exec ${BASH:+"$BASH"} "$MYDIR/configure" \
    --with-shell="$SHELL" \
    --program-prefix="" \
    --program-suffix="" \
    --disable-debug \
    --${depdendency_tracking:-enable}-dependency-tracking \
    --${maintainer_mode:-enable}-maintainer-mode \
    --host="$HOST" \
    --build="${build=$HOST}" \
    --target="${target=$HOST}" \
    --prefix="$PREFIX" \
    --sysconfdir="${sysconfdir=$PREFIX/etc}" \
    --localstatedir="${localstatedir=$PREFIX/var}" \
    "$@"
    