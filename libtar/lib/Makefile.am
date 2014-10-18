noinst_LTLIBRARIES = libtar.la

AM_CPPFLAGS = \
  -I$(srcdir) \
  -I$(builddir) \
  -I$(srcdir)/.. \
  -I$(builddir)/.. \
  -I$(top_srcdir)/compat \
  -I$(top_srcdir)/listhash \
  -I$(top_builddir)/listhash

libtar_la_SOURCES = \
    append.c \
    block.c \
    decode.c \
    encode.c \
    extract.c \
    handle.c \
    internal.h \
    libtar.h \
    output.c \
    util.c \
    wrapper.c

libtar_la_LDFLAGS = -rpath $(libdir) -no-undefined -version-number 1:2:11
libtar_la_LIBADD = ../listhash/liblisthash.la ../compat/libcompat.la $(ZLIB_LIBS)
