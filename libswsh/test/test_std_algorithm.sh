#!/bin/sh
# ---------------------------------------------------------------------------
MY_BASE=`basename "$0"`
MY_DIR=`dirname "$0"`

. ../lib/std/algorithm.sh

# Test match()
# ---------------------------------------------------------------------------
test_std_algorithm_match()
{
  : BROKEN!
  #assertTrue 'match "*.sh" script1.sh script2.sh script3.sh'
  #assertTrue 'match "arg[0-9]" arg1 test abc'
}

# Test for_each
# ---------------------------------------------------------------------------
_test_std_algorithm_for_each()
{
  VALUE=
  
  for_each 'VALUE=$VALUE$1' a b c d e

  assertEqual "$VALUE" "abcde"

}

# Test each
# ---------------------------------------------------------------------------
test_std_algorithm_each()
{
  assertFalse 'each "test \"\$1\" = x" x x a x x'
  assertTrue 'each "test \"\$1\" = 0" 0 0 0 0 0 0 0'
  assertFalse 'each "test \"\$1\" = x" 1 2 3 4 5 6 7 8'
}


# Test some
# ---------------------------------------------------------------------------
test_std_algorithm_some()
{
  assertTrue 'some "test \"\$1\" = a" x x a x x'
  assertTrue 'some "test \"\$1\" = 0" 0 0 0 0 0 0 0'
  assertFalse 'some "test \"\$1\" = x" 1 2 3 4 5 6 7 8'
}



# load and run shUnit2
# ---------------------------------------------------------------------------
if test -n "${ZSH_VERSION:-}"; then
  SHUNIT_PARENT=$0
  setopt shwordsplit
fi

. shunit2
