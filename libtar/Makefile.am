ACLOCAL_AMFLAGS = -I autoconf

SUBDIRS = autoconf doc compat listhash lib libtar

#include_HEADERS = tar.h
noinst_HEADERS = tar.h

pkgdocdir = ${docdir}/${PACKAGE_NAME}

pkgdoc_DATA = README COPYRIGHT ChangeLog ChangeLog-1.0.x TODO

EXTRA_DIST = \
  $(pkgdoc_DATA) \
	autogen.sh
