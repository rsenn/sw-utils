ACLOCAL_AMFLAGS = -I build/gnu

SUBDIRS = lib src data doc test

DIST_SUBDIRS = build lib src data doc test

EXTRA_DIST = \
  $(BUILD_FILES) \
  $(pkgdoc_DATA) \
	.todo

BUILD_FILES = \
  setup.sh

pkgdocdir = ${docdir}

if DEVTODO
DEVTODO_OUTPUT = TODO
endif

pkgdoc_DATA = README AUTHORS $(DEVTODO_OUTPUT)

pkglib_shdir = ${libdir}/sh
pkglib_sh_DATA = 

if DEVTODO
$(srcdir)/.todo:
	[ ! -s "$@" ] && echo -e '<?xml version="1.0"?>\n<todo version="0.1.20">\n</todo>' >$@

TODO: $(srcdir)/.todo
	-devtodo -A --TODO --verbose --date-format "%Y%m%d" --database $<
endif

CONFIG_MAINTAINERCLEAN_FILES = \
  Makefile.in \
  $(DEVTODO_OUTPUT) \
  aclocal.m4 \
  configure \
  configure.ac \
	missing \
	config.guess \
	config.sub \
	install-sh

CONFIG_MAINTAINERCLEAN_DIRS = \
  $(distdir) \
	CMakeFiles

am__CONFIG_DISTCLEAN_FILES = \
  config.status \
	*.cache \
	*.log \
	*.lineno \
	aclocal.m4 \
	*.out \
	$(distdir).tar*
  
maintainer-clean-am: distclean-am maintainer-clean-generic
	-rm -f $(CONFIG_MAINTAINERCLEAN_FILES)
	-rm -rf $(CONFIG_MAINTAINERCLEAN_DIRS)
