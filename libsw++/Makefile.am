if SYSTEM_LIBTAR
INCLUDES = -I$(top_builddir) $(LIBTAR_CFLAGS) $(BZLIB_CFLAGS) $(ZLIB_CFLAGS)
else
INCLUDES = \
  -I$(top_builddir) \
  -I$(top_srcdir)/libtar \
  -I$(top_srcdir)/libtar/lib \
  -I$(top_builddir)/libtar/lib \
  -I$(top_builddir)/libtar/listhash \
	$(DB_CFLAGS) \
  $(BZLIB_CFLAGS) \
	$(ZLIB_CFLAGS)
endif

DEFS = \
	-DDEBUG \
	-DSHELL=\"$(SHELL)\" \
	-DPKG_DIR=\"$(PKG_DIR)\" \
	-DLIBDIR=\"$(libdir)\" \
	-DSBINDIR=\"$(sbindir)\" \
	-DSYSCONFDIR=\"$(sysconfdir)\"

lib_LTLIBRARIES = libsw++.la

libsw___la_LDFLAGS = -no-undefined -version-number $(LTVERSION)

if SYSTEM_LIBTAR
libsw___la_LIBADD = $(LIBTAR_LIBS) $(BZLIB_LIBS) $(DB_LIBS) $(LIBS)
else
libsw___la_LIBADD = -L$(top_builddir)/libtar/lib -ltar $(BZLIB_LIBS) $(DB_LIBS) $(LIBS)
endif

#$(ZLIB_LIBS)
libsw___la_SOURCES = \
	pkgadd.cpp \
	pkgadd.hpp \
	pkgdb.hpp \
	pkgdb_text.cpp \
	pkgdb_text.hpp \
	pkgdb_dbm.cpp \
	pkgdb_dbm.hpp \
	pkginfo.cpp \
	pkginfo.hpp \
	pkgrm.cpp \
	pkgrm.hpp \
	pkgtool.cpp \
	pkgtool.hpp
