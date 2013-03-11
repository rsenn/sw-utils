#!/bin/sh
#
# ui.sh: user-interface functions
#
# $Id: ui.in 487 2006-06-22 07:31:06Z roman $
# -------------------------------------------------------------------------
test $lib_ui_sh || {

: ${ui_backtitle:="epiphyte"}
: ${ui_width:=64}
: ${ui_terminal:=/dev/tty}

# display a menu dialog box
#
# ui_menu [options] <title> <items>...
# -------------------------------------------------------------------------
ui_menu()
{
  local options IFS="$list_separator"

  # parse options first
  while [ "$1" ]
  do
    case $1 in
      --cancel-label|--default-item)
        array_push 'options' "$1" "$2"
        shift
        ;;
      --*)
        array_push 'options' "$1"
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  # get the title and calculate its line count
  local title=$1; shift
  local lines=`echo "$title" | wc -l`

  # calculate dialog height and item count
  local items=$(($# / 2))
  local height=$((items + 6 + lines))

  dialog --backtitle "$ui_backtitle" \
         ${options} --menu "$title" \
         ${height} ${ui_width} \
         ${items} "$@" \
         2>&1 1>${ui_terminal}
}

# display an input dialog box
#
# ui_input [options] <title> [init]
# -------------------------------------------------------------------------
ui_input()
{
  local options IFS="$list_separator"

  # parse options first
  while [ "$1" ]
  do
    case $1 in
      --cancel-label)
        array_push 'options' "$1" "$2"
        shift
        ;;
      --*)
        array_push 'options' "$1"
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  # get the title and calculate its line count
  local title=$1; shift
  local lines=`echo "$title" | wc -l`

  # calculate dialog height and item count
  local height=$((lines + 7))

  dialog --backtitle "$ui_backtitle" \
         ${options} --inputbox "$title" \
         ${height} ${ui_width} \
         ${1:+"$1"} \
         2>&1 1>${ui_terminal}
}

# display an input dialog box
#
# ui_choose [options] <title> <items...>
# -------------------------------------------------------------------------
ui_choose()
{
  local options entries entry IFS="$list_separator"

  # parse options first
  while [ "$1" ]
  do
    case $1 in
      --*-label|--default-item)
        array_push 'options' "$1" "${2:-"-"}"
        shift
        ;;
      --*)
        array_push 'options' "$1"
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  # get the title and calculate its line count
  local title=${1:-"-"}; shift
  local lines=`echo "$title" | wc -l`

  # calculate dialog height and item count
  local items=$(($# / 2))
  local height=$((items + 6 + lines))

  dialog --backtitle "$ui_backtitle" \
         ${options} --menu "$title" \
         ${height} ${ui_width} \
         ${items} "$@" \
         2>&1 1>${ui_terminal}
}

# display an info dialog box
#
# ui_info <text>
# -------------------------------------------------------------------------
ui_info()
{
  local options

  # parse options first
  while [ "$1" ]
  do
    case $1 in
      --*)
        array_push 'options' "$1"
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  # get the text and calculate its line count
  local text=${1:-"-"}; shift
  local lines=`echo "$text" | wc -l`
  local height=$((lines + 2))

  dialog --backtitle "$ui_backtitle" \
         --infobox "$text" \
         ${height} ${ui_width} \
         2>&1 1>${ui_terminal}
}

# display a yes/no dialog box
#
# ui_yesno [options] <title> [default]
# -------------------------------------------------------------------------
ui_yesno()
{
  local options IFS="$list_separator"

  # parse options first
  while [ "$1" ]
  do
    case $1 in
      --*)
        array_push 'options' "$1"
        ;;
      *)
        break
        ;;
    esac
    shift
  done
  if [ "$2" = no ]; then
    array_push 'options' '--defaultno'
  fi

  # get the title and calculate its line count
  local title=$1; shift
  local lines=`echo "$title" | wc -l`

  # calculate dialog height and item count
  local height=$((lines + 4))

  if dialog --backtitle "$ui_backtitle" \
            ${options} --yesno "$title" \
            ${height} ${ui_width} \
            2>&1 1>${ui_terminal}; then
    echo "yes"
  else
    echo "no"
  fi
}

# display a checklist dialog box
#
# ui_checklist [options] <title> [item label status]...
# -------------------------------------------------------------------------
ui_checklist()
{
  local options IFS="$list_separator"

  # parse options first
  while [ "$1" ]
  do
    case $1 in
      --*-label|--default-item)
        array_push 'options' "$1" "${2:-"-"}"
        shift
        ;;
      --*)
        array_push 'options' "$1"
        ;;
      *)
        break
        ;;
    esac
    shift
  done

  # get the title and calculate its line count
  local title=$1; shift
  local lines=`echo "$title" | wc -l`
  local items=$(($# / 3))

  # calculate dialog height and item count
  local height=$((lines + 6 + items))

  dialog --backtitle "$ui_backtitle" \
         --single-quoted \
         ${options} --checklist "$title" \
         ${height} ${ui_width} ${items} "$@" \
         2>&1 1>${ui_terminal}
}

# --- eof ---------------------------------------------------------------------
lib_ui_sh=:;}
