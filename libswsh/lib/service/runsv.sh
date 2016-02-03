#!
#
# service.sh: Functions for dealing with services supervised by daemontools.
# They modify or extract info from /usr/local/services respectively
# /usr/local/etc/services, either directly or trought "svc" & "svstat"
# (daemontools).
#
# $Id: service.sh.in 589 2008-08-27 05:51:02Z enki $
# -------------------------------------------------------------------------
test $lib_runsv_sh || {

: ${prefix:="/usr"}
: ${exec_prefix:="/usr"}
: ${sysconfdir:="/etc"}
: ${libdir:="${exec_prefix}/lib"}
: ${shlibdir:="${libdir}/sh"}
: ${localstatedir:="/var"}

# -------------------------------------------------------------------------
. $shlibdir/util.sh
. $shlibdir/log.sh
. $shlibdir/proc.sh
. $shlibdir/data/text.sh
. $shlibdir/std/array.sh
. $shlibdir/std/algorithm.sh

# -------------------------------------------------------------------------
: ${SVCONFDIR="$sysconfdir/service"}
: ${SVDIR="$localstatedir/service"}

# UTILITY FUNCTIONS
# ================================================================================

# runsv_name <path>...
#
# convert from service paths to names
# -------------------------------------------------------------------------
runsv_name()
{
  for_each 'realpath' "$@" | removeprefix "$SVDIR/"
}

# runsv_path <name>...
#
# convert from service names to paths
# -------------------------------------------------------------------------
runsv_path()
{
  for_each 'case "$1" in
    /*) echo "$1" ;;
    *) echo "$SVDIR/$1" ;;
  esac' "$@"
}

# SERVICE CONFIGURATION FUNCTIONS
# ================================================================================

# runsv_pidfile <name>
#
# get the pid file specified in the configuration of a service
# -------------------------------------------------------------------------
#runsv_pidfile()
#{
#  eval eval echo "\$${1}_PIDFILE"
#}

# runsv_each <commands|function>
#
# execute a function/command for each service known to the configuration.
# will abort (and return 1) after the first call to a function fails.
# -------------------------------------------------------------------------
runsv_each()
{
 (IFS=" "
  CMD="$1"
  shift
  each "$CMD" ${*-$SVDIR/*})
}

# Checks if the specified service exists, which means it has a
# corresponding directory in /usr/local/etc/services
#
# Can be used in the form:
#
# runsv_exists <service>... && {
#   <actions>...
# }
# -------------------------------------------------------------------------
runsv_exists()
{
  each 'test -d "$1/run"' "$@"
}

# Like the one above, but yields an error message when a service doesn't exist
# -------------------------------------------------------------------------
runsv_mustexist()
{
  if ! runsv_exists "$1"; then
    echo "$1: no such service"
    return 1
  fi
}

# -------------------------------------------------------------------------
runsv_mustnotexist()
{
  if runsv_exists "$1"; then
    echo "$1: already exists"
    return 1
  fi
}

# Checks if the specified service(s) is/are enabled, which means they are
# symlinked from /usr/local/services to /usr/local/etc/services.
#
# Can be used in the form:
#
# runsv_enabled <service>... && {
#   <actions>...
# }
# -------------------------------------------------------------------------
runsv_enabled()
{
  runsv_exists "$@" &&
  for service
  do
    if test ! -d $runsv_rundir/$service
    then
      return 1
    fi
  done
}

# Like the one above, but yields an error message when a service isn't enabled
# or doesn't even exist
# -------------------------------------------------------------------------
runsv_mustbeenabled()
{
  local service

  runsv_mustexist "$@" &&
  for service
  do
    if test ! -d $runsv_rundir/$service
    then
      echo "$service: disabled"
      return 1
    fi
  done
}

# runsv_enable <service>...
#
# Enable one or more services
# -------------------------------------------------------------------------
runsv_enable()
{
  runsv_mustexist "$@" &&
  for service
  do
    if ! runsv_enabled "$service"; then
      ln -s "$runsv_svcdir/$service" "$runsv_rundir"
    else
      errormsg "${service}: already enabled"
    fi
  done
}

# runsv_disable <service>...
#
# Disable one or more services
# -------------------------------------------------------------------------
runsv_disable()
{
  runsv_mustexist "$@" &&
  for service
  do
    if runsv_enabled "$service"
    then
      rm -f "$runsv_rundir/$service"
    else
      errormsg "$service: already disabled"
    fi
  done
}

# SERVICES MONITORING
# ================================================================================

# Get the service(s) status using "svstat" (daemontools)
#
# runsv_stat <service>...
#
# It will print out a line for each service like:
#
# /usr/local/service/httpd: up (pid 31737) 3556 seconds
# /usr/local/service/mysqld: down 1515 seconds, normally up
# -------------------------------------------------------------------------
runsv_stat()
{
  local service

#  runsv_mustbeenabled "$@" &&
  svstat `runsv_path "$@"` 2>/dev/null
}

# Get the process id of services using the daemontools backend
#
# runsv_getpid <name...|svstat-output...>
#
# You can optionally supply the output from a previous call to runsv_stat,
# so it won't call svstat by itself
# -------------------------------------------------------------------------
runsv_getpid()
{
  local pid service stat IFS="
"
  case $* in
    *:*) set -- $* ;;
      *) set -- `runsv_stat $*` ;;
  esac

  echo "$*" | sed -n -e "/^[^:]\+: up (/ s/.*pid \([0-9]*\).*/\1/ p"
}

#runsv_getpid_boot()
#{
#  pgrep -f 'svscanboot$'
#}

# Get the process id of a service using the configuration
#
# runsv_getpid_file <name>
# -------------------------------------------------------------------------
#runsv_getpid_file()
#{
#  local pidfile=`runsv_pidfile "$1"`
#
#  if test -f "$pidfile"
#  then
#    cat "$pidfile"
#  fi
#}

# runsv_gettime <name> [svstat]
#
# Get the time a particular service has been running for
# -------------------------------------------------------------------------
runsv_gettime()
{
  local time service=$1

  shift

  time=$(array ${@-`runsv_stat ${service}`} | sed -n '/^[0-9]\+$/ { N; p }')

  if test -n "$time"
  then
    echo "$time"
  fi
}

# runsv_getstatus <name> [svstat]
#
# get the status of a service (up, down, disabled)
# -------------------------------------------------------------------------
runsv_getstatus()
{
  local time service=$1

  shift

  status=$(echo ${@-`runsv_stat "$service"`} | \
           sed 's|.*supervise not running|failure|;;
                s|.*file does not exist|disabled|;;
                s|.*: ||;;
                s| (.*||;;
                s|.*down .*|down|;;
                s|.*up .*|up|')

  if test -n "$status"
  then
    echo "$status"
  fi
}

# runsv_supervised <name> [svstat]
#
# check if a service is supervised, which means that it must be enabled
# and svscanboot and the supervise process corresponding to that service
# must be running.
# -------------------------------------------------------------------------
runsv_supervised()
{
  local service=$1

  shift

  test "`runsv_getstatus ${service} "$@"`" != "disabled"
}

# runsv_mustbesupervised <name>
#
# same as above, but printing an error message
# -------------------------------------------------------------------------
runsv_mustbesupervised()
{
  proc_mustbeinstalled &&
  if ! runsv_supervised "$1"
  then
    errormsg "$1 is disabled"
    return 1
  fi
}

# SERVICES CONTROL   (duh, not very nice concept here)
# ================================================================================

# runsv_up <service>...
#
# Start a service
# -------------------------------------------------------------------------
runsv_up()
{
  runsv_mustnotrun "$@" &&
 (svc -u `runsv_path "$@"`)
}

# runsv_down <name>
#
# Stop a service
# -------------------------------------------------------------------------
runsv_down()
{
  runsv_mustrun "$@" &&
 (svc -d `runsv_path "$@"`)
}

# SERVICES API
# ================================================================================

# get human readable info about a service
#
# runsv_getinfo <service>...
# -------------------------------------------------------------------------
runsv_getinfo()
{
  local svstat=`runsv_stat "$1"`
  local status=`runsv_getstatus "$1" "$svstat"`
  local time=`runsv_gettime "$1" "$svstat"`

  case $status in
    up)
      local pid=`runsv_getpid "$1" "$svstat"`
      echo "up since ${time} (pid ${pid})"
      ;;
    down)
      echo "down since ${time}"
      ;;
    'file does not exist')
      echo "disabled"
      ;;
    *)
      echo "$status"
      ;;
   esac
}

