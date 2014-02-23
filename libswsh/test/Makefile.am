SUBDIRS = data

check_SCRIPTS = \
	test_std_algorithm.sh \
	test_std_math.sh \
	test_std_var.sh \
	test_compat_declare.sh \
	test_util.sh \
	test_data_xml.sh \
	test_web_freshmeat.sh 

TESTS_OPTIONS = -e
TESTS_ENVIRONMENT = SHELLS="$(SHELLS)" ECHO_N="@ECHO_N@" srcdir="$(srcdir)" builddir="." shlibdir="../lib" $(srcdir)/run-test-suite $(TESTS_OPTIONS)
TESTS = $(check_SCRIPTS)

EXTRA_DIST = run-test-suite $(check_SCRIPTS)

CONFIG_MAINTAINERCLEAN_FILES = Makefile.in

maintainer-clean-am: distclean-am maintainer-clean-generic
	-rm -f $(CONFIG_MAINTAINERCLEAN_FILES)
