#!/bin/bash

pmods='$MEDIAPATH/pmagic*/pmodules'

set -o vi

IFS="
"

[ "$HOSTNAME" = MSYS ] && OS="Msys"
drives_upper=$'A\nB\nC\nD\nE\nF\nG\nH\nI\nJ\nK\nL\nM\nN\nO\nP\nQ\nR\nS\nT\nU\nV\nW\nX\nY\nZ'
drives_lower=$'a\nb\nc\nd\ne\nf\ng\nh\ni\nj\nk\nl\nm\nn\no\np\nq\nr\ns\nt\nu\nv\nw\nx\ny\nz'

ansi_cyan='\[\033[1;36m\]' ansi_red='\[\033[1;31m\]' ansi_green='\[\033[1;32m\]' ansi_yellow='\[\033[1;33m\]' ansi_blue='\[\033[1;34m\]' ansi_magenta='\[\033[1;35m\]' ansi_gray='\[\033[0;37m\]' ansi_bold='\[\033[1m\]' ansi_none='\[\033[0m\]'

#PATH="/sbin:/usr/bin:/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/libexec:/usr/local/libexec"
#LANG=C
#LANGUAGE="en_US.ISO-8859-1"
LANGUAGE=C
#[ -d /usr/share/locale/en_US ] && LANGUAGE="en_US" || {
#[ -d /usr/share/locale/en ] && LANGUAGE="en" || LANGUAGE="C"
#}
LC_ALL="$LANGUAGE"
HISTSIZE=32768
HISTFILESIZE=16777216
XLIB_SKIP_ARGB_VISUALS=1
LESS="-R"
IFS=$'\n\t\r'
HISTFILESIZE=$((HISTSIZE * 512))

case "$TERM" in
  *256color*) ;;
  konsole|screen|rxvt|vte|Eterm|putty|xterm|mlterm|mrxvt|gnome) TERM="$TERM-256color" ;;
esac

unalias cp mv rm  2>/dev/null

export PATH LC_ALL LOCALE LANGUAGE HISTSIZE HISTFILESIZE XLIB_SKIP_ARGB_VISUALS LESS LS_COLORS TERM

case "$TERM" in
    xterm*) TERM=rxvt ;;
esac

case "$TERM" in
  xterm|rxvt|screen) TERM="$TERM-256color" ;;
esac

TERM=xterm-256color

alias xargs='xargs -d "\n"'
alias aria2c='aria2c --file-allocation=none --check-certificate=false'

if ls --help 2>&1 |grep -q '\--color'; then
        LS_ARGS="$LS_ARGS --color=auto"
fi
if ls --help 2>&1 |grep -q '\--time-style'; then
        LS_ARGS="$LS_ARGS --time-style=+%Y%m%d-%H:%M:%S"
fi
alias ls="ls $LS_ARGS"

if grep --help 2>&1 |grep -q '\--color'; then
        GREP_ARGS="$GREP_ARGS --color=auto"
fi
if grep --help 2>&1 |grep -q '\--line-buffered'; then
        GREP_ARGS="$GREP_ARGS --line-buffered"
fi
alias grep="grep $GREP_ARGS"
alias cp='cp'
alias mv='mv'
alias rm='rm'

unalias cp  2>/dev/null
unalias mv  2>/dev/null
unalias rm 2>/dev/null

type yum 2>/dev/null >/dev/null && alias yum='sudo yum -y'
#type smart 2>/dev/null >/dev/null && alias smart='sudo smart -y'
type apt-get 2>/dev/null >/dev/null && alias apt-get='sudo apt-get -y'
type aptitude 2>/dev/null >/dev/null && alias aptitude='sudo aptitude -y'

#cd() { command cd "$(d "$1")"; }
#pushd() { command pushd "$(d "$1")"; }

if type require.sh 2>/dev/null >/dev/null; then
	. require.sh

	require util
	require algorithm
	require list
	require fs
fi

set -o vi

alias lsof='lsof 2>/dev/null'

[ "$OSTYPE" ] && OS="$OSTYPE"

[ -d /cygdrive ]  && { CYGDRIVE="/cygdrive"; : ${OS="Cygwin"}; }
(set -- /sysdrive/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}/; for DRIVE do test -d "$DRIVE" && exit 0; done; exit 1) && SYSDRIVE="/sysdrive" || unset SYSDRIVE


if [ "$PS1" = '\s-\v\$ ' ]; then
  unset PS1
fi

set-prompt()
{
  if [ -r "$HOME/.bash_prompt" ]; then
         eval "PS1=\"$(<$HOME/.bash_prompt)\""
  else
        PS1="$*"
  fi
}


