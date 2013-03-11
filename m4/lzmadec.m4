dnl AC_CHECK_LZMADEC([action-if-enabled-and-found], [action-if-enabled-and-not-found], [action-if-disabled])

dnl AC_DEFUN([AC_HELP_STRING], [])

AC_DEFUN([AC_CHECK_LZMADEC],
[
  # let the user enable/disable the usage of lzmadec
  AC_ARG_WITH([lzmadec],
    AC_HELP_STRING([--with-lzmadec=PATH],[search for lzmadec in PATH])
AC_HELP_STRING([--without-lzmadec],[disable use of lzmadec]),
    
[
  LZMADEC_ENABLE="yes"
  LZMADEC_DIR="$withval"
],
[
  LZMADEC_ENABLE="$withval"
  LZMADEC_DIR=""
])
  
  if test -z "$LZMADEC_ENABLE"; then
    LZMADEC_ENABLE="yes"
  fi
  
  if test -z "$LZMADEC_DIR"; then
    LZMADEC_DIR='${prefix}'
  fi
  
  # let the user specify a non-standard include path
  AC_ARG_WITH([lzmadec-include-dir],
    AC_HELP_STRING([--with-lzmadec-include-dir=PATH],[search for lzmadec headers in PATH]),
      [LZMADEC_INC_DIR="$withval"], [LZMADEC_INC_DIR="$LZMADEC_DIR/include"])
    
  # let the user specify a non-standard library path
  AC_ARG_WITH([lzmadec-lib-dir],
    AC_HELP_STRING([--with-lzmadec-lib-dir=PATH],[search for lzmadec libraries in PATH]),
      [LZMADEC_LIB_DIR="$withval"], [LZMADEC_LIB_DIR="$LZMADEC_DIR/lib"])

  # reset lzmadec dir if none was specified
  if test "$LZMADEC_DIR" = "yes"; then
    LZMADEC_ENABLE="yes"
    LZMADEC_DIR="$prefix"
  fi
  
  if test "$LZMADEC_DIR" = "no" || test -z "$LZMADEC_DIR"; then
    LZMADEC_ENABLE="no"
    LZMADEC_DIR='$(top_builddir)/lzmadec'
  fi
  
  # set include dir if specified
  if test -n "$LZMADEC_INC_DIR"; then
    LZMADEC_CFLAGS="-I$LZMADEC_INC_DIR"
  fi
  
  # set lib dir if specified
  if test -n "$LZMADEC_LIB_DIR"; then
    LZMADEC_LIBS="-L$LZMADEC_LIB_DIR -ltar"
    LZMADEC_SUBDIR=""
  else
    LZMADEC_LIBS="../lzmadec/lib/lzmadec.la"
    LZMADEC_SUBDIR="lzmadec"
  fi
  
  if test "$LZMADEC_ENABLE" = "yes" || test -z "$LZMADEC_ENABLE"; then
    # backup libs and cflags
    save_LIBS="$LIBS"
    save_CFLAGS="$CFLAGS"
  
    # set lzmadec libs and cflags
    CFLAGS="$LZMADEC_CFLAGS"
    LIBS="$LZMADEC_LIBS"
  
    # now check for the library
    AC_CHECK_LIB([lzmadec], [lzmadec_open], [LZMADEC_OK="yes"], [LZMADEC_OK="no"])
  
    # and now for the header
    AC_CHECK_HEADER([lzmadec.h], [LZMADEC_OK="yes"], [LZMADEC_OK="no"])
    
    if test "$LZMADEC_OK" = "yes"; then
      :; $1
    else
      :; $2
    fi
  
    # restore the flags
    LZMADEC_CFLAGS="$CFLAGS"
    LZMADEC_LIBS="$LIBS -llzmadec"
  
    CFLAGS="$save_CFLAGS"
    LIBS="$save_LIBS"
    
    AC_SUBST([LZMADEC_DIR])
    AC_SUBST([LZMADEC_INC_DIR])
    AC_SUBST([LZMADEC_LIB_DIR])
    AC_SUBST([LZMADEC_CFLAGS])
    AC_SUBST([LZMADEC_LIBS])
    AC_SUBST([LZMADEC_ENABLE])
    AC_SUBST([LZMADEC_SUBDIR])
  else
    :; $3
  fi])
