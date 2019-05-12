#!/bin/sh
#
# 20190425

libtoolize --force --copy --automake 
aclocal -I .. -I ../build/gnu -I ../libswsh -I ../libswsh/build/gnu -I ../libswsh/m4 -I ../libtar -I ../libtar/autoconf -I ../m4
automake --copy --foreign --add-missing --add-missing
aclocal -I .. -I ../build/gnu -I ../libswsh -I ../libswsh/build/gnu -I ../libswsh/m4 -I ../libtar -I ../libtar/autoconf -I ../m4
autoconf
