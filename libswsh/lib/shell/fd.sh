#!
#
# fd.sh: File descriptor maintenance.
#
# $Id: www.in 683 2007-03-26 16:21:05Z  $
test $lib_fd_sh || {

# fd_valid
# -------------------------------------------------------------------------
fd_valid()
{
  local n=$1
  test -e /dev/fd/$((n))
}

# fd_alloc
# -------------------------------------------------------------------------
fd_alloc()
{
  local fd=0

  while fd_valid $((fd))
  do
    : $((++fd))
  done

  echo $((fd))
}

# -------------------------------------------------------------------------
_fd_redir()
{
  local rdr
  case $1 in
    r) rdr='<' ;;
    w) rdr='>' ;;
    a) rdr='>>' ;;
    rw|*) rdr='<>' ;;
  esac
  echo "$rdr"
}

# -------------------------------------------------------------------------
fd_path()
{
  readlink "/dev/fd/$1" || readlink "/proc/$$/fd/$1" ||
  realpath "/dev/fd/$1" || realpath "/proc/$$/fd/$1"
} 2>/dev/null

# -------------------------------------------------------------------------
fd_open()
{
  local n=`fd_alloc`
  eval exec "$((n))`_fd_redir $2`$1" && return $((n))
  return 127
}

# fd_type <fd-number>
# 
# Outputs the type of the file descriptor.
# -------------------------------------------------------------------------
fd_type()
(
  LINK=`fd_path "$1"` 

  if [ -b "$LINK" ]; then
    echo block
  elif [ -c "$LINK" ]; then
    echo char
  elif [ -f "$LINK" ]; then
    echo file
  elif [ -p "$LINK" ]; then
    echo fifo
  elif [ -S "$LINK" ]; then
    echo sock
  elif [ -e "$LINK" ]; then
    echo null
  else
    echo -
    return 1
  fi
)


# -------------------------------------------------------------------------
fd_dump()
{
  FD_delim="${IFS%${IFS#?}}"

  for FD_link in /proc/$$/fd/*; do
    FD_number="${FD_link##*/}"
    echo "$FD_number" "`fd_type $FD_number`" "`fd_path $FD_number`"
  done

  unset FD_delim FD_link FD_number
}

# -------------------------------------------------------------------------
fd_list()
(
  cd /proc/$$/fd

  for NUMBER in *; do
    echo "$NUMBER"
  done
)

# -------------------------------------------------------------------------
fd_close()
{
  local n=$1
  fd_valid $((n)) && eval exec "->&$((n))"
}

# --- eof ---------------------------------------------------------------------
lib_www_sh=:;}
