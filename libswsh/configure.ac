dnl Initialize autoconf and automake
AC_INIT([libswsh],[0.9.7])

AC_CANONICAL_TARGET
AC_CONFIG_AUX_DIR([build/gnu])
AC_CONFIG_MACRO_DIR([build/gnu])
AC_CONFIG_SRCDIR([lib/util.sh.in])

AM_INIT_AUTOMAKE
dnl AM_MAINTAINER_MODE
dnl AM_DEP_TRACK

dnl Check for required programs
AC_PROG_AWK

if test -z "$AWK"; then
  AC_CHECK_PROGS([AWK], [gawk awk])
fi

export AWK

AC_PROG_LN_S
AC_PROG_MKDIR_P

dnl AC_ARG_WITH([shell-path], AC_HELP_STRING([--with-shell-path=PATHLIST], [Where to look for the shell]),
dnl [SHELL_PATH="$withval"])

AC_DEFINE_DIR([portsdir],[prefix/ports],[Define this to the directory where you store your ports tree])
AC_DEFINE_DIR([pkgdir],[prefix/pkg],[Define this to the directory where you want to store built packages])

# Check for required programs
SHELLS=

AC_ARG_WITH([shells],AC_HELP_STRING([--with-shells=LIST],[Specify the shells you want to use]),[SHELLS="$withval"])

if test -z "$SHELLS"; then
  if test -z "$BASH" -o "`basename "$BASH"`" = sh; then
    AC_CHECK_PROG([BASH],[bash],[bash])
  fi
  if test -n "$BASH"; then
    test -n "$SHELLS" && SHELLS="$SHELLS `basename "$BASH"`" || SHELLS="`basename "$BASH"`"
  fi

  AC_CHECK_PROG([SH],[sh],[sh])
  if test -n "$SH" -a "$SHELLS" != sh; then
    test -n "$SHELLS" && SHELLS="$SHELLS $SH" || SHELLS="$SH"
  fi

  AC_CHECK_PROG([ASH],[ash],[ash])
  if test -n "$ASH"; then
    test -n "$SHELLS" && SHELLS="$SHELLS $ASH" || SHELLS="$ASH"
  fi

  AC_CHECK_PROG([DASH],[dash],[dash])
  if test -n "$DASH"; then
    test -n "$SHELLS" && SHELLS="$SHELLS $DASH" || SHELLS="$DASH"
  fi

  AC_CHECK_PROG([ZSH],[zsh],[zsh])
  if test -n "$ZSH"; then
    test -n "$SHELLS" && SHELLS="$SHELLS $ZSH" || SHELLS="$ZSH"
  fi

  AC_CHECK_PROG([KSH],[ksh],[ksh])
  if test -n "$KSH"; then
    test -n "$SHELLS" && SHELLS="$SHELLS $KSH" || SHELLS="$KSH"
  fi
fi
dnl AC_CHECK_PROG([SHISH],[shish],[shish])
dnl if [ -n "$SHISH" ]; then
dnl   test -n "$SHELLS" && SHELLS="$SHELLS $SHISH" || SHELLS="$SHISH"
dnl fi

AC_SUBST([SHELLS])

AC_CHECK_PROG([DEVTODO],[devtodo],[devtodo])
AM_CONDITIONAL([DEVTODO],[test -n "$DEVTODO"])

# Check for the ShUnit2 Unit Test Framework
AC_CHECK_PROG([SHUNIT2],[shunit2],[shunit2])
AM_CONDITIONAL([SHUNIT2],[test -n "$SHUNIT2"])

# Check for the shflags Command Line Parser
AC_CHECK_PATH([SHFLAGS],[shflags],[shflags])
AM_CONDITIONAL([SHFLAGS],[test -n "$SHFLAGS"])

AC_CHECK_PROGS([NETCAT],[netcat nc])

# Check for the "curl" utility, because we can provide data for it.
AM_FIND_PROG([CURL],[curl])
AM_FIND_PROG([WGET],[wget])

AM_FIND_PROG([LYNX],[lynx])
AM_FIND_PROG([LINKS],[links])
AM_FIND_PROG([W3M],[w3m])

AM_FIND_PROG([FTP],[ftp])
AM_FIND_PROG([NCFTP],[ncftp])
AM_FIND_PROG([LFTP],[lftp])

