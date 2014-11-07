dnl Initialize autoconf and automake
AC_INIT([sw-utils],[0.9.7])
AC_CANONICAL_TARGET
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_AUX_DIR_DEFAULT([build/gnu])
AC_CONFIG_AUX_DIRS([build/gnu m4])
AM_INIT_AUTOMAKE
AC_CONFIG_SRCDIR([libsw++/pkgtool.cpp])




AM_MAINTAINER_MODE
AM_DEP_TRACK

AC_CONFIG_MACRO_DIR([build/gnu])

dnl Check for required programs
AC_PROG_CC
AC_PROG_CXX
AC_PROG_LN_S
#AC_PROG_TOUCH
AM_PROG_LIBTOOL

AC_CHECK_PROG([DEVTODO],[devtodo],[devtodo])


AC_ARG_WITH([shell], AS_HELP_STRING([--with-shell=PATH],[Shell interpreter]),
[SHELL="$withval" ac_cv_prog_SHELL="$SHELL"])

AC_ARG_WITH([shell-path], AS_HELP_STRING([--with-shell-path=PATHLIST],[Where to look for the shell]),
[SHELL_PATH="$withval"])

SYSTEM_LIBTAR="no"
AC_ARG_WITH([system-libtar], AS_HELP_STRING([--with-system-libtar=DIR],[Use installed libtar library]),
[SYSTEM_LIBTAR="$withval"])

AM_CONDITIONAL([SYSTEM_LIBTAR], [test "$SYSTEM_LIBTAR" != no])

AC_PATH_PROGS([SHELL],[sh bash zsh],[${SHELL_PATH:-$PATH}])

AC_CONFIG_HEADER([config.h])



AC_CHECK_PROG([fakeroot])

dnl AC_CHECK_PROG([statifier])
dnl AC_CHECK_LIB([unwind], [_Unwind_Resume])

case $host_os in
  netbsd*) 
    AM_CHECK_PKGSRC([/usr/pkg])
  ;;
esac

# check for Berkeley DB library implemented in m4/db.m4
AM_CHECK_DB

dnl Check for required libraries
AC_CHECK_LIBTAR([ac_cv_system_libtar="yes"], [LIBTAR_CFLAGS='-I$(top_builddir)/libtar/lib'
LIBTAR_LIBS='-L$(top_builddir)/libtar/lib -ltar'
ac_cv_system_libtar="yes"])

AM_CONDITIONAL([USE_SYSTEM_LIBTAR],[test "$ac_cv_system_libtar" = yes])

AC_CHECK_ZLIB([AC_DEFINE([HAVE_ZLIB], [1], [Define this if you have the zlib compression library])])
AC_CHECK_BZLIB([AC_DEFINE([HAVE_BZLIB], [1], [Define this if you have the bzlib compression library])])


dnl Package database
AC_ARG_WITH([pkg-dir], AS_HELP_STRING([--with-pkg-dir=PATH],[Put package database in PATH [[LOCALSTATEDIR/lib/pkg]]]),
[PKG_DIR="$withval"], [PKG_DIR="\${localstatedir}/lib/pkg"])

AC_ARG_ENABLE([debug], AS_HELP_STRING([--enable-debug],[Enable debug mode]),
[debug="$withval"], [debug="no"])

DEFAULT_FLAGS_DEBUG="-g"
DEFAULT_FLAGS_OPT="-O2"

AC_ARG_WITH([debug-flags], AS_HELP_STRING([--with-debug-flags],[Set compiler flags for debugging mode]) []$DEFAULT_FLAGS_DEBUG[],
[if test "$withval" = "yes"
then
  CFLAGS_DEBUG="$DEFAULT_FLAGS_DEBUG"
  CXXFLAGS_DEBUG="$DEFAULT_FLAGS_DEBUG"
  BUILD_DEBUG="yes"
elif test -n "$withval" && test "$withval" != "no"
then
  CFLAGS_DEBUG="$withval"
  CXXFLAGS_DEBUG="$withval"
  BUILD_DEBUG="yes"
elif test "$withval" = "no"
then
  CFLAGS_DEBUG=""
  CXXFLAGS_DEBUG=""
  BUILD_DEBUG="no"
else
  CFLAGS_DEBUG="$DEFAULT_FLAGS_DEBUG"
  CXXFLAGS_DEBUG="$DEFAULT_FLAGS_DEBUG"
  BUILD_DEBUG="yes"
fi], [CFLAGS_DEBUG=""
CXXFLAGS_DEBUG=""
BUILD_DEBUG="no"
])

