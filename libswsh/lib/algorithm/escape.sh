# $Id: escape.sh.in 557 2008-08-21 21:47:13Z enki $
#
# escape.sh: Functions which escape character data for use in different 
#            contexts.
#
# -------------------------------------------------------------------------
test $lib_escape_sh || {

# escape_noquote <string>
# 
# Escape for unquoted use within shell
# ---------------------------------------------------------------------------
escape_noquote()
{
  local s="$1"

  s=${s//"\\"/"\\\\"}
  s=${s//'$'/"\\"'$'}
  s=${s//'"'/'\"'}
  s=${s//"'"/"\\'"}
  s=${s//" "/"\\ "}
#  s=${s//"${IFS:0:1}"/"\\${IFS:0:1}"}
#  s=${s//"${IFS:1:1}"/"\\${IFS:1:1}"}
#  s=${s//"${IFS:2:1}"/"\\${IFS:2:1}"}

  echo "$s"
}

# escape_dquote <string>
# 
# Escape for double-quoted use within shell
# ---------------------------------------------------------------------------
escape_dquote()
{
  local s="$1"

  s=${s//"\\"/"\\\\"}
  s=${s//'$'/"\\"'$'}
  s=${s//'"'/'\"'}

  echo "$s"
}

# escape_squote <string>
#
# Escape for single-quoted use within shell
# ---------------------------------------------------------------------------
escape_squote()
{
  echo "$1" | sed "s,','\\\\'',g"
}

# escape_echo <string>
#
# Escape for use with echo -e
# ---------------------------------------------------------------------------
escape_echo()
{
  local s="$1"

  s=${s//$cr/"\\r"}
  s=${s//$nl/"\\n"}

  echo "$s"
}

# escape_sed <string>
#
# Escape for use within sed-script
# ---------------------------------------------------------------------------
escape_sed()
{
  echo "$1" | sed \
    -e ':lp; N; $! b lp' \
    -e 's,\\,\\\\,g' \
    -e 's,\n,\\n,g' \
    -e 's,\[,\\\[,g' \
    -e 's,\],\\\],g'
}

# --- eof ---------------------------------------------------------------------
lib_escape_sh=:;}
