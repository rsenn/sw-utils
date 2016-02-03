#!/bin/sh
#
# src.sh: functions for operating on source files and trees.
#
# $Id: src.in 425 2006-06-16 13:32:51Z roman $
# -------------------------------------------------------------------------
test $lib_src_sh || {

src_c_masks="*.c *.h"                                         # masks for C source
src_cpp_masks="*.cpp *.cpp *.cc *.C *.h *.hpp *.hxx *.hh *.H" # masks for C++ source

# -------------------------------------------------------------------------

# --- eof ---------------------------------------------------------------------
lib_src_sh=:;}
