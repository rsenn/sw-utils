#!/bin/sh
# ---------------------------------------------------------------------------
MY_BASE=`basename "$0"`
MY_DIR=`dirname "$0"`

. ../lib/std/var.sh

# Test is_var <name>
# ---------------------------------------------------------------------------
test_std_is_var()
{
  name="_a_legal_variable1234"; is_var "$name"; assertTrue "$name" $?
  name="an-illegal-variable1234"; is_var "$name"; assertFalse "$name" $?
  name="0_legality"; is_var "$name"; assertFalse "$name" $?
  name="_"; is_var "$name"; assertTrue "$name" $?

  unset -v name
}

# Test var_set <name> [value...]
# ---------------------------------------------------------------------------
test_std_var_set()
{
  IFS=" "
  var_set 'testvar' a b c
  assertEquals "$testvar" "a b c"

  IFS="
"
  var_set 'vartest' 1 2 3
  assertEquals "$vartest" "1
2
3"
}

# Test var_unset <name(s)...>
# ---------------------------------------------------------------------------
_test_std_var_set()
{
  a=1 b=2 c=3

  var_unset a c

  assertEquals "${a-unset}" "unset"
  assertEquals "$b" 2
  assertEquals "${c-unset}" "unset"
}

# load and run shUnit2
# ---------------------------------------------------------------------------
if test -n "${ZSH_VERSION:-}"; then
  SHUNIT_PARENT=$0
  setopt shwordsplit
fi

. shunit2
