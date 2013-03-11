#!/bin/sh
#
# msvc.sh: Wrapper for the MSVC++ compiler, making it behave like GNU C.
#
# Copyright (C) 2007 - DigitAll Vertrieb

# Directories of the build system
prefix="/usr"
libdir="$prefix/lib"
shlibdir="$libdir/sh"

. $shlibdir/array.sh

# Directories of the host system
cl_target="i586-win32-msvc90"
cl_prefix="/c/Program Files/Microsoft Visual Studio 9.0/VC"
cl_dir="c:/Program Files/Microsoft Visual Studio 9.0/VC"
cl_bindir="$cl_prefix/bin"
cl_libdir="$cl_dir/lib"
cl_includedir="$cl_dir/include"

mside_prefix="/c/Program Files/Microsoft Visual Studio 9.0/Common7/IDE"
mside_dir="c:/Program Files/Microsoft Visual Studio 9.0/Common7/IDE"

mssdk_prefix="/c/Program Files/Microsoft SDKs/Windows/v6.0A"
mssdk_dir="c:/Program Files/Microsoft SDKs/Windows/v6.0A"
mssdk_bindir="$mssdk_prefix/bin"
mssdk_libdir="$mssdk_dir/lib"
mssdk_includedir="$mssdk_dir/include"
mssdk_libs='advapi32.lib'

cygwin_prefix="/d/Packages/Cygwin"
cygwin_dir="d:/Packages/Cygwin"
cygwin_bindir="$cygwin_prefix/bin"

# Programs for running the MSVC toolchain
#WINE="$libdir/wine/wine.bin"
msvc_compiler="$cl_dir/bin/cl.exe"
msvc_librarian="$cl_dir/bin/lib.exe"
msvc_optchar="-"

# MSVC toolchain configuration
msvc_path="$cl_bindir:$mside_prefix:$mssdk_bindir"
msvc_include="$cl_includedir;$mssdk_includedir"
msvc_lib="$cl_libdir;$mssdk_libdir"

