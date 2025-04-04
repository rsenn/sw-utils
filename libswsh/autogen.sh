#!/bin/sh
#
# 20250223


aclocal -I m4
automake --copy --foreign --add-missing
aclocal -I m4
autoconf