# waiting for a service to come up
# -------------------------------------------------------------------------
runsv_wait_up()
{
  while sleep $runsv_interval
  do
    runsv_runs "$@" && break
  done
}

# waiting for a service to terminate
# -------------------------------------------------------------------------
runsv_wait_down()
{
  while sleep $runsv_interval
  do
    runsv_runs "$@" || break
  done
}

# runsv_mustnotrun <name>
# -------------------------------------------------------------------------
runsv_mustnotrun()
{
  if runsv_runs "$1"
  then
    errormsg "$1 already running"
    return 1
  fi
}

# runsv_runs <name> [svstat]
# -------------------------------------------------------------------------
runsv_runs()
{
#  echo $1 `runsv_getstatus "$@"`
  test "`runsv_getstatus "$@"`" = "up"
}

# runsv_mustrun <name>
# -------------------------------------------------------------------------
runsv_mustrun()
{
  if ! runsv_runs "$@"
  then
    errormsg "$1 not running"
    return 1
  fi
}

# SERVICES COMMAND LINE CLIENT
# ================================================================================

# runsv_create <name> <run> [svcdir]
# -------------------------------------------------------------------------
runsv_create()
{
  local svcdir="${3-$runsv_svcdir}"

  runsv_mustnotexist "$1" &&
  {
    mkdir -p "$svcdir/$1"

    if is_object "$2"
    then
      ln -s "$2" "$svcdir/$1/run"
    else
      cp -fL "$2" "$svcdir/$1/run"
    fi 2>/dev/null

    msg "Created new service '$1'."
    echo "$svcdir/$1"
  }
}