# Wrapper info
PROGNAME=${0##*/}

# Wrapper behaviour
DEBUG=true
OUTEXT=false
PDB=false

# ------------------------------------------------------------------------- #
# DON'T CHANGE BEYOND THIS LINE UNLESS KNOWING EXACTLY WHAT YOU'RE DOING!!! #
# ------------------------------------------------------------------------- #

# msvc_infer <arguments...>
#
# Determine compilation mode & output file type.
# ------------------------------------------------------------------------- #
msvc_infer()
{
  local a e mode="link" outname outtype="exe" inname intype debug=0 

  for a
  do
    case $a in
      [-/]c) mode="compile" msvc_outtype="obj" ;;
      [-/][EP]*) msvc_mode="preproc" msvc_outtype="pp" ;;

      -S) msvc_mode="assemble" msvc_type="asm" ;;
      
      # Handle debugging options.
      -g) test $((msvc_debug)) -lt 3 && : $((++msvc_debug)) ;;
      -g[0-3]) msvc_debug="${a#-g}" ;;
      -ggdb) msvc_debug=3 ;;

      # Option for compiling a shared library (DLL)
      [-/]LD*)
        if test "$msvc_type" = "exe"
        then 
          msvc_type="dll"
        fi
        ;;
        
      # unknown argument
      -*|/*)
    esac
  done
}

# msvc_serialize [prefix...]
#
# ------------------------------------------------------------------------- #
msvc_serialize()
{
  echo "${1+$1_}mode=$msvc_mode"
  echo "${1+$1_}outfile=$msvc_outfile"
  echo "${1+$1_}outtype=$msvc_outtype"

}

# read_var <name> <files...>
#
# Reads a variable from a file.
# ------------------------------------------------------------------------- #
read_var()
{
  local name=$1 && shift

  sed -n "/^$name=/ {
    /^$name='[^']*'\$/    s/^$name='\([^']*\)'\$/\1/ p
    /^$name=\"[^\"]*\"\$/ s/^$name=\"\([^\"]*\)\"\$/\1/ p
    /^$name=[^'\"]*\$/    s/^$name=\([^'\"]*\)\$/\1/ p
  }" "$@"
}

# restart_script <args>
#
# Restarts this script.
# ------------------------------------------------------------------------- #
restart_script()
{
  exec "$0" "$@"
}

# msvc_outopt <name> [mode] [type]
#
# Outputs a command line option which sets the output name for
# the corresponding mode.
# ------------------------------------------------------------------------- #
msvc_outopt()
{
  local opt="" mode=${2-"$msvc_mode"} type=${3-"$msvc_type"}

  case $mode in
    compile) opt="${msvc_optchar}Fo$1" ;;
    assemble) opt="${msvc_optchar}Fa$1" ;;
    preproc) ;;
    *) opt="${msvc_optchar}Fe$1" ;;
  esac


  if test -n "$opt"
  then 
    if $OUTEXT
    then
      echo "$opt${type:+.$type}"
    else
      echo "$opt"
    fi
  fi
}

# msvc_relative <path>
#
# Convert absolute path to relative one.
# This is done on any absolute path argument to disambiguate them from command line
# switches.
# ------------------------------------------------------------------------- #
msvc_relative()
{
  local IFS="/" dir cwd=`pwd` path=$*

  for dir in ${cwd#/}
  do
    path="../${path#/}"
  done
  
  echo "$path"
}

# msvc_compile <args>
# ------------------------------------------------------------------------- #
msvc_compile()
{
  unset msvc_sources
  unset msvc_link
  
  i=0
  prev=
  
  for arg
  do
    test $((i++)) = 0 && set --
    
    if $msvc_ldflags
    then
      case $arg in
        -dll)
          msvc_dll=true
          ;;
        *)
          array_push msvc_link "$arg"
          ;;
      esac

      continue
    fi
    
    case $prev in
      # Last argument was -o, so this argument is the output filename.
      [-/]o) arg=`msvc_outopt "$arg"` && unset prev ;;
      [-/][DI]) arg="${msvc_optchar}${prev#-}$arg" && unset prev ;;
      -L) msvc_lib="$msvc_lib;$arg" && unset arg && unset prev ;;
      -l) array_push msvc_link "$arg.lib" && unset arg && unset prev ;;
      [-/]LINK) array_push msvc_link "$arg" && unset arg && unset prev ;;
      
      *)
        case $arg in
          # Dump machine
          [-/]dumpmachine)
            echo "$cl_target"
            exit 0
            ;;
        
          # Void options...
          [-/]traditional-cpp | [-/][Nn][Oo][Ll][Oo][Gg][Oo])
            unset arg
            ;;
        
          # Options which take arguments...
          [-/][DILlo]) 
            prev="$arg"
            continue
            ;;
  
          # Options without args...
          [-/][cE])
            arg="${msvc_optchar}${arg#[-/]}"
            ;;

          [-/][Ll][Ii][Nn][Kk])
            msvc_ldflags=true
#            prev="${msvc_optchar}LINK"
            continue
            ;;
      
          # Options which change env vars...
          -L*)
            msvc_lib="$msvc_lib;${arg#-L}"
            continue
#            arg="-LIBPATH:${arg#-L}"
            ;;
  
          # Link a library...
          -l*)
#            arg="${arg#-l}.lib"
            array_push msvc_link "${arg#-l}.lib"
            continue
            ;;

          # Options which map transparently...
          [-/][DI]* | [-/]MD*)
            arg="${msvc_optchar}${arg#[-/]}"
            ;;
  
          # Set the output filename.
          [-/]o* | [-/]F[eo]*)
            msvc_output="${arg#[-/]o}"
            msvc_output="${msvc_output#[-/]F[eo]}"
            arg=`msvc_outopt "$msvc_output"` || continue
            ;;
  
          # Compiler warnings
          [-/]Wall | [-/]W[23])
            arg="${msvc_optchar}Wall"
            ;;
  
          [-/]WX | -Werror) 
            arg="${msvc_optchar}WX"
            ;;
  
          -W) 
            arg="${msvc_optchar}W1"
            ;;
      
          -fomit-frame-pointer)
            arg="${msvc_optchar}Oy"
            ;;
      
          # Optimization flags
          [-/]O[0-3bdgistxy] | -O)
            msvc_optimize=${arg#[-/]O}
            
            case $msvc_optimize in
              s) msvc_optimize=`array "1" "s"` ;;
              0) msvc_optimize="d" ;;
         "" | 1) msvc_optimize=`array "1" "t"` ;;
              2) msvc_optimize=`array "2" "t" "i"` ;;
              3) msvc_optimize=`array "2" "x" "i" "b1"` ;;
              *) array_push msvc_optimize "$msvc_optimize" ;;
            esac
            
            unset arg
            ;;
      
          # Debugging flags
          -g*)
            case $prev in
              -g*) ;;
              *)
                case $msvc_debug in
                  0) arg= ;;
                  1) arg=`array "${msvc_optchar}Zi"` ;;
                  2) arg=`array "${msvc_optchar}Zi" "${msvc_optchar}Yd"` ;;
                  3) arg=`array "${msvc_optchar}Zi" "${msvc_optchar}ZI" "${msvc_optchar}Yd"` ;;
                esac
                ;;
            esac
            
            if ! $PDB
            then
              unset arg
            fi
            ;;
      
          # Linker options
          [-/]LD | -shared | -mdll)
            arg="${msvc_optchar}LD"
            ;;
            
          # Help options
          [-/][Hh][Ee][Ll][Pp])
            arg="${msvc_optchar}HELP"
            ;;
      
          # Discard options
          -pipe)
            unset arg
            ;;
      
          # Any other option
          -*)
            echo "Unrecognized option: $arg" 1>&2
            exit 1
            ;;
        
          # Non-option arguments
          *)
            source_path="$arg"
            source_file=`basename "$arg"`
            source_dir=`dirname "$arg"`
            
            case $source_file in
              lib*.a)
                 array_push msvc_link "$source_path"
                 continue
#                source_file=${source_file#lib}
#                source_file=${source_file%.a}.lib
                ;;
            esac
            
            case $source_dir in
              /*) source_dir=`msvc_relative "$source_dir"` ;;
            esac
            
            case $source_dir in
              .) source_path="$source_file" ;;
              *) source_path="$source_dir/$source_file" ;;
            esac
          
            array_push msvc_sources "$source_path"
            unset arg
            continue
            ;;
        esac
      ;;
    esac
    
  
    set -- "$@" ${arg+$arg}
  
  done
  
  # Second pass, adjusting some switches...
  i=0
  
  for arg
  do
    test $((i++)) = 0 && set --
  
    case $arg in
      /LD | /M[DT])
        # On debugging mode greater than 1 we also instruct the linker..
        if test $((msvc_debug)) -gt 1
        then
          arg="${arg}d"
        fi
        ;;
    esac
  
    set -- "$@" $arg
  done
  
  # Never display microsoft banner..
#  set -- "/nologo" "$@"
  
  # Set optimization, if any...
  if test -n "$msvc_optimize" && test "$msvc_optimize" != "d"
  then
    for opt in $msvc_optimize
    do
      set -- "$@" "${msvc_optchar}O$opt"
    done
  fi
  
  # Add the list of sources...
  set -- "$@" $msvc_sources
  
  # Add option forcing C++ compilation...
  case $PROGNAME in
    [cg]++ | *-[cg]++)
      set -- "${msvc_optchar}TP" "$@"
      ;;
  esac

  # Add dll linker option
  if $msvc_dll
  then
    if test $((msvc_debug)) -gt 1
    then
      set -- "$@" "${msvc_optchar}LDd"
    else
      set -- "$@" "${msvc_optchar}LD"
    fi
  fi

  # Add linker options
  if test -n "$msvc_link"
  then
#    set -- "$@" "/LINK" $msvc_link
    set -- "$@" $msvc_link 
    
    set -- "$@" $mssdk_libs
  fi

  # Finally execute the compiler..
#  set -- env -i PATH="$msvc_path" LIB="$msvc_lib" INCLUDE="$msvc_include" "$msvc_compiler" "$@"

  if test "${msvc_arflags+set}" = set
  then
    set -- "$msvc_librarian" "$@"
  else
    set -- "$msvc_compiler" "$@"
  fi
    
  msvc_exec "$@"

}
# msvc_exec <args>
# ------------------------------------------------------------------------- #
msvc_exec()
{
  (

  echo PATH="$msvc_path" LIB="$msvc_lib" INCLUDE="$msvc_include" 1>&2
  PATH="$msvc_path" LIB="$msvc_lib" INCLUDE="$msvc_include"
  export PATH LIB INCLUDE
  
  if $DEBUG; then set -x; fi
  "$@") || exit $?
  
  return
  msvc_ret=$?

  if $DEBUG
  then
    echo "RET: $msvc_ret"
  fi
  
  return $msvc_ret
}

# msvc_ar <args>
# ------------------------------------------------------------------------- #
msvc_ar()
{
  msvc_arflags="$1"
     
  shift
  set -- "/OUT:$@"

  msvc_exec "$msvc_librarian" "$@"
}

# msvc_main <args>
# ------------------------------------------------------------------------- #
msvc_main()
{
  IFS="$array_s"
  
  echo "Invoked as: $PROGNAME $@" 1>&2
  
  msvc_infer "$@"

  msvc_optimize=1
  msvc_dll=false
  msvc_ldflags=false

  # When invoked as 'ar' or 'ranlib', then invoke the librarian
  case "${PROGNAME##*[-/]}" in
    ar)
      msvc_ar "$@"
      ;;
    *)
      msvc_compile "$@"
      ;;
  esac
  
}

msvc_main "$@"

#exit $msvc_ret
