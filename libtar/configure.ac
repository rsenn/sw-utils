dnl ### Normal initialization. ######################################
AC_INIT([libtar],[1.2.11])
AC_CONFIG_AUX_DIR([autoconf])
AM_INIT_AUTOMAKE
AC_PREREQ([2.72])
AC_CONFIG_HEADERS([config.h])
AC_COPYRIGHT([[
Copyright (c) 1998-2003 University of Illinois Board of Trustees
Copyright (c) 1998-2003 Mark D. Roth
All rights reserved.
]])
AC_CONFIG_SRCDIR([lib/libtar.h])
dnl ENCAP_PKG([], [postinstall-encap])

dnl ### Load subdirectory modules. ##################################
dnl PSG_MODULE([compat])
dnl PSG_MODULE([listhash], [libtar])

dnl ### Set some option defaults. ###################################
if test -z "$CFLAGS"; then
  CFLAGS="-O"
fi
MKDIR="mkdir -p -m 755"
AC_SUBST([MKDIR])

dnl ### Check for compiler et al. ###################################
AC_PROG_CC
AC_PROG_RANLIB
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
LT_INIT

dnl ### Compiler characteristics. ##################################
AC_C_CONST

dnl ### Checks for header files. ###################################
m4_warn([obsolete],
[The preprocessor macro 'STDC_HEADERS' is obsolete.
  Except in unusual embedded environments, you can safely include all
  C89 headers unconditionally.])dnl
# Autoupdate added the next two lines to ensure that your configure
# script's behavior did not change.  They are probably safe to remove.
AC_CHECK_INCLUDES_DEFAULT
AC_PROG_EGREP

AC_CHECK_HEADERS([unistd.h sys/param.h])
AC_HEADER_MAJOR
AC_TYPE_MODE_T
AC_TYPE_OFF_T
AC_TYPE_SIZE_T
AC_TYPE_UID_T

m4_include([compat/module.ac])
m4_include([listhash/module.ac])

dnl ### Check for needed functions. ################################
COMPAT_FUNC_BASENAME
COMPAT_FUNC_DIRNAME
COMPAT_FUNC_FNMATCH
AC_CHECK_FUNCS([lchown glob vsnprintf])
COMPAT_FUNC_MAKEDEV
COMPAT_FUNC_SNPRINTF
COMPAT_FUNC_STRDUP
AC_FUNC_STRFTIME
COMPAT_FUNC_STRLCPY
COMPAT_FUNC_STRMODE
COMPAT_FUNC_STRSEP

dnl ### Check for libraries. #######################################
dnl AC_ARG_WITH([zlib],
dnl   [  --without-zlib          Use external gzip binary instead of zlib],
dnl   [],
dnl   [with_zlib=yes])
dnl if test "$with_zlib" = "yes"; then
dnl   AC_CHECK_LIB([z], [gzread])
dnl fi

AC_CHECK_ZLIB

dnl ### Create output files. #######################################
AC_CONFIG_FILES([Makefile
autoconf/Makefile
compat/Makefile
lib/Makefile
libtar/Makefile
doc/Makefile
listhash/Makefile])

AC_OUTPUT