# runsv_setparams <name> [params...]
# -------------------------------------------------------------------------
runsv_setparams()
{
  local service="$1"

  shift

  runsv_mustexist "$service" &&
  {
    for param
    do
      echo "$param"
    done >$runsv_svcdir/$service/params
  }
}

# runsv_list [svcdir]
# -------------------------------------------------------------------------
runsv_list()
{
  local svcdir="${1-$runsv_svcdir}"

 (cd "$svcdir"

  for svc in */run
  do
    case $svc in
      supervise/run|*/supervise/run)
        ;;
      */run)
        if test -e "$svc" -a ! -d "$svc" -a -d "${svc%/run}"
        then
          echo ${svc%/run}
        fi
        ;;
    esac
  done)# 2>/dev/null
}

# runsv_tree [svcdir]
# -------------------------------------------------------------------------
runsv_tree()
{
  local svcdir="${1-$runsv_svcdir}"
  local pfx=${2-$svcdir/}

  (cd "$svcdir"

   for svc in */run
   do
     if test -e "$svc" && test "$svc" != "supervise/run"
     then
       svc=${svc%/run}
       echo "$pfx$svc"
       runsv_tree "$svcdir/$svc" ${2+"$2$svc/"}
     fi
   done) 2>/dev/null
}

# try to start a service and track its log while it is coming up
# -------------------------------------------------------------------------
runsv_start()
{
  runsv_mustbesupervised $1 &&
  runsv_mustnotrun $1 &&
  {
    local logpid stop

    msg "starting $1..."

    if var_isset "$1_START"
    then
      (log_follow --stop="`var_get "$1_START"`" --lines=0 --prefix $1) & logpid=$!
    fi

    runsv_up $1

    if ! var_isset "$1_START"
    then
      runsv_wait_up $1
    fi

    wait ${logpid} 2>/dev/null
  }
}

# try to stop a service and track its log while it is shutting down
# -------------------------------------------------------------------------
runsv_stop()
{
  runsv_mustbesupervised $1 &&
  runsv_mustrun $1 &&
  {
    local logpid stop

    msg "stopping $1 (`var_get "$1_STOP"`)..."

    if var_isset "$1_STOP"
    then
      (log_follow --stop="`var_get "$1_STOP"`" --lines=0 --prefix $1) & logpid=$!
    fi

    runsv_down $1

    if ! var_isset "$1_STOP"
    then
      runsv_wait_down $1
    fi

    wait $((logpid)) 2>/dev/null
  }
}

# runsv_wrap <function> [services...]
# -------------------------------------------------------------------------
runsv_wrap()
{
  local fn="$1" service services

  shift

  if test "$#" -gt 0
  then
    services="$@"
    for service in $services
    do
      runsv_mustexist $service || return 1
    done
  else
    services=$SERVICES
  fi

  for service in $services
  do
    $fn $service
  done
}

