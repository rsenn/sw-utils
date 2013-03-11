#!/bin/sh
#
# template.sh: Template for a libswsh module
#
# $Id: list.in 654 2007-02-26 13:07:53Z roman $
# -------------------------------------------------------------------------
@DEBUG_FALSE@test $lib_template_sh || {

# Declare and initialize static variables
# -------------------------------------------------------------------------
template_var1=

# template_example <arg1> [arg2]
#
# Example function.
# -------------------------------------------------------------------------
template_example()
{
  local IFS="
"
  echo "Dummy function"
}

# --- EOF -----------------------------------------------------------------
@DEBUG_FALSE@lib_template_sh=:;}
