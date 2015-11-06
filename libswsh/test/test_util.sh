#!/bin/sh
# ---------------------------------------------------------------------------
MY_BASE=`basename "$0"`
MY_DIR=`dirname "$0"`

. ../lib/std/var.sh
. ../lib/util.sh

# Test pushv()
# ---------------------------------------------------------------------------
testPushv_simple()
{
  expected="a:b-c"  
  vector="a"
  
  IFS=":" pushv vector "b"
  IFS="-" pushv vector "c"
  
  assertEquals "$expected" "$vector"
}

# load and run shUnit2
# ---------------------------------------------------------------------------
if test -n "${ZSH_VERSION:-}"; then
  SHUNIT_PARENT=$0
  setopt shwordsplit
fi

. shunit2