# show the status of a service
#
# runsv_status <service>
# -------------------------------------------------------------------------
runsv_status()
{
  info=`runsv_getinfo $1`

  # fancy colorful :)
#  info=`echo ${info} | sed 's,^up,\\033[32;1mup\\033[0m,;;s,^down,\\033[31;1mdown\\033[0m,;;s,^disabled,\\033[33;disabled\\033[0m,'`

  echo -e $1: ${info}
}

# add services to autostart list (means enable)
# -------------------------------------------------------------------------
runsv_add()
{
  if runsv_enabled "$@"
  then
    msg "service $@ already enabled"
  else
    if runsv_enable "$@"
    then
      msg "enabled service $@"
    else
      msg "failed enabling service $@"
    fi
  fi
}

# remove services from autostart list (means disable)
# -------------------------------------------------------------------------
runsv_remove()
{
  if runsv_runs "$@"
  then
    msg "service $@ still running"
    return 1
  fi

  if ! runsv_enabled "$@"
  then
    msg "service $@ already disabled"
  else
    if runsv_disable "$@"
    then
      msg "disabled service $@"
    else
      msg "failed disabling service $@"
    fi
  fi
}

# print a list of all services that are running
# -------------------------------------------------------------------------
runsv_running()
{
  local service

  for service in $SERVICES
  do
    if runsv_runs "$service"
    then
      echo "$service"
    fi
  done
}

# runsv_clean_rc <file> <trailing comments>
# -------------------------------------------------------------------------
runsv_clean_inittab()
{
  local inittab="`cat $1`"

  if test -n "$2"
  then
    echo "`echo "${inittab%"$2"}"`"
  else
    echo "$inittab"
  fi
}

# get trailing comments from inittab
#
# runsv_end_rc <file>
# -------------------------------------------------------------------------
runsv_end_inittab()
{
  local line end

  while read line
  do
    case $line in
      ""|" "|"  "|"   ")
        ;;
      "#"*)
        end="${end}
${line}"
        ;;
      *)
        end=""
        ;;
    esac
  done < $1

  echo "$end"
}

# determine the rcfile
runsv_rcfile()
{
  local end temp

  case $target in
    *freebsd*)
      rcfile='/etc/rc'
      ;;
    *)
      local rc

      for rc in '/etc/inittab' '/etc/rc'
      do
        if test -f "$rc"
        then
          rcfile="$rc"
          break
        fi
      done
      ;;
  esac

  case $rcfile in
    '/etc/inittab')
      entry_add="SV:12345:respawn:$prefix/bin/svscanboot"
      comment_add='# automatically added by nexsvc, do NOT change!'

      entry_search="SV.*svscanboot"
      comment_search='.*added by nex.*'

      end_of_search='# end of.*'
      ;;

    '/etc/rc')
      entry_add="/usr/local/bin/setsid.static /usr/local/bin/svscanboot &"
      comment_add='# automatically added by nexsvc, do NOT change!'

      entry_search=".*setsid.*svscanboot ."
      comment_search='.*added by nex.*'

      end_of_search='# end of.*'
      ;;
  esac
}

# install svscanboot to the inittab or rc-script
# -------------------------------------------------------------------------
runsv_install()
{
  local end temp

  runsv_rcfile

  # backup rcfile
  if test ! -f "$rcfile.backup" && test -s "$rcfile"
  then
    cp "$rcfile" "$rcfile.backup"
  fi

  if ! grep -q "^$entry_search$" $rcfile
  then
    case $target in
      *freebsd*)
        text_insert_before "$comment_add$newline$entry_add" "^echo''" $rcfile ||
        text_insert_before "$comment_add$newline$entry_add" "^date" $rcfile ||
        text_insert_before "$comment_add$newline$entry_add" "^exit 0" $rcfile ||
        text_append "$comment_add$newline$entry_add" $rcfile
        ;;
      *)
        if ! grep -q "^$end_of_search$" $rcfile; then
          text_append "$comment_add$newline$entry_add" $rcfile
        else
          text_insert_before "$comment_add$newline$entry_add" "^$end_of_search$" ${rcfile}
        fi
        ;;
    esac
    msg "added $prefix/bin/svscanboot to ${rcfile}"
    return 0
  else
    msg "svscanboot already in ${rcfile}"
    return 1
  fi
}

