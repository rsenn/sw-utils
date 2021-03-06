#!/bin/sh
# ---------------------------------------------------------------------------
MY_BASE=`basename "$0"`
MY_DIR=`dirname "$0"`

. ${srcdir:-$MY_DIR}/../lib/std/math.sh

# Test min()
# ---------------------------------------------------------------------------
test_std_math_min()
{
  # overflows! :-/
  #assertEquals 4295967295 "`min 634 2147717882 5 8564 3 4295967295 75`"
  assertEquals -1 "`min 634 2147717882 5 8564 3 -1 75`"

  # overflow!!
  #assertEquals -4295967295 "`min -634 2147717882 -2147717882 3245 4295967295 -4295967295 123`"
  assertEquals -37910 "`min 3245 -634  37626 -37910 3245`"
}

## Test max()
# ---------------------------------------------------------------------------
_test_std_math_max()
{
  assertEquals 4295967295 "`max 634 2147717882 5 7243 3 4295967295 75`" 
  assertEquals 4295967295 "`max -634 2147717882 -2147717882 3245 4295967295 -4295967295 123`"
}

# Test avg()
# ---------------------------------------------------------------------------
test_std_math_avg()
{
  assertEquals 4 "`avg 2 6 4 8 0`"
}

# Test log10()
# ---------------------------------------------------------------------------
test_std_math_log10()
{
  assertEquals 4 "`log10 99999`"
}

# Test log2()
# ---------------------------------------------------------------------------
test_std_math_log2()
{
  assertEquals 8 "`log2 511`"
  assertEquals 9 "`log2 512`"
}

# load and run shUnit2
# ---------------------------------------------------------------------------
if test -n "${ZSH_VERSION:-}"; then
  SHUNIT_PARENT=$0
  setopt shwordsplit
fi

. shunit2
