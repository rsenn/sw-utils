#!/usr/bin/env bash
#
# 20080811

MY_NAME=`basename "$0"`
MY_DIR=`dirname "$0"`

if type gsed >/dev/null 2>/dev/null; then
  SED=gsed
else
  SED=sed
fi
  
#ACINPUT_DIR=. PREPEND_ACOUTPUT=../../ PREPEND_AGOUTPUT=     # bootstrap in libswsh/build/gnu/
ACINPUT_DIR=build/gnu PREPEND_ACOUTPUT= PREPEND_AGOUTPUT=../../     # bootstrap in libswsh/

MAKEFILES=
FILES=


libtoolize --force --copy --automake 
aclocal --force -I build/gnu
#autoheader --force
automake --force --copy --foreign --add-missing
aclocal --force -I build/gnu
autoconf --force


find $MY_DIR/../../lib $MY_DIR/../../src | 
while read path; do
  [ -d "$path" ] || continue

  case $path in
    */.[!.]*) continue ;;
  esac

  FILES=`cd $path && ls *sh.in *.sh 2>/dev/null`

  #test -n "$FILES" &&
   echo "$path"
done | sort -u | {
  dirs=
  while read dir; do
    case $dir in
      */CMakeFiles*) continue ;;
    esac

    subdir=${dir#$MY_DIR/../../}

    set -- `cd "$dir" && ls *.sh [a-z]*.in 2>/dev/null | $SED 's,\.in$,,g' | uniq`
    scripts=$*

    dist=`cd "$dir" && set -- && for x in $scripts; do [ -f "$x.in" ] || set -- "$@" "$x"; done; echo $*`

    set -- `cd "$dir" && ls [a-z]*.in 2>/dev/null | grep -v Makefile`
    input=$*
    output=`set --; for fname in $input; do set -- "$@" "${fname%.in}"; done; echo $*`

    set -- `cd "$dir" && ls -d */ 2>/dev/null | $SED -e '/CMakeFiles/d' -e 's,/$,,g'`
    subdirs=$*

    scriptdir="shlib"

    case $subdir in 
      src*) scriptdir="bin" ;;
    esac

    echo "$MY_NAME: creating ${dir#./}/Makefile.am" 1>&2

    case $subdir in
      lib*) scriptdir="pkglib" targetdir="libdir" targetsubdir="sh${subdir#lib}" target="DATA" ;;
      src*) scriptdir="bin" targetdir= targetsubdir= target="SCRIPTS" ;;
    esac

    cat >$dir/Makefile.am <<EOF
# Automatically generated by $MY_NAME - Do not edit

${subdirs:+SUBDIRS = $subdirs
}${output:+GENERATED_FILES = $output
}${input:+INPUT_FILES = $input
}${dist:+DISTRIBUTED_FILES = $dist
}${input:+${output:+
}}
${targetdir:+${scriptdir}dir = \$($targetdir)${targetsubdir:+/$targetsubdir}
}
${scriptdir}_${target} = $scripts
${input:+noinst_DATA = \$(INPUT_FILES)
}EXTRA_DIST =${dist:+ \$(DISTRIBUTED_FILES)}${input:+ \$(INPUT_FILES)}

${output:+CLEANFILES = \$(GENERATED_FILES) stamp-init
}CONFIG_MAINTAINERCLEAN_FILES = Makefile.in

maintainer-clean-generic:
	rm -f Makefile.am

${output:+stamp-init: \$(INPUT_FILES) \$(top_builddir)/config.status
	cd \$(top_builddir) && ./config.status \`for file in \$(GENERATED_FILES); do echo $subdir/\$\$file; done\`
	touch \$@

\$(GENERATED_FILES): stamp-init

}maintainer-clean-am: distclean-am maintainer-clean-generic
	-rm -f \$(CONFIG_MAINTAINERCLEAN_FILES)
EOF

#   if ! isin $dir $dirs; then
     dirs="$dirs
$dir"
      MAKEFILES="${MAKEFILES:+$MAKEFILES\n}$PREPEND_ACOUTPUT$subdir/Makefile"
      FILES="${FILES:+$FILES\n}$PREPEND_ACOUTPUT$subdir/Makefile"
#   fi

    for i in $input; do
      FILES="$FILES\n$PREPEND_ACOUTPUT$subdir/${i%.in}"
    done
  done

  #echo "MAKEFILES:" $MAKEFILES 1>&2
  #echo "EXTRA_PREPEND:" $EXTRA_PREPEND 1>&2
  unset MAKEFILES

  $SED \
    -e "s,@EXTRA_BOOTSTRAP@,${ACINPUT_DIR:-.}," \
    -e "s,@EXTRA_PREPEND@,$PREPEND_ACOUTPUT," \
    -e "s,@EXTRA_FILES@,$FILES," \
    -e "s,@EXTRA_MAKEFILES@,$MAKEFILES," \
    $MY_DIR/configure.ac.in >$MY_DIR/${PREPEND_AGOUTPUT}configure.ac
}

cd "$MY_DIR/${PREPEND_AGOUTPUT}"


(PS4="$MY_NAME: executing "
 set -x
 aclocal --force -I ${ACINPUT_DIR:-"."}
 automake --force --copy --foreign --add-missing
 aclocal --force -I ${ACINPUT_DIR:-"."}
 autoconf --force) 2>&1 
