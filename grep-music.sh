#!/bin/sh

PARTIAL_EXPR="(\.part|\.!..|)"
while :; do
  case "$1" in
    -c | --complete) PARTIAL_EXPR="" ; shift ;;
    *) break ;;
  esac
done

EXTS="mp3 ogg flac mpc m4a m4b wma wav aif aiff voc"

exec grep -i -E "$@" "\\.($(IFS='| '; set -- $EXTS;  echo "$*"))${PARTIAL_EXPR}\$" 