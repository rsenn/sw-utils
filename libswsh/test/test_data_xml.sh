#!/bin/sh
# ---------------------------------------------------------------------------
MY_BASE=`basename "$0"`
MY_DIR=`dirname "$0"`

. ${builddir-$MY_DIR}/../lib/data/xml.sh

# Test wheter xml_getvalue() correctly handles 2 matching tags on the same line
# ---------------------------------------------------------------------------
test_xml_getvalue_2tags()
{
  xml='<tag>value1</tag><tag>value2</tag>'
  inner='value1
value2'
  rslt=`echo "$xml" | xml_getvalue 'tag'`
  
  assertEquals "$inner" "$rslt"
}

# Test whether matches including tag attributes work
# ---------------------------------------------------------------------------
test_xml_getvalue_match_attr()
{
  xml='<a href="http://dummy.com/">dummy text</a>'
  text='dummy text'
  rslt=`echo "$xml" | xml_getvalue 'a href=".*"'`

  assertEquals "$text" "$rslt"
}

# load and run shUnit2
# ---------------------------------------------------------------------------
if test -n "${ZSH_VERSION:-}"; then
  SHUNIT_PARENT=$0
  setopt shwordsplit
fi

. shunit2
