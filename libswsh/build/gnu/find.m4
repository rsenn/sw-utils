dnl
dnl AM_FIND_PROG([VARIABLE-NAME],[PROGRAM-NAME],[VALUE-IF-FOUND])
dnl
dnl Find an executable file (a program) in $PATH
dnl
AC_DEFUN([AM_FIND_PROG],
[_AC_CHECK_PATH([$1],[$2],[m4_ifval([$3],[$3],[$2])])
$1=$ac_cv_file_$1
AM_CONDITIONAL([$1],[test -n "$ac_cv_file_$1"])
AC_SUBST([$1])
])dnl

dnl
dnl AM_FIND_PATH([VARIABLE-NAME],[FILENAME],[VALUE-IF-FOUND])
dnl
dnl Find a (possibly non-executable) file in $PATH
dnl
AC_DEFUN([AM_FIND_PATH],
[_AC_CHECK_PATH([$1],[$2],[m4_ifval([$3],[$3],[$2])])
AM_CONDITIONAL([$1],[test -n "$ac_cv_file_$1"])
AC_SUBST([$1], [$ac_cv_file_$1])
])



# _AC_CHECK_PATH(VARIABLE, FILE-TO-CHECK-FOR,
#               [VALUE-IF-FOUND], [VALUE-IF-NOT-FOUND],
#               [PATH], [REJECT])
# -----------------------------------------------------
AC_DEFUN([_AC_CHECK_PATH],
[# Extract the first word of "$2", so it can be a file name with args.
set dummy $2; ac_word=$[2]
AC_MSG_CHECKING([for $ac_word])
AC_CACHE_VAL(ac_cv_file_$1,
[if test -n "$$1"; then
  ac_cv_file_$1="$$1" # Let the user override the test.
else
m4_ifvaln([$6],
[  ac_file_rejected=no])dnl
_AS_PATH_WALK([$5],
[if test -f "$as_dir/$ac_word"; then
m4_ifvaln([$6],
[    if test "$as_dir/$ac_word" = "$6"; then
       ac_file_rejected=yes
       continue
     fi])dnl
    ac_cv_file_$1="$3"
    _AS_ECHO_LOG([found $as_dir/$ac_word])
    break
  fi])
m4_ifvaln([$6],
[if test $ac_file_rejected = yes; then
  # We found a bogon in the path, so make sure we never use it.
  set dummy $ac_cv_file_$1
  shift
  if test $[@%:@] != 0; then
    # We chose a different compiler from the bogus one.
    # However, it has the same basename, so the bogon will be chosen
    # first if we set $1 to just the basename; use the full file name.
    shift
    ac_cv_file_$1="$as_dir/$ac_word${1+' '}$[@]"
m4_if([$2], [$4],
[  else
    # Default is a loser.
    AC_MSG_ERROR([$1=$6 unacceptable, but no other $4 found in dnl
m4_default([$5], [\$PATH])])
])dnl
  fi
fi])dnl
dnl If no 4th arg is given, leave the cache variable unset,
dnl so AC_CHECK_PATHS will keep looking.
m4_ifvaln([$4],
[  test -z "$ac_cv_file_$1" && ac_cv_file_$1="$4"])dnl
fi])dnl
$1=$ac_cv_file_$1
if test -n "$$1"; then
  AC_MSG_RESULT([$$1])
else
  AC_MSG_RESULT([no])
fi
])# _AC_CHECK_PATH


# AC_CHECK_PATH(VARIABLE, FILE-TO-CHECK-FOR,
#               [VALUE-IF-FOUND], [VALUE-IF-NOT-FOUND],
#               [PATH], [REJECT])
# -----------------------------------------------------
AC_DEFUN([AC_CHECK_PATH],
[_AC_CHECK_PATH($@)
AC_SUBST([$1])dnl
])