[ -d /cygdrive ]  && { CYGDRIVE="/cygdrive"; : ${OS="Cygwin"}; }
[ -d /sysdrive ]  && SYSDRIVE="/sysdrive" || SYSDRIVE=

currentpath()
{
  (CWD="${1-$PWD}"
   [ "$CWD" != "${CWD#$HOME}" ] && OUT="~${CWD#$HOME}" || OUT=`$PATHTOOL -m "$CWD"`
   [ "$OUT" != "${OUT#$SYSROOT}" ] && OUT=${OUT#$SYSROOT}
   echo "$OUT")
}

case "${OS=`uname -o |head -n1`}" in
   msys* | Msys* |MSys* | MSYS*)
    MEDIAPATH="$SYSDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}" 
    PATHTOOL=msyspath
    set-prompt '\e[32m\]\u@\h \[\e[33m\]`currentpath`\[\e[0m\]\n\$ '
    MSYSROOT=`msyspath -m /`
   ;;
  *cygwin* |Cygwin* | CYGWIN*) 
    MEDIAPATH="$CYGDRIVE/{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}" 
   set-prompt '\[\e]0;${OS}\w\a\]\n\[\e[32m\]$USERNAME@${HOSTNAME%.*} \[\e[33m\]`currentpath`\[\e[0m\]\n\$ '
   PATHTOOL=cygpath
   CYGROOT=`cygpath -m /`
  ;;
*) 
  MEDIAPATH="/m*/*/"
  
  set-prompt "${ansi_yellow}\\u${ansi_none}@${ansi_red}${HOSTNAME%[.-]*}${ansi_none}:${ansi_bold}(${ansi_none}${ansi_green}\\w${ansi_none}${ansi_bold})${ansi_none} \\\$ "
 ;;
esac
SYSROOT=`$PATHTOOL -m /`

#: ${PS1:='\[\e]0;$MSYSTEM\w\a\]\n\[\e[32m\]\u@\h \[\e[33m\]\w\[\e[0m\]\n\$ '}

