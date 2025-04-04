#!/bin/sh
#
# 20250223


aclocal -I autoconf/
autoheader
automake --copy --foreign --foreign --add-missing
aclocal -I autoconf/
autoconf