# Check for archivers
AM_FIND_PROG([SHAR],[shar])
AM_FIND_PROG([TAR],[tar])
AM_FIND_PROG([STAR],[star])
AM_FIND_PROG([ZIP],[zip])
AM_FIND_PROG([UNZIP],[unzip])
AM_FIND_PROG([RAR],[rar])
AM_FIND_PROG([UNRAR],[unrar])

# Check for available compression utilities
AM_FIND_PROG([COMPRESS],[compress])
AM_FIND_PROG([GZIP],[gzip])
AM_FIND_PROG([BZIP2],[bzip2])
AM_FIND_PROG([LZMA],[lzma])
AM_FIND_PROG([LZOP],[lzop])

# Check for the "newfile" utility, because we can provide data for it.
AM_FIND_PROG([NEWFILE],[newfile])


dnl AM_FIND_PROG([BLAH],[blah])

# Check for the sysprofile infrastructure, because we can install an 
# automatically loaded require() function to include shell script modules
AC_MSG_CHECKING([for shell profile dir])
AC_ARG_WITH([profile-dir], AC_HELP_STRING([--with-profile-dir=PATH], [Put shell profile modules in PATH [[SYSCONFDIR/profile.d]]]),[dnl
ac_cv_profiledir="$withval"; if test "$ac_cv_profiledir" = no; then ac_cv_profiledir=; fi
],[dnl

dnl AC_MSG_CHECKING([for the system-wide shell profile directory])

set -- $sysconfdir/sysprofile.d $sysconfdir/profile.d

case $prefix in
  / | /usr | /usr/local | /opt/*) set -- "$@" /etc/sysprofile.d /etc/profile.d;;
esac

for ac_dir; do
  if eval test -d "\"$ac_dir\""; then
    ac_cv_profiledir="$ac_dir"
    break
  fi
done
dnl])
if test -n "$ac_cv_profiledir"; then
  AC_MSG_RESULT([$ac_cv_profiledir])
else
  AC_MSG_RESULT([not found])
fi
AM_CONDITIONAL([PROFILE], [test -n "$ac_cv_profiledir"])
AC_SUBST([sysprofiledir], [$ac_cv_profiledir])

# Set up some special directories
AC_SUBST([pkgdatadir],[\${datadir}/$PACKAGE_NAME])
AC_SUBST([templatedir],[\${pkgdatadir}/data])

# Find the actual shell
dnl AC_ARG_WITH([shell], AC_HELP_STRING([--with-shell=PATH], [Shell interpreter]),
dnl [SHELL="$withval" ac_cv_prog_SHELL="$SHELL"])

# Find the package storage directory
AC_ARG_WITH([pkg-dir], AC_HELP_STRING([--with-pkg-dir=PATH], [Store packages in PATH [[LOCALSTATEDIR/lib/pkg]]]),
[PKG_DIR="$withval"], [PKG_DIR="\${localstatedir}/lib/pkg"])

AC_ARG_ENABLE([debug], AC_HELP_STRING([--enable-debug], [Enable debug mode]),
[ac_cv_debug="$withval"], [ac_cv_debug="no"])

# Find the daemontools service directory
AC_ARG_WITH([service-dir], AC_HELP_STRING([--with-service-dir=PATH], [Services root for svscan [[EXEC_PREFIX/service]]]),
[servicedir="$withval"], [case $prefix in 
  /usr | /) servicedir="/service" ;;
         *) servicedir="\${exec_prefix}/service" ;;
esac])
AC_SUBST([servicedir])

# Install a debug build?
AC_ARG_ENABLE([debug], AC_HELP_STRING([--enable-debug], [Enable debug mode]),
[ac_cv_debug="$withval"], [ac_cv_debug="no"])

if test -n "$ac_cv_debug"; then
  ac_cv_debug="yes"
fi

dnl DEFAULT_FLAGS_DEBUG="-g"
dnl DEFAULT_FLAGS_OPT="-O2"
dnl
dnl AC_ARG_WITH([debug-flags], AC_HELP_STRING([--with-debug-flags], [Set compiler flags for debugging mode]) []$DEFAULT_FLAGS_DEBUG[],
dnl [if test "$withval" = "yes"
dnl then
dnl   CFLAGS_DEBUG="$DEFAULT_FLAGS_DEBUG"
dnl   CXXFLAGS_DEBUG="$DEFAULT_FLAGS_DEBUG"
dnl   BUILD_DEBUG="yes"
dnl elif test -n "$withval" && test "$withval" != "no"
dnl then
dnl   CFLAGS_DEBUG="$withval"
dnl   CXXFLAGS_DEBUG="$withval"
dnl   BUILD_DEBUG="yes"
dnl elif test "$withval" = "no"
dnl then
dnl   CFLAGS_DEBUG=""
dnl   CXXFLAGS_DEBUG=""
dnl   BUILD_DEBUG="no"
dnl else
dnl   CFLAGS_DEBUG="$DEFAULT_FLAGS_DEBUG"
dnl   CXXFLAGS_DEBUG="$DEFAULT_FLAGS_DEBUG"
dnl   BUILD_DEBUG="yes"
dnl fi], [CFLAGS_DEBUG=""
dnl CXXFLAGS_DEBUG=""
dnl BUILD_DEBUG="no"
dnl ])
dnl
dnl AC_ARG_WITH([optimization-flags], AC_HELP_STRING([--with-optimization-flags], [Set compiler optimization flags]) []$DEFAULT_FLAGS_OPT[],
dnl [if test -n "$withval" && test "$withval" != no && test "$withval" != "yes"
dnl then
dnl   CFLAGS_OPT="$withval"
dnl   CXXFLAGS_OPT="$withval"
dnl   BUILD_OPT="yes"
dnl elif test "$withval" = "yes"
dnl then
dnl   CFLAGS_OPT="$DEFAULT_FLAGS_OPT"
dnl   CXXFLAGS_OPT="$DEFAULT_FLAGS_OPT"
dnl   BUILD_OPT="yes"
dnl else
dnl   CFLAGS_OPT="$DEFAULT_FLAGS_OPT"
dnl   CXXFLAGS_OPT="$DEFAULT_FLAGS_OPT"
dnl   BUILD_OPT="yes"
dnl fi], [CFLAGS_OPT="$DEFAULT_FLAGS_OPT"
dnl CXXFLAGS_OPT="$DEFAULT_FLAGS_OPT"
dnl BUILD_OPT="yes"
dnl ])

dnl AC_SUBST([CFLAGS_DEBUG])
dnl AC_SUBST([CXXFLAGS_DEBUG])
dnl AC_SUBST([BUILD_DEBUG])
dnl
dnl AC_SUBST([CFLAGS_OPT])
dnl AC_SUBST([CXXFLAGS_OPT])
dnl AC_SUBST([BUILD_OPT])
dnl
dnl AC_ARG_ENABLE([werror], AC_HELP_STRING([--enable-werror], [Treat warnings as errors]),
dnl [werror="$withval"], [werror="no"])
dnl 

AM_CONDITIONAL([DEBUG], [test "$ac_cv_debug" = yes])
dnl AM_CONDITIONAL([WERROR], [test "$werror" = yes])

AC_SUBST([DEBUG], "$ac_cv_debug")

dnl AC_SUBST([WERROR], "$werror")
dnl AC_SUBST([LTVERSION],[`IFS=.;set -- $VERSION;IFS=:;echo "$*"`])

AC_SUBST([PKG_DIR])
AC_SUBST([relprefix],[${prefix#/}])
AC_SUBST([exec_prefix],[`eval "echo  \"$prefix\""`])
AC_SUBST([swroot],[`dirname "$prefix"`])
AC_SUBST([swrel],[${swroot#/}])
AC_SUBST([shlibdir],['${libdir}/sh'])

dnl Output build files
AC_CONFIG_FILES([Makefile
build/Makefile
build/cmake/Makefile
build/gnu/Makefile
doc/Makefile
lib/Makefile
lib/archive.sh
lib/buildsys.sh
lib/bytesize.sh
lib/distrib.sh
lib/fs.sh
lib/pkgmgr.sh
lib/pkg.sh
lib/port.sh
lib/service.sh
lib/shdoc.sh
lib/swsh.sh
lib/template.sh
lib/term.sh
lib/util.sh
lib/xtra.sh
lib/algorithm/Makefile
lib/algorithm/fmt.sh
lib/archive/Makefile
lib/archive/cpio.sh
lib/archive/deb.sh
lib/archive/jar.sh
lib/archive/rar.sh
lib/archive/sevenzip.sh
lib/archive/tar.sh
lib/archive/zip.sh
lib/buildsys/Makefile
lib/buildsys/autotools.sh
lib/buildsys/cmake.sh
lib/buildsys/make.sh
lib/buildsys/nobuild.sh
lib/buildsys/plmake.sh
lib/buildsys/pysetup.sh
lib/buildsys/autotools/Makefile
lib/class/Makefile
lib/class/cache.sh
lib/class/tempfile.sh
lib/code/Makefile
lib/code/bin.sh
lib/code/perl.sh
lib/code/ruby.sh
lib/compat/Makefile
lib/compat/declare.sh
lib/compression/Makefile
lib/compression/bzip2.sh
lib/compression/gzip.sh
lib/compression/lzma.sh
lib/daemons/Makefile
lib/daemons/crontab.sh
lib/daemons/httpd.sh
lib/daemons/named.sh
lib/data/Makefile
lib/data/config.sh
lib/data/envdir.sh
lib/data/html.sh
lib/data/info.sh
lib/data/list.sh
lib/data/obj.sh
lib/data/pdf.sh
lib/data/reg.sh
lib/data/text.sh
lib/data/tree.sh
lib/data/xml.sh
lib/database/Makefile
lib/database/mysql.bash
lib/database/mysql.sh
lib/devel/Makefile
lib/devel/compiler.sh
lib/devel/patch.sh
lib/devel/scan.sh
lib/devel/srcdist.sh
lib/devel/toolchain.sh
lib/devel/triplet.sh
lib/devel/toolchain/Makefile
lib/devel/toolchain/gcc.sh
lib/devel/toolchain/icl.sh
lib/distrib/Makefile
lib/distrib/centos.sh
lib/distrib/cygwin.sh
lib/distrib/debian.sh
lib/distrib/gentoo.sh
lib/distrib/lsb.sh
lib/distrib/mandrake.sh
lib/distrib/mingw.sh
lib/distrib/msys.sh
lib/distrib/redhat.sh
lib/distrib/slackware.sh
lib/distrib/ubuntu.sh
lib/djb/Makefile
lib/djb/buffer.sh
lib/fs/Makefile
lib/fs/dir.sh
lib/fs/file.sh
lib/fs/hier.sh
lib/fs/path.sh
lib/net/Makefile
lib/net/bridge.sh
lib/net/cidr.sh
lib/net/ethernet.sh
lib/net/http.sh
lib/net/if.sh
lib/net/inet.sh
lib/net/ip4.sh
lib/net/ssh.sh
lib/net/url.sh
lib/net/www.sh
lib/net/server/Makefile
lib/net/www/Makefile
lib/net/www/curl.sh
lib/pkgmgr/Makefile
lib/pkgmgr/dpkg.sh
lib/pkgmgr/rpm.sh
lib/pkgtool/Makefile
lib/pkgtool/apt.sh
lib/ports/Makefile
lib/ports/deb.sh
lib/service/Makefile
lib/service/runit.sh
lib/service/daemontools/Makefile
lib/service/runit/Makefile
lib/shell/Makefile
lib/shell/bash.sh
lib/shell/child.sh
lib/shell/cmd.sh
lib/shell/emit.sh
lib/shell/fn.sh
lib/shell/script.sh
lib/shell/trap.sh
lib/std/Makefile
lib/std/algorithm.sh
lib/std/array.sh
lib/std/ctype.sh
lib/std/escape.sh
lib/std/log.sh
lib/std/str.sh
lib/std/var.sh
lib/sys/Makefile
lib/sys/proc.sh
lib/term/Makefile
lib/term/color.sh
lib/term/screen.sh
lib/term/color/Makefile
lib/trace/Makefile
lib/trace/strace.sh
lib/unix/Makefile
lib/unix/group.sh
lib/unix/user.sh
lib/utils/Makefile
lib/utils/rcat.sh
lib/utils/rsed.sh
lib/utils/sed.sh
lib/vcs/Makefile
lib/vcs/svn.sh
lib/web/Makefile
lib/web/freshmeat.sh
lib/web/gnu.sh
lib/web/googlecode.sh
lib/web/kernel.sh
lib/web/rubyforge.sh
lib/web/sourceforge.sh
src/Makefile
src/require.sh
src/sw
src/utils/Makefile
src/utils/acbootstrap
src/utils/acbuild
src/utils/acrun
src/utils/fnsed
src/utils/rcat
src/utils/rsed
src/utils/tok/Makefile
src/utils/tok/tokgrep
src/utils/tok/toksubst
data/Makefile
test/Makefile
test/data/Makefile])

dnl AC_OUTPUT_FILES([Makefile
dnl build/Makefile
dnl build/cmake/Makefile
dnl build/gnu/Makefile
dnl doc/Makefile
dnl 
dnl data/Makefile
dnl test/Makefile
dnl test/data/Makefile])

AC_OUTPUT
