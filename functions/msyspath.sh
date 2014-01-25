msyspath()
{ 
 (MODE=msys
  while :; do
    case "$1" in 
      -w) MODE=win32; shift ;;
      -m) MODE=mixed; shift ;;
      *) break ;;
    esac
  done
  CMD=_msyspath
  if [ "$1" != "-" -a "$#" -gt 0 ]; then
    CMD="echo \"\$*\" |$CMD"
  fi
  eval "$CMD"
  exit $?)
}
msyspath()
{
 (add_to_script() { while [ "$1" ]; do SCRIPT="${SCRIPT:+$SCRIPT ;; }$1"; shift; done; }
 
  case $MODE in
    win*|mix*) add_to_script "s|^/sysdrive||" "s|^[\\\\/]\([A-Za-z0-9]\)\([\\\\/]\)|\\1:\\2|" ;;
    *) add_to_script "s|^\([A-Za-z0-9]\):|/\\1|" ;;
  esac
  case $MODE in
    win*|mix*)
       ROOT=$(mount | sed -n 's,\\,\\\\,g ;; s|\s\+on\s\+/\s\+.*||p')
      add_to_script "/^.:/!  s|^|$ROOT|"
    ;;
  esac
  case "$MODE" in
    win32) add_to_script "s|/|\\\\|g" ;;
    *) add_to_script "s|\\\\|/|g" ;;
  esac
  case "$MODE" in
    msys*) add_to_script "s|^/A/|/a/|" "s|^/B/|/b/|" "s|^/C/|/c/|" "s|^/D/|/d/|" "s|^/E/|/e/|" "s|^/F/|/f/|" "s|^/G/|/g/|" "s|^/H/|/h/|" "s|^/I/|/i/|" "s|^/J/|/j/|" "s|^/K/|/k/|" "s|^/L/|/l/|" "s|^/M/|/m/|" "s|^/N/|/n/|" "s|^/O/|/o/|" "s|^/P/|/p/|" "s|^/Q/|/q/|" "s|^/R/|/r/|" "s|^/S/|/s/|" "s|^/T/|/t/|" "s|^/U/|/u/|" "s|^/V/|/v/|" "s|^/W/|/w/|" "s|^/X/|/x/|" "s|^/Y/|/y/|" "s|^/Z/|/z/|" ;;
    win*)  add_to_script "s|^a:|A:|" "s|^b:|B:|" "s|^c:|C:|" "s|^d:|D:|" "s|^e:|E:|" "s|^f:|F:|" "s|^g:|G:|" "s|^h:|H:|" "s|^i:|I:|" "s|^j:|J:|" "s|^k:|K:|" "s|^l:|L:|" "s|^m:|M:|" "s|^n:|N:|" "s|^o:|O:|" "s|^p:|P:|" "s|^q:|Q:|" "s|^r:|R:|" "s|^s:|S:|" "s|^t:|T:|" "s|^u:|U:|" "s|^v:|V:|" "s|^w:|W:|" "s|^x:|X:|" "s|^y:|Y:|" "s|^z:|Z:|" ;;
  esac
 (sed "$SCRIPT" "$@")
 )
}
