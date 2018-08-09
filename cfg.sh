cfg() { 
  build=$(gcc -dumpmachine)
  : ${builddir=build/$build}
  mkdir -p $builddir;
  ( set -x; cd $builddir;
  ../../configure \
    ${prefix:+--prefix="$prefix"} \
    ${sysconfdir:+--sysconfdir="$sysconfdir"} \
    ${localstatedir:+--localstatedir="$localstatedir"} \
    ${build:+--build="$build"} \
    ${host:+--host="$host"} \
    --disable-{silent-rules,dependency-tracking} \
    --disable-rpath \
    --enable-debug \
    "$@")
}

cfg-android() {
  (: ${builddir=build/android}
    cfg \
   "$@")
}

cfg-diet() {
 (build=$(${CC:-gcc} -dumpmachine)
  host=${build/-gnu/-dietlibc}
  : ${builddir=build/$host}
  : ${prefix=/opt/diet}
  : ${libdir=/opt/diet/lib-${host%%-*}}
  : ${bindir=/opt/diet/bin-${host%%-*}}
  
  CC="diet-gcc" \
  PKG_CONFIG="$host-pkg-config" \
  LIBS="${LIBS:+$LIBS }-liconv -lpthread" \
  cfg \
    "$@")
}

cfg-musl() {
 (build=$(${CC:-gcc} -dumpmachine)
  host=${build/-gnu/-musl}
  host=${host/-pc-/-}
  builddir=build/$host
  prefix=/usr
  includedir=/usr/include/$host
  libdir=/usr/lib/$host
  bindir=/usr/bin/$host
  
  CC=musl-gcc \
  PKG_CONFIG=musl-pkg-config \
  cfg \
    "$@")
}

cfg-mingw() {
 (build=$(gcc -dumpmachine)
  host=${build%%-*}-w64-mingw32
  prefix=/usr/$host/sys-root/mingw
  
  builddir=build/$host \
  bindir=$prefix/bin \
  libdir=$prefix/lib \
  cfg \
    "$@")
}

cfg-aarch64() {
 (build=$(gcc -dumpmachine)
  host=aarch64-linux-gnu
  prefix=/usr/$host/sys-root/usr
  
  builddir=build/$host \
  bindir=$prefix/bin \
  libdir=$prefix/lib \
  cfg \
    "$@")
}

cfg-termux() {
  (builddir=build/termux
    cfg \
   "$@")
}
