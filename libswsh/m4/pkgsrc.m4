AC_DEFUN([AM_CHECK_PKGSRC],
  [if test -d m4_default([$1], [/usr/pkg])/include -a -d m4_default([$1], [/usr/pkg])/lib; then
  pkgsrcincludedir=m4_default([$1], [/usr/pkg])/include
  pkgsrclibdir=m4_default([$1], [/usr/pkg])/lib

  CPPFLAGS="$CPPFLAGS -I${pkgsrcincludedir}"
  LDFLAGS="$LDFLAGS -L${pkgsrclibdir} -Wl,-rpath,${pkgsrclibdir}"
fi
])
