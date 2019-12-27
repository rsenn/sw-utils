AC_DEFUN([AM_CHECK_DB], 
[AC_CHECK_LIB([db], [db_create], [DB_LIBS="-ldb"],
  AC_CHECK_LIB([db4], [db_create], [DB_LIBS="-ldb4"],
  AC_CHECK_LIB([db-4.8], [db_create], [DB_LIBS="-ldb-4.8"])))
AC_CHECK_HEADER([db4/db.h], [DB_CFLAGS="-I${pkgsrcincludedir:-$includedir}/db4"])
dnl
AC_SUBST([DB_CFLAGS])
AC_SUBST([DB_LIBS])
])

