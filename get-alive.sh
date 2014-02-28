#!/bin/bash

IFS="
"

FROM="${1-*.alive*}"
shift

IFS="|"
ALIVE="\\[ALIVE\\]"
WHAT="${*:-$ALIVE}"
IFS="
"

sed -n \
  -e "s,.*\[\(.*\)\].*\(http://.*\),\2 \[\1\],p" $FROM \
  | egrep -i "($WHAT)" \
  | sed \
      -e 's,.\[[0-9]\+m,,g' \
  | cat | #: awk '{ print $1 }'  \
    sed -e 's,\s\+(,    \t,' -e 's,)\s\+\[,    \t\[,' |
    sort -k2 | 
  if [ -n "$*" ]; then
    cut -f1
  else
    cat
  fi