# remove svscanboot from the inittab
# -------------------------------------------------------------------------
runsv_uninstall()
{
  local temp tab

  runsv_rcfile

  if grep -q "^${entry_search}$" "$rcfile"
  then
    text_remove "^${entry_search}$" "$rcfile"
    text_remove "^${comment_search}$" "$rcfile"

    msg "removed svscanboot from ${rcfile}"

    return 0
  else
    msg "svscanboot not in ${rcfile}"
    return 1
  fi
}

runsv_mustbeinstalled()
{
  if ! grep -q "^${entry_search}$" "$rcfile"
  then
    msg "svscanboot not in ${rcfile}, use nexsvc --install"
    return 1
  fi

  return 0
}

runsv_isinstalled()
{
  grep -q "^${entry_search}$" "$rcfile"
}

# rehash init [1]
# -------------------------------------------------------------------------
runsv_rehash()
{
  runsv_rcfile

  case $rcfile in
    '/etc/inittab')
      msg "sending SIGHUP to init [1]"
      kill -HUP 1
      ;;
    '/etc/rc')
      local pid=`proc_svscanboot`

      if test -n "$pid"
      then
        if ! runsv_isinstalled
        then
          msg "sending SIGTERM to svscanboot [$pid]"
          kill -TERM "$pid"
        else
          msg "svscanboot is already running [$pid]"
        fi
      else
        runsv_mustbeinstalled &&
        {
          setsid /usr/local/bin/svscanboot &
          msg "launched svscanboot [$!]"
        }
      fi
      ;;
  esac
}

# shut down everything (before uninstall)
# -------------------------------------------------------------------------
runsv_fullstop()
{
  local services svc_pids file_pids tree_pids all_pids

  # get a list of running services and their pids
  services=`runsv_running`
  svc_pids=`runsv_for_each runsv_getpid_svc`

  # get list of running processes by their pid files
  file_pids=`runsv_for_each runsv_getpid_file`

  # get list of running processes by the more direct
  # approach of searching svscanboot in the process list
  # and then tracking all its children
  tree_pids=`proc_supervised`

  # merge all pids
  set -- `proc_merge ${svc_pids} ${file_pids} ${tree_pids}`

  if test -n "$services"
  then
    msg "$# processes in `proc_count ${services}` services to consider"

    # terminate services using the conventional method
    for_each runsv_down ${services}
  else
    msg "$# processes to consider"
  fi

  # remove svscan from rcfile and rehash init
  runsv_uninstall
  runsv_rehash

  # force those who didn't terminate
  local still_running=`proc_still_running $svc_pids`

  for pid in $still_running
  do
    name=`proc_cmdline $pid`
    msg "$name ($pid) didn't terminate properly, killing it..."

    kill $pid
  done

  if test -n "$still_running"
  then
    msg "waiting a moment to terminate..."
    sleep 1
  fi

  # get those which are still running
  set -- `proc_still_running "$@"`

  if test "$#" -gt 0
  then
    msg "$# processes still running, killing them now..."

    kill "$@" 2>/dev/null

    msg "waiting a moment to terminate..."
    sleep 1

    set -- `proc_still_running "$@"`

    if test "$#" -gt 0
    then
      msg "$# processes STILL running (!!!)"
    fi
  else
    msg "clean shutdown"
  fi
}

# show all pids
runsv_pids()
{
  local services svc_pids file_pids tree_pids all_pids

  # get a list of running services and their pids
  services=`runsv_running`
  svc_pids=`runsv_for_each runsv_getpid_svc`

  # get list of running processes by their pid files
  file_pids=`runsv_for_each runsv_getpid_file`

  # get list of running processes by the more direct
  # approach of searching svscanboot in the process list
  # and then tracking all its children
  tree_pids=`proc_supervised`

  # merge all pids
  set -- `proc_merge ${svc_pids} ${file_pids} ${tree_pids}`

  echo "$@"
}

# SERVICES API FROM WITHIN RUN SCRIPT
# ================================================================================
runsv_msg()
{
  echo "$@" 1>&2
}

runsv_error()
{
  runsv_msg "$@"
  exec sleep $((15 * 60))
}

# --- eof ---------------------------------------------------------------------
lib_runsv_sh=:;}
