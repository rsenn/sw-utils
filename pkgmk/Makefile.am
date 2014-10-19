SOMESCRIPTS = pkgmk pkgmk-deb

bin_SCRIPTS = $(SOMESCRIPTS)

sysconf_DATA = pkgmk.conf
pkgmksysconfdir = $(sysconfdir)/pkgmk.d
pkgmkconfsysconfdir = $(sysconfdir)/pkgmk.conf.d

pkgmklibdir = $(libdir)/pkgmk
pkgmklib_SCRIPTS = pkgmk-buildcmd

bashcompdir = $(datadir)/bash
bashcomp_DATA = pkgmk.comp

pkgmkconfsysconf_DATA = \
    layout.conf \
    mirrors.conf \
    toolchain.conf

EXTRA_DIST = \
    pkgmk.in \
    pkgmk.8.in \
    pkgmk.conf.in \
    pkgmk-deb.in \
    libtool.conf.in \
    layout.conf.in \
    mirrors.conf.in \
    toolchain.conf.in \
    pkgmk-buildcmd.in \
    pkgmk.comp.in

DISTCLEANFILES = \
    pkgmk.8 \
    pkgmk \
    pkgmk-deb \
    pkgmk.conf \
    $(pkgmkconfsysconf_DATA)

man8_MANS = pkgmk.8

TRACE_BINARIES = \
  cc c++ gcc g++ lcc icl cl icl.exe cl.exe \
  install cp mv rm ln touch mk$(NULL)dir \
  bzip2 bunzip2 bzcat \
  gzip gunzip zcat \
  tar zip unzip rar unrar \
  make gmake pmake smake \
  pkg-config \
  ar as dlltool ld nm objdump objcopy ranlib readelf size strings strip windres
  

#  cat cp head ln mv rm tail touch \
#  grep egrep pgrep sed \
#

install-data-hook:
	for name in $(TRACE_BINARIES); do \
    cd $(DESTDIR)$(pkgmklibdir) && ln -sf pkgmk-buildcmd $$name; \
	done
