EXTRA_DIST = \
  configure.ac.in \
	autogen.sh \
	autocfg.sh \
	install-sh

CONFIG_MAINTAINERCLEAN_FILES = \
  Makefile.in \
  missing \
	config.guess \
	config.sub \
	install-sh

maintainer-clean-am: distclean-am maintainer-clean-generic
	-rm -f $(CONFIG_MAINTAINERCLEAN_FILES)
