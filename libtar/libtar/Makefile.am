bin_PROGRAMS = libtar

AM_CPPFLAGS = \
  -I$(srcdir)/.. \
  -I$(srcdir)/../compat \
  -I.. \
  -I$(top_srcdir)/lib \
  -I../listhash \
  -I$(top_srcdir)/listhash

LDADD = -L../lib -ltar

libtar_SOURCES = libtar.c
libtar_LIBS = $(LIBS)
