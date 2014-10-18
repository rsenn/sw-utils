ACLOCAL_AMFLAGS = -I build/gnu -I m4
AUTOMAKE_AMFLAGS = --add-missing --foreign --copy

# programs that need to be compiled
bin_PROGRAMS = pkgadd pkgadd.static 

sourcesdir = ${prefix}/src
distfilesdir = ${sourcesdir}/distfiles

if SYSTEM_LIBTAR
SUBDIRS = m4 libsw++ libswsh pkgbackup swconfig pkgmk svadm scripts #objconv
else
SUBDIRS = m4 libtar libsw++ libswsh pkgbackup swconfig pkgmk svadm scripts #objconv
endif

DIST_SUBDIRS = m4 libtar libsw++ libswsh pkgbackup swconfig pkgmk svadm scripts #objconv

AM_CPPFLAGS = -DDEBUG -DSHELL=\"$(SHELL)\" -DSYSCONFDIR=\"$(sysconfdir)\"

# scripts
SOMESCRIPTS = rejmerge 
bin_SCRIPTS = $(SOMESCRIPTS) $(target)-wrap

# manual pages which are generated from their corresponding .in files
man8_MANS = pkgadd.8 pkgrm.8 pkginfo.8 rejmerge.8

# config files which will be installed
sysconf_DATA = pkgadd.conf rejmerge.conf 

pkgdatadir = $(datadir)/sw-utils
pkgdata_DATA =

pkgsysconfdir = $(sysconfdir)/sw
pkgmksysconfdir = $(sysconfdir)/pkgmk.d

pkgmksysconf_DATA = 

EXTRA_DIST = \
  pkgadd.8.in \
  pkgrm.8.in \
  pkginfo.8.in \
  rejmerge.8.in \
  $(sysconf_DATA) \
  rejmerge.in \
  wrap.in \
  $(EXTRA_DIST_FILES)

pkgadd_SOURCES = main.cpp
#                 pkgtool.cpp \
#                 pkgadd.cpp \
#                 pkgrm.cpp \
#                 pkginfo.cpp \
#                 pkgadd.h \
#                 pkginfo.h \
#                 pkgrm.h \
#                 pkgtool.h

#pkgadd_static_SOURCES = $(pkgadd_SOURCES)

DISTCLEANFILES = \
  rejmerge \
  pkgadd.8 \
  pkgrm.8 \
  pkginfo.8 \
  rejmerge.8 \
  unused-libs \
  check-libs \
  $(target)-wrap

if SYSTEM_LIBTAR
pkgadd_LDADD = libsw++/libsw++.la $(LIBTAR_LIBS) $(BZLIB_LIBS) -lz
else
pkgadd_LDADD = libsw++/libsw++.la libtar/lib/libtar.la $(BZLIB_LIBS) -lz
endif
#$(LIBTAR_LIBS) $(BZLIB_LIBS) $(ZLIB_LIBS)

pkgadd_static_SOURCES = $(pkgadd_SOURCES)
pkgadd_static_LDADD = $(pkgadd_LDADD)
pkgadd_static_LDFLAGS = -all-static

DEFS = -DPKG_DIR=\"$(PKG_DIR)\" \
       -DSYSCONFDIR=\"$(sysconfdir)\" \
       -DSBINDIR=\"$(sbindir)\" \
       -DLIBDIR=\"$(libdir)\"

if SYSTEM_LIBTAR
INCLUDES = -I$(top_builddir) -I$(top_srcdir) -I$(top_srcdir)/libsw++ $(LIBTAR_CFLAGS)
else
INCLUDES = \
  -I$(top_builddir) \
  -I$(top_srcdir) \
  -I$(top_srcdir)/libsw++ \
  -I$(top_srcdir)/libtar \
  -I$(top_builddir)/libtar \
  -I$(top_srcdir)/libtar/lib \
  -I$(top_builddir)/libtar/lib \
  -I$(top_srcdir)/libtar/listhash \
  -I$(top_builddir)/libtar/listhash
endif

install-exec-hook:
	rm -f $(DESTDIR)$(bindir)/pkgrm
	$(LN_S) pkgadd $(DESTDIR)$(bindir)/pkgrm
	rm -f $(DESTDIR)$(bindir)/pkginfo
	$(LN_S) pkgadd $(DESTDIR)$(bindir)/pkginfo

install-data-hook:
	$(mkinstalldirs) $(DESTDIR)$(PKG_DIR)
	$(mkinstalldirs) $(DESTDIR)$(distfilesdir)
	$(mkdir_p) $(DESTDIR)$(PKG_DIR)/rejected

uninstall-hook:
	$(RM) $(DESTDIR)$(PKG_DIR)/db

#if DEVTODO
#$(srcdir)/.todo:
#        [ ! -s "$@" ] && echo -e '<?xml version="1.0"?>\n<todo version="0.1.20">\n</todo>' >$@
#
#TODO: | $(srcdir)/.todo
#        -devtodo -A --TODO --verbose --date-format "%Y%m%d" --database $<
#endif

CONFIG_DISTCLEAN_FILES = \
  config.status config.cache config.log \
  configure.lineno config.status.lineno \
  Makefile Makefile.in

am__CONFIG_DISTCLEAN_FILES = config.log config.status
  
EXTRA_DIST_FILES = \
  configure \
  Makefile.in \
  depcomp \
  aclocal.m4 \
	cfg.sh

BUILD_DIST_FILES = \
  build/Makefile.in \
  build/debian/changelog \
  build/debian/control \
  build/debian/rules \
  build/gnu/autogen.sh \
  build/gnu/ltmain.sh \
	build/gnu/libtool.m4 \
  build/gnu/ltoptions.m4 \
  build/gnu/ltsugar.m4 \
  build/gnu/ltversion.m4 \
  build/gnu/lt~obsolete.m4 \
  build/gnu/install-sh \
  build/gnu/config.guess \
  build/gnu/config.sub \
  build/gnu/depcomp \
  build/gnu/missing \
	m4/libtar.m4 \
	m4/zlib.m4 \
	m4/bzlib.m4 \
	m4/lzmadec.m4 \
	m4/db.m4

dist-hook:
	rm -rf $(distdir)/build
	mkdir -p $(distdir)/build/debian
	mkdir -p $(distdir)/build/gnu
	@list='$(BUILD_DIST_FILES)'; for p in $$list; do \
		cp $(srcdir)/$$p $(distdir)/$$p; \
	done
