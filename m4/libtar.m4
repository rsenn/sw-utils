dnl AC_CHECK_LIBTAR([action-if-enabled-and-found], [action-if-enabled-and-not-found], [action-if-disabled])

dnl AC_DEFUN([AC_HELP_STRING], [])

AC_DEFUN([AC_CHECK_LIBTAR],
[
  # let the user enable/disable the usage of libtar
  AC_ARG_WITH([libtar],
    AC_HELP_STRING([--with-libtar=PATH],[search for libtar in PATH])
AC_HELP_STRING([--without-libtar],[disable use of libtar]),
    
[
  LIBTAR_ENABLE="yes"
  LIBTAR_DIR="$withval"
],
[
  LIBTAR_ENABLE="$withval"
  LIBTAR_DIR=""
])
  
  if test -z "$LIBTAR_ENABLE"; then
    LIBTAR_ENABLE="yes"
  fi
  
  if test -z "$LIBTAR_DIR"; then
    LIBTAR_DIR='${prefix}'
  fi
  
  # let the user specify a non-standard include path
  AC_ARG_WITH([libtar-include-dir],
    AC_HELP_STRING([--with-libtar-include-dir=PATH],[search for libtar headers in PATH]),
      [LIBTAR_INC_DIR="$withval"], [LIBTAR_INC_DIR="$LIBTAR_DIR/include"])
    
  # let the user specify a non-standard library path
  AC_ARG_WITH([libtar-lib-dir],
    AC_HELP_STRING([--with-libtar-lib-dir=PATH],[search for libtar libraries in PATH]),
      [LIBTAR_LIB_DIR="$withval"], [LIBTAR_LIB_DIR="$LIBTAR_DIR/lib"])

  # reset libtar dir if none was specified
  if test "$LIBTAR_DIR" = "yes"; then
    LIBTAR_ENABLE="yes"
    LIBTAR_DIR="$prefix"
  fi
  
  if test "$LIBTAR_DIR" = "no" || test -z "$LIBTAR_DIR"; then
    LIBTAR_ENABLE="no"
    LIBTAR_DIR='$(top_builddir)/libtar $(top_srcdir)/libtar $(top_builddir)/libtar/listhash $(top_srcdir)/libtar/listhash'
  fi
  
  # set include dir if specified
  if test -n "$LIBTAR_INC_DIR"; then
    LIBTAR_CFLAGS="-I$LIBTAR_INC_DIR"
  fi
  
  # set lib dir if specified
  if test -n "$LIBTAR_LIB_DIR"; then
    LIBTAR_LIBS="-L$LIBTAR_LIB_DIR -ltar"
    LIBTAR_SUBDIR=""
  else
    LIBTAR_LIBS="../libtar/lib/libtar.la"
    LIBTAR_SUBDIR="libtar"
  fi
  
  if test "$LIBTAR_ENABLE" = "yes" || test -z "$LIBTAR_ENABLE"; then
    # backup libs and cflags
    save_LIBS="$LIBS"
    save_CFLAGS="$CFLAGS"
  
    # set libtar libs and cflags
    CFLAGS="$LIBTAR_CFLAGS"
    LIBS="$LIBTAR_LIBS"
  
    # now check for the library
    AC_CHECK_LIB([tar], [tar_open], [LIBTAR_OK="yes"], [LIBTAR_OK="no"])
  
    # and now for the header
    AC_CHECK_HEADER([libtar.h], [LIBTAR_OK="yes"], [LIBTAR_OK="no"])
    
    if test "$LIBTAR_OK" = "yes"; then
      :; $1
    else
      :; $2
    fi
  
    # restore the flags
    LIBTAR_CFLAGS="$CFLAGS"
    LIBTAR_LIBS="$LIBS -ltar"
  
    CFLAGS="$save_CFLAGS"
    LIBS="$save_LIBS"
    
    AC_SUBST([LIBTAR_DIR])
    AC_SUBST([LIBTAR_INC_DIR])
    AC_SUBST([LIBTAR_LIB_DIR])
    AC_SUBST([LIBTAR_CFLAGS])
    AC_SUBST([LIBTAR_LIBS])
    AC_SUBST([LIBTAR_ENABLE])
    AC_SUBST([LIBTAR_SUBDIR])
  else
    :; $3
  fi])
