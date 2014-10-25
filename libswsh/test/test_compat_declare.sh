#!/bin/sh
# ---------------------------------------------------------------------------

MY_BASE=`basename "$0"`
MY_DIR=`dirname "$0"`

. ../lib/compat/declare.sh

# Test declare()
# ---------------------------------------------------------------------------
test_declare_Simple()
{
  declare var1="this is a string" var2=x=123 var3="a b = d"

  assertEquals "this is a string" "$var1"
  assertEquals "x=123" "$var2"
  assertEquals "a b = d" "$var3"
}

# load and run shUnit2
# ---------------------------------------------------------------------------
if test -n "${ZSH_VERSION:-}"; then
  SHUNIT_PARENT=$0
  setopt shwordsplit
fi

. shunit2