pathmunge()
{
  while :; do
    case "$1" in
      -v) PATHVAR="$2"; shift 2 ;;
      *) break ;;
    esac
  done
  local IFS=":";
  : ${OS=`uname -o | head -n1`};
  case "$OS:$1" in
      [Mm]sys:*[:\\]*)
          tmp="$1";
          shift;
          set -- `${PATHTOOL:-msyspath} "$tmp"` "$@"
      ;;
  esac;
  if ! eval "echo \"\${${PATHVAR-PATH}}\"" | egrep -q "(^|:)$1($|:)"; then
      if test "$2" = "after"; then
          eval "${PATHVAR-PATH}=\"\${${PATHVAR-PATH}}:\$1\"";
      else
          eval "${PATHVAR-PATH}=\"\$1:\${${PATHVAR-PATH}}\"";
      fi;
  fi
  unset PATHVAR
}
list-mediapath()
{
  for ARG; do
    eval "ls -1 -d  -- $MEDIAPATH/\$ARG 2>/dev/null"
  done
}
add-mediapath()
{
  for ARG; do
    set -- $(eval "list-mediapath $ARG"); while [ "$1" ]; do 
        D="${1%/}"; [ -d "$D" ] || D=${D%/*}; 
      if [ -d "$D" ]; then
         [ "$ADD" = before ] && PATH="$D:$PATH" || PATH="$PATH:$D"
      fi
      shift
      done
  done
}

is-cmd() { type "$1" >/dev/null 2>/dev/null; }

#echo -n "Adding mediapaths ... " 1>&2; add-mediapath "I386/" "I386/system32/" "Windows/" "Tools/" "HBCD/" "Program*/{Notepad2,WinRAR,Notepad++,SDCC/bin,gputils/bin}/"; echo "done" 1>&2
is-cmd "notepad2" || add-mediapath "Prog*/Notepad2"

add-mediapath Tools/

#for DIR in $(list-mediapath "Prog*"/{UniExtract,Notepad*,WinRAR,7-Zip,WinZip}/ "Tools/" "I386/" "Windows"/{,system32/} "*.lnk"); do
#  DIR=${DIR%/}
#  [ -d "$DIR" ] || DIR=${DIR%/*}
#  pathmunge "${DIR}" after
# done
#
#[ -d "$CYGDRIVE/c/Program Files/WinRAR" ] && PATH="$PATH:$CYGDRIVE/c/Program Files/WinRAR"
#[ -d "$CYGDRIVE/c/Program Files/Notepad2" ] && PATH="$PATH:$CYGDRIVE/c/Program Files/Notepad2"
#[ -d "$CYGDRIVE/c/Program Files/Notepad++" ] && PATH="$PATH:$CYGDRIVE/c/Program Files/Notepad++"
#[ -d "$CYGDRIVE/c/Program Files/SDCC/bin" ] && PATH="$PATH:$CYGDRIVE/c/Program Files/SDCC/bin"
#[ -d "$CYGDRIVE/c/Program Files/gputils/bin" ] && PATH="$PATH:$CYGDRIVE/c/Program Files/gputils/bin"
#[ -d "$CYGDRIVE/C/Program Files/Microchip/MPLAB IDE/Programmer Utilities/PM3Cmd" ] && PATH="$PATH:$CYGDRIVE/C/Program Files/Microchip/MPLAB IDE/Programmer Utilities/PM3Cmd"
#[ -d "$CYGDRIVE/C/Program Files/Microchip/MPLAB IDE/Programmer Utilities/ICD3" ] && PATH="$PATH:$CYGDRIVE/C/Program Files/Microchip/MPLAB IDE/Programmer Utilities/ICD3"
#[ -d "$CYGDRIVE/x/I386" ] && PATH="$PATH:$CYGDRIVE/x/I386:$CYGDRIVE/x/I386/system32"
#[ -d "$CYGDRIVE/c/cygwin/bin" ] && PATH="$PATH:$CYGDRIVE/c/cygwin/bin"
#

FNS="$HOME/.bash_functions"

[ -r "$FNS" -a -s "$FNS" ] && . "$FNS"

[ -d "$USERPROFILE" ] && CDPATH=".:$(${PATHTOOL:-msyspath} "$USERPROFILE")"

#CDPATH=".:$CYGDRIVE/c/Users/rsenn"
#
#mediapath()
#{
#  case "$MEDIAPATH" in
#    *{*)
#      MEDIA=$(ls  --color=no -d $MEDIAPATH" 2>/dev/null |sed -n 's,/*$,, ; s,.*/,,; /#[a-z]$/p') 
#      MEDIAPATH="/{$(IFS=",$IFS"; set -- $MEDIA; echo "$*")}"
#      unset MEDIA
#      ;;
#    esac
#    echo "$MEDIAPATH"
#}
#

[ -d "x:/Windows" ] && : ${SystemRoot='x:\Windows'}
[ -d "x:/I386" ] && : ${SystemRoot='x:\I386'}

explore()
{
    ( r=$(realpath "$1");
    r=${r%/.};
    r=${r#./};
    p=$(${PATHTOOL:-msyspath} -w "$r");
    ( set -x;
    cmd /c "${SystemRoot:+$SystemRoot\\}explorer.exe /n,/e,$p" ) )
}

msiexec()
{
    (  while :; do
        case "$1" in
          -* | /?) ARGS="${ARGS+$ARGS }$1"; shift ;;
           *) break ;;
           esac
           done
    
    r=$(realpath "$1");
    r=${r%/.};
    r=${r#./};
    p=$(${PATHTOOL:-msyspath} -w "$r");
    ( set -x;
    cmd /c "msiexec.exe $ARGS $p" ) )
}




#
if [ -e /etc/bash_completion -a "${BASH_COMPLETION-unset}" = unset ]; then
         . /etc/bash_completion
 fi
 
CDPATH="."

if [ -n "$USERPROFILE" ]; then
  USERPROFILE=`${PATHTOOL:-msyspath} -m "$USERPROFILE"`
  if [ -d "$USERPROFILE" ]; then
     pathmunge -v CDPATH "$(${PATHTOOL:-msyspath} "$USERPROFILE")" after
  
    DESKTOP="$USERPROFILE/Desktop" DOCUMENTS="$USERPROFILE/Documents" DOWNLOADS="$USERPROFILE/Downloads" PICTURES="$USERPROFILE/Pictures" VIDEOS="$USERPROFILE/Videos" MUSIC="$USERPROFILE/Music"
    
    pathmunge -v CDPATH "$(${PATHTOOL:-msyspath} "$DOCUMENTS")" after
    pathmunge -v CDPATH "$(${PATHTOOL:-msyspath} "$DESKTOP")" after
  fi
fi

case "$MSYSTEM" in
  *MINGW32*) [ -d /mingw/bin ] && pathmunge /mingw/bin ;;
  *MINGW64*) [ -d /mingw64/bin ] && pathmunge /mingw64/bin ;;
  *)
LS_COLORS='di=01;34:ln=01;36:pi=33:so=01;35:do=01;35:bd=33;01:cd=33;01:or=31;01:ex=01;33:'
export LS_COLORS
;;
esac

[ -d /sbin ] && pathmunge /sbin
[ -d /usr/sbin ] && pathmunge /usr/sbin

 