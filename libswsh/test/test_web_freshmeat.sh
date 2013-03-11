#!/bin/sh
# ---------------------------------------------------------------------------
MY_BASE=`basename "$0"`
MY_DIR=`dirname "$0"`

. ${builddir-$MY_DIR}/../lib/util.sh
. ${builddir-$MY_DIR}/../lib/web/freshmeat.sh

# Test pushv()
# ---------------------------------------------------------------------------
test_freshmeat_xml()
{
  xmldata=`cat "${srcdir-$MY_DIR}/data/freshmeat-x11.xml"`
 
  assertEquals "$xmldata" "`freshmeat_xml "$xmldata"`"
}

# load and run shUnit2
# ---------------------------------------------------------------------------
if [ -n "${ZSH_VERSION:-}" ]; then
  SHUNIT_PARENT=$0
  setopt shwordsplit
fi

. shunit2
