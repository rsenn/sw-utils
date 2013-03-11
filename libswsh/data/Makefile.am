EXTRA_DIST = $(INPUT_FILES) $(DISTRIBUTED_FILES)
CLEANFILES = $(GENERATED_FILES) stamp-init
GENERATED_FILES = $(profile_DATA) $(bin_SCRIPTS)
DISTRIBUTED_FILES = $(NEWFILE_TEMPLATES)

noinst_DATA = \
  $(DISTRIBUTED_FILES)

INPUT_FILES = \
  $(NEWFILE_TEMPLATES) \
  Pkgtemplate \
	freshmeat_categories.txt

# The central data directory of our package
pkgdatadir = $(datadir)/libswsh
pkgdata_DATA = \
  freshmeat_categories.txt

# Templates for creating software-ports
templatedir = $(pkgdatadir)/templates
template_DATA = \
    Pkgtemplate

# Templates for the newfile(1) utility
NEWFILE_TEMPLATES = \
    tmpl@swsh \
    body.inc@swsh \
		shflags.inc@sh

if NEWFILE
newfiletemplatedir = $(datadir)/newfile/templates
newfiletemplate_DATA = $(NEWFILE_TEMPLATES)

install-newfiletemplateDATA: $(newfiletemplate_DATA)
	@$(NORMAL_INSTALL)
	test -z "$(newfiletemplatedir)" || $(mkdir_p) "$(DESTDIR)$(newfiletemplatedir)"
	@list='$(newfiletemplate_DATA)'; for p in $$list; do \
	  if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	  f=$(am__strip_dir) \
	  echo "sed -e 's:@pre""fix@:$(prefix):g' '$$d$$p' >'$(DESTDIR)$(newfiletemplatedir)/$$f'"; \
	  sed -e "s:@pre""fix@:$(prefix):g" "$$d$$p" >"$(DESTDIR)$(newfiletemplatedir)/$$f"; \
	done
endif

am__CONFIG_DISTCLEAN_FILES = Makefile.in
  
maintainer-clean-am: distclean-am maintainer-clean-generic
	-rm -f $(am__CONFIG_DISTCLEAN_FILES)
