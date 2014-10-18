#!/bin/sh

host=`${CC-gcc} -dumpmachine 2>/dev/null`

if test -z "$host"
then
  host=`./config.guess`
  prefix="/usr"
else
  prefix=`${CC-gcc} -print-search-dirs 2>/dev/null | sed -ne '/^install:/ s|^install: \([^ ]\+\)/lib/.*|\1| p'`
fi

echo "Configuring for host $host and installation in $prefix ..." 1>&2
echo 1>&2

case $prefix in 
  "/usr")
    sysconfdir="/etc"
    localstatedir="/var"
    bindir="/bin"
    ;;
esac

exec ./configure \
    --host="$host" \
    --build="${build=$host}" \
    --target="${target=$host}" \
    --prefix="$prefix" \
    --sysconfdir="${sysconfdir=$prefix/etc}" \
    --localstatedir="${localstatedir=$prefix/var}" \
    --with-shell="${bindir=$prefix/bin}/bash" \
    --program-prefix="" \
    --program-suffix="" \
    "$@"
    