AC_ARG_WITH([optimization-flags], AS_HELP_STRING([--with-optimization-flags],[Set compiler optimization flags]) []$DEFAULT_FLAGS_OPT[],
[if test -n "$withval" && test "$withval" != "no" && test "$withval" != "yes"
then
  CFLAGS_OPT="$withval"
  CXXFLAGS_OPT="$withval"
  BUILD_OPT="yes"
elif test "$withval" = "yes"
then
  CFLAGS_OPT="$DEFAULT_FLAGS_OPT"
  CXXFLAGS_OPT="$DEFAULT_FLAGS_OPT"
  BUILD_OPT="yes"
else
  CFLAGS_OPT="$DEFAULT_FLAGS_OPT"
  CXXFLAGS_OPT="$DEFAULT_FLAGS_OPT"
  BUILD_OPT="yes"
fi], [CFLAGS_OPT="$DEFAULT_FLAGS_OPT"
CXXFLAGS_OPT="$DEFAULT_FLAGS_OPT"
BUILD_OPT="yes"
])

AC_SUBST([CFLAGS_DEBUG])
AC_SUBST([CXXFLAGS_DEBUG])
AC_SUBST([BUILD_DEBUG])

AC_SUBST([CFLAGS_OPT])
AC_SUBST([CXXFLAGS_OPT])
AC_SUBST([BUILD_OPT])

AC_ARG_ENABLE([werror], AS_HELP_STRING([--enable-werror],[Treat warnings as errors]),
[werror="$withval"], [werror="no"])

AM_CONDITIONAL([DEBUG], [test "$debug" = yes])
AM_CONDITIONAL([WERROR], [test "$werror" = yes])

AC_SUBST([DEBUG], "$debug")
AC_SUBST([WERROR], "$werror")

AC_SUBST([PKG_DIR])            
AC_SUBST([LTVERSION],[`IFS=.;set -- $VERSION;IFS=:;echo "$*"`])

relprefix=${prefix#/}
AC_SUBST([relprefix])

relsysconfdir=${sysconfdir#/}
AC_SUBST([relsysconfdir])

rellocalstatedir=${localstatedir#/}
AC_SUBST([rellocalstatedir])

eval "exec_prefix=\"$prefix\""
AC_SUBST([exec_prefix])

swroot=$(dirname "$prefix")
AC_SUBST([swroot])

swrel=${swroot#/}
AC_SUBST([swrel])

#shlibdir='${libdir}/sh'
AC_SUBST([shlibdir],['${libdir}/sh'])

AC_CONFIG_SUBDIRS([libtar libswsh])

dnl Output build files
AC_CONFIG_FILES([Makefile
rejmerge
pkgadd.conf
pkgadd.8
pkginfo.8
pkgrm.8
rejmerge.8
m4/Makefile
scripts/Makefile
scripts/srcexport
scripts/frompkg
scripts/catexport
scripts/check-libs
scripts/unused-libs
scripts/pkgcheckdep
scripts/pkgexport
scripts/pkginstall
scripts/pkgpatch
scripts/pkgrelease
scripts/pkgstrip
scripts/pkgupdate
scripts/mkservice
scripts/pkg2rpm
$target-wrap:wrap.in
pkgbackup/Makefile
swconfig/Makefile
swconfig/swconfig
pkgmk/Makefile
pkgmk/pkgmk
pkgmk/pkgmk-deb
pkgmk/pkgmk.conf
pkgmk/pkgmk.comp
pkgmk/libtool.conf
pkgmk/layout.conf
pkgmk/mirrors.conf
pkgmk/toolchain.conf
pkgmk/pkgmk.8
pkgmk/pkgmk-buildcmd
svadm/Makefile
svadm/svadm
libsw++/Makefile])

AC_OUTPUT
