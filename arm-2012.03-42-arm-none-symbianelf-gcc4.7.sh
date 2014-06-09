#! /usr/bin/env bash
# This file contains the complete sequence of commands
# Mentor Graphics used to build this version of Sourcery CodeBench.
# 
# For each free or open-source component of Sourcery CodeBench,
# the source code provided includes all of the configuration
# scripts and makefiles for that component, including any and
# all modifications made by Mentor Graphics.  From this list of
# commands, you can see every configuration option used by
# Mentor Graphics during the build process.
# 
# This file is provided as a guideline for users who wish to
# modify and rebuild a free or open-source component of
# Sourcery CodeBench from source. For a number of reasons,
# though, you may not be able to successfully run this script
# directly on your system. Certain aspects of the Mentor Graphics
# build environment (such as directory names) are included in
# these commands. Mentor Graphics uses Canadian cross compilers so
# you may need to modify various configuration options and paths
# if you are building natively. This sequence of commands
# includes those used to build proprietary components of
# Sourcery CodeBench for which source code is not provided.
# 
# Please note that Sourcery CodeBench support covers only your
# use of the original, validated binaries provided as part of
# Sourcery CodeBench -- and specifically does not cover either
# the process of rebuilding a component or the use of any
# binaries you may build.  In addition, if you rebuild any
# component, you must not use the --with-pkgversion and
# --with-bugurl configuration options that embed Mentor Graphics
# trademarks in the resulting binary; see the "Mentor Graphics
# Trademarks" section in the Sourcery CodeBench Software
# License Agreement.
set -e
inform_fd=2 
umask 022
exec < /dev/null

error_handler ()
{
    exit 1
}

check_status() {
    local status="$?"
    if [ "$status" -ne 0 ]; then
	error_handler
    fi
}

check_pipe() {
    local -a status=("${PIPESTATUS[@]}")
    local limit=$1
    local ix
    
    if [ -z "$limit" ] ; then
	limit="${#status[@]}"
    fi
    for ((ix=0; ix != $limit ; ix++)); do
	if [ "${status[$ix]}" != "0" ] ; then
	    error_handler
	fi
    done
}

error () {
    echo "$script: error: $@" >& $inform_fd
    exit 1
}

warning () {
    echo "$script: warning: $@" >& $inform_fd
}

verbose () {
    if $gnu_verbose; then
	echo "$script: $@" >& $inform_fd
    fi
}

copy_dir() {
    mkdir -p "$2"

    (cd "$1" && tar cf - .) | (cd "$2" && tar xf -)
    check_pipe
}

copy_dir_clean() {
    mkdir -p "$2"
    (cd "$1" && tar cf - \
	--exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc \
	--exclude="*~" --exclude=".#*" \
	--exclude="*.orig" --exclude="*.rej" \
	.) | (cd "$2" && tar xf -)
    check_pipe
}

update_dir_clean() {
    mkdir -p "$2"


    (cd "$1" && tar cf - \
	--exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc \
	--exclude="*~" --exclude=".#*" \
	--exclude="*.orig" --exclude="*.rej" \
	--after-date="$3" \
	. 2> /dev/null) | (cd "$2" && tar xf -)
    check_pipe
}

copy_dir_exclude() {
    local source="$1"
    local dest="$2"
    local excl="$3"
    shift 3
    mkdir -p "$dest"
    (cd "$source" && tar cfX - "$excl" "$@") | (cd "$dest" && tar xf -)
    check_pipe
}

copy_dir_only() {
    local source="$1"
    local dest="$2"
    shift 2
    mkdir -p "$dest"
    (cd "$source" && tar cf - "$@") | (cd "$dest" && tar xf -)
    check_pipe
}

clean_environment() {
    local env_var_list
    local var




    unset BASH_ENV CDPATH POSIXLY_CORRECT TMOUT

    env_var_list=$(export | \
	grep '^declare -x ' | \
	sed -e 's/^declare -x //' -e 's/=.*//')

    for var in $env_var_list; do
	case $var in
	    HOME|HOSTNAME|LOGNAME|PWD|SHELL|SHLVL|SSH_*|TERM|USER)


		;;
	    LD_LIBRARY_PATH|PATH| \
		FLEXLM_NO_CKOUT_INSTALL_LIC|LM_APP_DISABLE_CACHE_READ)


		;;
	    MAKEINFO)

		;;
	    *_LICENSE_FILE)












		if [ "" ]; then
		    local license_file_envvar
		    license_file_envvar=

		    if [ "$var" != "$license_file_envvar" ]; then
			export -n "$var" || true
		    fi
		else
		    export -n "$var" || true
		fi
		;;
	    *)

		export -n "$var" || true
		;;
	esac
    done


    export LANG=C
    export LC_ALL=C


    export CVS_RSH=ssh



    user_shell=$SHELL
    export SHELL=$BASH
    export CONFIG_SHELL=$BASH
}

pushenv() {
    pushenv_level=$(($pushenv_level + 1))
    eval pushenv_vars_${pushenv_level}=
}


pushenv_level=0
pushenv_vars_0=



pushenvvar() {
    local pushenv_var="$1"
    local pushenv_newval="$2"
    eval local pushenv_oldval=\"\$$pushenv_var\"
    eval local pushenv_oldset=\"\${$pushenv_var+set}\"
    local pushenv_save_var=saved_${pushenv_level}_${pushenv_var}
    local pushenv_savep_var=savedp_${pushenv_level}_${pushenv_var}
    eval local pushenv_save_set=\"\${$pushenv_savep_var+set}\"
    if [ "$pushenv_save_set" = "set" ]; then
	error "Pushing $pushenv_var more than once at level $pushenv_level"
    fi
    if [ "$pushenv_oldset" = "set" ]; then
	eval $pushenv_save_var=\"\$pushenv_oldval\"
    else
	unset $pushenv_save_var
    fi
    eval $pushenv_savep_var=1
    eval export $pushenv_var=\"\$pushenv_newval\"
    local pushenv_list_var=pushenv_vars_${pushenv_level}
    eval $pushenv_list_var=\"\$$pushenv_list_var \$pushenv_var\"
}

prependenvvar() {
    local pushenv_var="$1"
    local pushenv_newval="$2"
    eval local pushenv_oldval=\"\$$pushenv_var\"
    pushenvvar "$pushenv_var" "$pushenv_newval$pushenv_oldval"
}

popenv() {
    local pushenv_var=
    eval local pushenv_vars=\"\$pushenv_vars_${pushenv_level}\"
    for pushenv_var in $pushenv_vars; do
	local pushenv_save_var=saved_${pushenv_level}_${pushenv_var}
	local pushenv_savep_var=savedp_${pushenv_level}_${pushenv_var}
	eval local pushenv_save_val=\"\$$pushenv_save_var\"
	eval local pushenv_save_set=\"\${$pushenv_save_var+set}\"
	unset $pushenv_save_var
	unset $pushenv_savep_var
	if [ "$pushenv_save_set" = "set" ]; then
	    eval export $pushenv_var=\"\$pushenv_save_val\"
	else
	    unset $pushenv_var
	fi
    done
    unset pushenv_vars_${pushenv_level}
    if [ "$pushenv_level" = "0" ]; then
	error "Popping environment level 0"
    else
	pushenv_level=$(($pushenv_level - 1))
    fi
}

prepend_path() {
    if $(eval "test -n \"\$$1\""); then
	prependenvvar "$1" "$2:"
    else
	prependenvvar "$1" "$2"
    fi
}
pushenvvar CSL_SCRIPTDIR /scratch/nsidwell/nokia/src/scripts-trunk
# pushenvvar PATH /usr/local/tools/gcc-4.3.3/bin
# pushenvvar LD_LIBRARY_PATH /usr/local/tools/gcc-4.3.3/x86_64-pc-linux-gnu/lib:/usr/local/tools/gcc-4.3.3/lib64:/usr/local/tools/gcc-4.3.3/lib
pushenvvar FLEXLM_NO_CKOUT_INSTALL_LIC 1
pushenvvar LM_APP_DISABLE_CACHE_READ 1
pushenvvar MAKEINFO 'makeinfo --css-ref=../cs.css'
clean_environment

echo Task: [01/74] /init/dirs
pushenv
# pushenvvar CC_FOR_BUILD gcc-4.7
mkdir -p /scratch/nsidwell/nokia/obj
mkdir -p /scratch/nsidwell/nokia/install
mkdir -p /scratch/nsidwell/nokia/pkg
mkdir -p /scratch/nsidwell/nokia/logs/data
popenv

echo Task: [02/74] /init/cleanup
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f /scratch/nsidwell/nokia/pkg/arm-2012.03-42-arm-none-symbianelf.src.tar.bz2 /scratch/nsidwell/nokia/pkg/arm-2012.03-42-arm-none-symbianelf.backup.tar.bz2
# Clean last install
rm -rf /scratch/nsidwell/nokia/install
rm -rf /scratch/nsidwell/nokia/logs
rm -rf /scratch/nsidwell/nokia/obj
popenv

echo Task: [03/74] /init/source_package/binutils
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/binutils-2012.03-42.tar.bz2
mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd /scratch/nsidwell/nokia/src
tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/binutils-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' binutils-2012.03
popd
popenv

echo Task: [04/74] /init/source_package/gcc
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/gcc-2012.03-42.tar.bz2
mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd /scratch/nsidwell/nokia/src
tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/gcc-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' gcc-4.6-2012.03
popd
popenv

echo Task: [05/74] /init/source_package/zlib
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/zlib-2012.03-42.tar.bz2
mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd /scratch/nsidwell/nokia/src
tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/zlib-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' zlib-1.2.3
popd
popenv

echo Task: [06/74] /init/source_package/gmp
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/gmp-2012.03-42.tar.bz2
mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd /scratch/nsidwell/nokia/src
tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/gmp-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' gmp-2012.03
popd
popenv

echo Task: [07/74] /init/source_package/mpfr
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/mpfr-2012.03-42.tar.bz2
mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd /scratch/nsidwell/nokia/src
tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/mpfr-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' mpfr-2012.03
popd
popenv

echo Task: [08/74] /init/source_package/mpc
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/mpc-2012.03-42.tar.bz2
mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd /scratch/nsidwell/nokia/src
tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/mpc-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' mpc-0.9
popd
popenv

echo Task: [09/74] /init/source_package/cloog
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/cloog-2012.03-42.tar.bz2
mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd /scratch/nsidwell/nokia/src
tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/cloog-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' cloog-0.15
popd
popenv

echo Task: [10/74] /init/source_package/ppl
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/ppl-2012.03-42.tar.bz2
mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd /scratch/nsidwell/nokia/src
tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/ppl-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' ppl-0.11
popd
popenv

echo Task: [11/74] /init/source_package/getting_started
#pushenv
#pushenvvar CC_FOR_BUILD gcc-4.7
#rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-#symbianelf.backup/getting_started-2012.03-42.tar.bz2
#mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup
#pushd /scratch/nsidwell/nokia/src
#tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup/getting_started-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' getting-started-2012.03
#popd
#popenv

echo Task: [12/74] /init/source_package/installanywhere
#pushenv
#pushenvvar CC_FOR_BUILD gcc-4.7
#rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup/installanywhere-2012.03-42.tar.bz2
#mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup
#pushd /scratch/nsidwell/nokia/src
#tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup/installanywhere-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' installanywhere-trunk
#popd
#popenv

echo Task: [13/74] /init/source_package/csl_tests
#pushenv
#pushenvvar CC_FOR_BUILD gcc-4.7
#rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup/csl_tests-2012.03-42.tar.bz2
#mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup
#pushd /scratch/nsidwell/nokia/src
#tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup/csl_tests-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' csl-tests-trunk
#popd
#popenv

echo Task: [14/74] /init/source_package/dejagnu_boards
#pushenv
#pushenvvar CC_FOR_BUILD gcc-4.7
#rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-#symbianelf.backup/dejagnu_boards-2012.03-42.tar.bz2
#mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-#symbianelf.backup
#pushd /scratch/nsidwell/nokia/src
#tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup/dejagnu_boards-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' dejagnu-boards-trunk
#popd
#popenv

echo Task: [15/74] /init/source_package/scripts
#pushenv
#pushenvvar CC_FOR_BUILD gcc-4.7
#rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup/scripts-2012.03-42.tar.bz2
#mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup
#pushd /scratch/nsidwell/nokia/src
#tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup/scripts-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' scripts-trunk
#popd
#popenv

echo Task: [16/74] /init/source_package/xfails
#pushenv
#pushenvvar CC_FOR_BUILD gcc-4.7
#rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup/xfails-2012.03-42.tar.bz2
#mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup
#pushd /scratch/nsidwell/nokia/src
#tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup/xfails-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' xfails-trunk
#popd
#popenv

echo Task: [17/74] /init/source_package/portal
#pushenv
#pushenvvar CC_FOR_BUILD gcc-4.7
#rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup/portal-2012.03-42.tar.bz2
#mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup
#pushd /scratch/nsidwell/nokia/src
#tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf.backup/portal-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' portal-trunk
#popd
#popenv

echo Task: [18/74] /init/source_package/libiconv
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/libiconv-2012.03-42.tar.bz2
mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd /scratch/nsidwell/nokia/src
tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/libiconv-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' libiconv-1.11
popd
popenv

echo Task: [19/74] /init/source_package/libelf
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/libelf-2012.03-42.tar.bz2
mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd /scratch/nsidwell/nokia/src
tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/libelf-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' libelf-2012.03
popd
popenv

echo Task: [23/74] /init/source_package/coreutils
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/coreutils-2012.03-42.tar.bz2
mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd /scratch/nsidwell/nokia/src
tar cf /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/coreutils-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' coreutils-5.94
popd
popenv

echo Task: [24/74] /x86_64-pc-linux-gnu/host_cleanup
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
popenv

echo Task: [25/74] /x86_64-pc-linux-gnu/zlib_first/copy
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
rm -rf /scratch/nsidwell/nokia/obj/zlib-first-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
copy_dir_clean /scratch/nsidwell/nokia/src/zlib-1.2.3 /scratch/nsidwell/nokia/obj/zlib-first-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
chmod -R u+w /scratch/nsidwell/nokia/obj/zlib-first-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
popenv

echo Task: [26/74] /x86_64-pc-linux-gnu/zlib_first/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushd /scratch/nsidwell/nokia/obj/zlib-first-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushenv
pushenvvar CFLAGS '-O3 -fPIC'
pushenvvar CC 'gcc-4.7 '
pushenvvar AR 'ar rc'
pushenvvar RANLIB ranlib
./configure --prefix=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr
popenv
popd
popenv

echo Task: [27/74] /x86_64-pc-linux-gnu/zlib_first/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushd /scratch/nsidwell/nokia/obj/zlib-first-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv

echo Task: [28/74] /x86_64-pc-linux-gnu/zlib_first/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushd /scratch/nsidwell/nokia/obj/zlib-first-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv

echo Task: [29/74] /x86_64-pc-linux-gnu/gmp/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushenvvar CFLAGS '-g -O2'
rm -rf /scratch/nsidwell/nokia/obj/gmp-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p /scratch/nsidwell/nokia/obj/gmp-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd /scratch/nsidwell/nokia/obj/gmp-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
/scratch/nsidwell/nokia/src/gmp-2012.03/configure --prefix=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-shared --build=x86_64-pc-linux-gnu --target=x86_64-pc-linux-gnu --host=x86_64-pc-linux-gnu --enable-cxx --disable-nls
popd
popenv
popenv
popenv

echo Task: [30/74] /x86_64-pc-linux-gnu/gmp/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushenvvar CFLAGS '-g -O2'
pushd /scratch/nsidwell/nokia/obj/gmp-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [31/74] /x86_64-pc-linux-gnu/gmp/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushenvvar CFLAGS '-g -O2'
pushd /scratch/nsidwell/nokia/obj/gmp-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv
popenv
popenv

echo Task: [32/74] /x86_64-pc-linux-gnu/gmp/postinstall
# on 64-bit, 1 of 58 tests fails (t-scan)
#pushenv
#pushenvvar CC_FOR_BUILD gcc-4.7
#pushenvvar CC gcc-4.7
#pushenvvar CXX g++-4.7
#pushenvvar AR ar
#pushenvvar RANLIB ranlib
#prepend_path PATH /scratch/nsidwell/nokia/install/bin
#pushenv
#pushenv
#pushenvvar CFLAGS '-g -O2'
#pushd /scratch/nsidwell/nokia/obj/gmp-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
#make check
#popd
#popenv
#popenv
#popenv

echo Task: [33/74] /x86_64-pc-linux-gnu/mpfr/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
rm -rf /scratch/nsidwell/nokia/obj/mpfr-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p /scratch/nsidwell/nokia/obj/mpfr-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd /scratch/nsidwell/nokia/obj/mpfr-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
/scratch/nsidwell/nokia/src/mpfr-2012.03/configure --prefix=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-shared --build=x86_64-pc-linux-gnu --target=arm-none-symbianelf --host=x86_64-pc-linux-gnu --disable-nls --with-gmp=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr
popd
popenv
popenv
popenv

echo Task: [34/74] /x86_64-pc-linux-gnu/mpfr/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushd /scratch/nsidwell/nokia/obj/mpfr-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [35/74] /x86_64-pc-linux-gnu/mpfr/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushd /scratch/nsidwell/nokia/obj/mpfr-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv
popenv
popenv

echo Task: [36/74] /x86_64-pc-linux-gnu/mpfr/postinstall
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushd /scratch/nsidwell/nokia/obj/mpfr-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make check
popd
popenv
popenv
popenv

echo Task: [37/74] /x86_64-pc-linux-gnu/mpc/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
rm -rf /scratch/nsidwell/nokia/obj/mpc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p /scratch/nsidwell/nokia/obj/mpc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd /scratch/nsidwell/nokia/obj/mpc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
/scratch/nsidwell/nokia/src/mpc-0.9/configure --prefix=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-shared --build=x86_64-pc-linux-gnu --target=arm-none-symbianelf --host=x86_64-pc-linux-gnu --disable-nls --with-gmp=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-mpfr=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr
popd
popenv
popenv
popenv

echo Task: [38/74] /x86_64-pc-linux-gnu/mpc/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushd /scratch/nsidwell/nokia/obj/mpc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [39/74] /x86_64-pc-linux-gnu/mpc/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushd /scratch/nsidwell/nokia/obj/mpc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv
popenv
popenv

echo Task: [40/74] /x86_64-pc-linux-gnu/mpc/postinstall
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushd /scratch/nsidwell/nokia/obj/mpc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make check
popd
popenv
popenv
popenv

echo Task: [41/74] /x86_64-pc-linux-gnu/ppl/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
rm -rf /scratch/nsidwell/nokia/obj/ppl-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p /scratch/nsidwell/nokia/obj/ppl-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd /scratch/nsidwell/nokia/obj/ppl-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
/scratch/nsidwell/nokia/src/ppl-0.11/configure --prefix=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-shared --build=x86_64-pc-linux-gnu --target=arm-none-symbianelf --host=x86_64-pc-linux-gnu --disable-nls --with-libgmp-prefix=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-gmp-prefix=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr CPPFLAGS=-I/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include LDFLAGS=-L/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib --disable-watchdog
popd
popenv
popenv
popenv

echo Task: [42/74] /x86_64-pc-linux-gnu/ppl/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushd /scratch/nsidwell/nokia/obj/ppl-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [43/74] /x86_64-pc-linux-gnu/ppl/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushd /scratch/nsidwell/nokia/obj/ppl-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv
popenv
popenv

echo Task: [44/74] /x86_64-pc-linux-gnu/cloog/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
rm -rf /scratch/nsidwell/nokia/obj/cloog-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p /scratch/nsidwell/nokia/obj/cloog-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd /scratch/nsidwell/nokia/obj/cloog-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
/scratch/nsidwell/nokia/src/cloog-0.15/configure --prefix=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-shared --build=x86_64-pc-linux-gnu --target=arm-none-symbianelf --host=x86_64-pc-linux-gnu --disable-nls --with-ppl=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-gmp=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr
popd
popenv
popenv
popenv

echo Task: [45/74] /x86_64-pc-linux-gnu/cloog/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushd /scratch/nsidwell/nokia/obj/cloog-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [46/74] /x86_64-pc-linux-gnu/cloog/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushd /scratch/nsidwell/nokia/obj/cloog-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv
popenv
popenv

echo Task: [47/74] /x86_64-pc-linux-gnu/cloog/postinstall
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushd /scratch/nsidwell/nokia/obj/cloog-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make check
popd
popenv
popenv
popenv

echo Task: [48/74] /x86_64-pc-linux-gnu/libelf/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
rm -rf /scratch/nsidwell/nokia/obj/libelf-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p /scratch/nsidwell/nokia/obj/libelf-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd /scratch/nsidwell/nokia/obj/libelf-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
/scratch/nsidwell/nokia/src/libelf-2012.03/configure --prefix=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-shared --build=x86_64-pc-linux-gnu --target=arm-none-symbianelf --host=x86_64-pc-linux-gnu --disable-nls
popd
popenv
popenv
popenv

echo Task: [49/74] /x86_64-pc-linux-gnu/libelf/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushd /scratch/nsidwell/nokia/obj/libelf-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [50/74] /x86_64-pc-linux-gnu/libelf/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushd /scratch/nsidwell/nokia/obj/libelf-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv
popenv
popenv

echo Task: [51/74] /x86_64-pc-linux-gnu/toolchain/binutils/copy
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
rm -rf /scratch/nsidwell/nokia/obj/binutils-src-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
copy_dir_clean /scratch/nsidwell/nokia/src/binutils-2012.03 /scratch/nsidwell/nokia/obj/binutils-src-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
chmod -R u+w /scratch/nsidwell/nokia/obj/binutils-src-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
touch /scratch/nsidwell/nokia/obj/binutils-src-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/.gnu-stamp
popenv
popenv
popenv

echo Task: [52/74] /x86_64-pc-linux-gnu/toolchain/binutils/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
rm -rf /scratch/nsidwell/nokia/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p /scratch/nsidwell/nokia/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd /scratch/nsidwell/nokia/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
/scratch/nsidwell/nokia/obj/binutils-src-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/configure --prefix=/opt/codesourcery --build=x86_64-pc-linux-gnu --target=arm-none-symbianelf --host=x86_64-pc-linux-gnu '--with-pkgversion=Sourcery CodeBench Lite 2012.03-42' --with-bugurl=https://support.codesourcery.com/GNUToolchain/ --disable-nls --enable-poison-system-directories
popd
popenv
popenv
popenv

echo Task: [53/74] /x86_64-pc-linux-gnu/toolchain/binutils/libiberty
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
pushd /scratch/nsidwell/nokia/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4 all-libiberty
popd
copy_dir_clean /scratch/nsidwell/nokia/src/binutils-2012.03/include /scratch/nsidwell/nokia/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
chmod -R u+w /scratch/nsidwell/nokia/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
mkdir -p /scratch/nsidwell/nokia/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
cp /scratch/nsidwell/nokia/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/libiberty/libiberty.a /scratch/nsidwell/nokia/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
popenv
popenv
popenv

echo Task: [54/74] /x86_64-pc-linux-gnu/toolchain/binutils/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
pushd /scratch/nsidwell/nokia/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [55/74] /x86_64-pc-linux-gnu/toolchain/binutils/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
pushd /scratch/nsidwell/nokia/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install prefix=/scratch/nsidwell/nokia/install exec_prefix=/scratch/nsidwell/nokia/install libdir=/scratch/nsidwell/nokia/install/lib datadir=/scratch/nsidwell/nokia/install/share
popd
popenv
popenv
popenv

echo Task: [56/74] /x86_64-pc-linux-gnu/toolchain/binutils/postinstall
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
pushd /scratch/nsidwell/nokia/install
rm ./lib/libiberty.a
rmdir ./lib
popd
pushd /scratch/nsidwell/nokia/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make prefix=/scratch/nsidwell/nokia/install exec_prefix=/scratch/nsidwell/nokia/install libdir=/scratch/nsidwell/nokia/install/lib datadir=/scratch/nsidwell/nokia/install/share install-html
popd
pushd /scratch/nsidwell/nokia/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make prefix=/scratch/nsidwell/nokia/install exec_prefix=/scratch/nsidwell/nokia/install libdir=/scratch/nsidwell/nokia/install/lib datadir=/scratch/nsidwell/nokia/install/share install-pdf
popd
cp /scratch/nsidwell/nokia/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/bfd/.libs/libbfd.a /scratch/nsidwell/nokia/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
cp /scratch/nsidwell/nokia/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/bfd/bfd.h /scratch/nsidwell/nokia/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
cp /scratch/nsidwell/nokia/src/binutils-2012.03/bfd/elf-bfd.h /scratch/nsidwell/nokia/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
cp /scratch/nsidwell/nokia/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/opcodes/.libs/libopcodes.a /scratch/nsidwell/nokia/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
rm -f /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-ld.bfd
rm -f /scratch/nsidwell/nokia/install/bin/ld.bfd
rm -f /scratch/nsidwell/nokia/install/arm-none-symbianelf/bin/ld.bfd
popenv
popenv
popenv

echo Task: [57/74] /x86_64-pc-linux-gnu/toolchain/gcc_final/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
rm -rf /scratch/nsidwell/nokia/obj/gcc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p /scratch/nsidwell/nokia/obj/gcc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd /scratch/nsidwell/nokia/obj/gcc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
/scratch/nsidwell/nokia/src/gcc-4.6-2012.03/configure --build=x86_64-pc-linux-gnu --host=x86_64-pc-linux-gnu --target=arm-none-symbianelf --enable-threads --disable-libmudflap --disable-libssp --disable-libstdcxx-pch --with-gnu-as --with-gnu-ld '--with-specs=%{save-temps: -fverbose-asm} -D__CS_SOURCERYGXX_MAJ__=2012 -D__CS_SOURCERYGXX_MIN__=3 -D__CS_SOURCERYGXX_REV__=42' --enable-languages=c,c++ --enable-shared --disable-hosted-libstdcxx '--with-pkgversion=Sacha GCC 4.7.3' --with-bugurl=http://github.com/xsacha/SymbianGCC --disable-nls --prefix=/opt/codesourcery --with-gmp=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-mpfr=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-mpc=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-ppl=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr '--with-host-libstdcxx=-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm' --with-cloog=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-libelf=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-libgomp --with-build-time-tools=/scratch/nsidwell/nokia/install/arm-none-symbianelf/bin --with-build-time-tools=/scratch/nsidwell/nokia/install/arm-none-symbianelf/bin
popd
popenv
popenv

echo Task: [58/74] /x86_64-pc-linux-gnu/toolchain/gcc_final/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
pushd /scratch/nsidwell/nokia/obj/gcc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv

echo Task: [59/74] /x86_64-pc-linux-gnu/toolchain/gcc_final/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
pushd /scratch/nsidwell/nokia/obj/gcc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make prefix=/scratch/nsidwell/nokia/install exec_prefix=/scratch/nsidwell/nokia/install libdir=/scratch/nsidwell/nokia/install/lib  install
make prefix=/scratch/nsidwell/nokia/install exec_prefix=/scratch/nsidwell/nokia/install libdir=/scratch/nsidwell/nokia/install/lib  install-html
make prefix=/scratch/nsidwell/nokia/install exec_prefix=/scratch/nsidwell/nokia/install libdir=/scratch/nsidwell/nokia/install/lib  install-pdf
popd
popenv
popenv

echo Task: [60/74] /x86_64-pc-linux-gnu/toolchain/gcc_final/postinstall
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushenv
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
pushd /scratch/nsidwell/nokia/install
rm ./lib/libiberty.a
rmdir include
popd
popenv
popenv

echo Task: [61/74] /x86_64-pc-linux-gnu/toolchain/zlib/0/copy
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
rm -rf /scratch/nsidwell/nokia/obj/zlib-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
copy_dir_clean /scratch/nsidwell/nokia/src/zlib-1.2.3 /scratch/nsidwell/nokia/obj/zlib-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
chmod -R u+w /scratch/nsidwell/nokia/obj/zlib-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
popenv

echo Task: [62/74] /x86_64-pc-linux-gnu/toolchain/zlib/0/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushd /scratch/nsidwell/nokia/obj/zlib-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushenv
pushenvvar CFLAGS '-O3 -fPIC'
pushenvvar CC 'gcc-4.7 '
pushenvvar AR 'ar rc'
pushenvvar RANLIB ranlib
./configure --prefix=/scratch/nsidwell/nokia/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr
popenv
popd
popenv

echo Task: [63/74] /x86_64-pc-linux-gnu/toolchain/zlib/0/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushd /scratch/nsidwell/nokia/obj/zlib-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv

echo Task: [64/74] /x86_64-pc-linux-gnu/toolchain/zlib/0/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushd /scratch/nsidwell/nokia/obj/zlib-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv

echo Task: [65/74] /x86_64-pc-linux-gnu/finalize_libc_installation
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
popenv

echo Task: [66/74] /x86_64-pc-linux-gnu/pretidy_installation
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushd /scratch/nsidwell/nokia/install
popd
popenv

echo Task: [67/74] /x86_64-pc-linux-gnu/remove_libtool_archives
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
find /scratch/nsidwell/nokia/install -name '*.la' -exec rm '{}' ';'
popenv

echo Task: [68/74] /x86_64-pc-linux-gnu/remove_copied_libs
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
popenv

echo Task: [69/74] /x86_64-pc-linux-gnu/remove_fixed_headers
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
pushd /scratch/nsidwell/nokia/install/lib/gcc/arm-none-symbianelf/4.7.3/include-fixed
popd
popenv

echo Task: [70/74] /x86_64-pc-linux-gnu/add_tooldir_readme
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
cat > /scratch/nsidwell/nokia/install/arm-none-symbianelf/bin/README.txt <<'EOF0'
The executables in this directory are for internal use by the compiler
and may not operate correctly when used directly.  This directory
should not be placed on your PATH.  Instead, you should use the
executables in ../../bin/ and place that directory on your PATH.
EOF0
popenv

echo Task: [71/74] /x86_64-pc-linux-gnu/strip_host_objects
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-addr2line
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-ar
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-as
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-c++
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-c++filt
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-cpp
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-elfedit
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-g++
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-gcc
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-gcc-4.7.3
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-gcov
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-gprof
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-ld
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-nm
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-objcopy
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-objdump
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-ranlib
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-readelf
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-size
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-strings
strip /scratch/nsidwell/nokia/install/bin/arm-none-symbianelf-strip
strip /scratch/nsidwell/nokia/install/arm-none-symbianelf/bin/ar
strip /scratch/nsidwell/nokia/install/arm-none-symbianelf/bin/as
strip /scratch/nsidwell/nokia/install/arm-none-symbianelf/bin/c++
strip /scratch/nsidwell/nokia/install/arm-none-symbianelf/bin/g++
strip /scratch/nsidwell/nokia/install/arm-none-symbianelf/bin/gcc
strip /scratch/nsidwell/nokia/install/arm-none-symbianelf/bin/ld
strip /scratch/nsidwell/nokia/install/arm-none-symbianelf/bin/nm
strip /scratch/nsidwell/nokia/install/arm-none-symbianelf/bin/objcopy
strip /scratch/nsidwell/nokia/install/arm-none-symbianelf/bin/objdump
strip /scratch/nsidwell/nokia/install/arm-none-symbianelf/bin/ranlib
strip /scratch/nsidwell/nokia/install/arm-none-symbianelf/bin/strip
strip /scratch/nsidwell/nokia/install/libexec/gcc/arm-none-symbianelf/4.7.3/cc1
strip /scratch/nsidwell/nokia/install/libexec/gcc/arm-none-symbianelf/4.7.3/collect2
strip /scratch/nsidwell/nokia/install/libexec/gcc/arm-none-symbianelf/4.7.3/install-tools/fixincl
strip /scratch/nsidwell/nokia/install/libexec/gcc/arm-none-symbianelf/4.7.3/cc1plus
strip /scratch/nsidwell/nokia/install/libexec/gcc/arm-none-symbianelf/4.7.3/lto-wrapper
strip /scratch/nsidwell/nokia/install/libexec/gcc/arm-none-symbianelf/4.7.3/lto1
popenv

echo Task: [72/74] /x86_64-pc-linux-gnu/strip_target_objects
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc /scratch/nsidwell/nokia/install/arm-none-symbianelf/lib/libsupc++.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc /scratch/nsidwell/nokia/install/arm-none-symbianelf/lib/libgcc_s.dll || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc /scratch/nsidwell/nokia/install/arm-none-symbianelf/lib/softfp/libsupc++.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc /scratch/nsidwell/nokia/install/arm-none-symbianelf/lib/softfp/libgcc_s.dll || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc /scratch/nsidwell/nokia/install/lib/gcc/arm-none-symbianelf/4.7.3/libgcc.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc /scratch/nsidwell/nokia/install/lib/gcc/arm-none-symbianelf/4.7.3/libgcov.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc /scratch/nsidwell/nokia/install/lib/gcc/arm-none-symbianelf/4.7.3/softfp/libgcc.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc /scratch/nsidwell/nokia/install/lib/gcc/arm-none-symbianelf/4.7.3/softfp/libgcov.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc /scratch/nsidwell/nokia/install/lib/gcc/arm-none-symbianelf/4.7.3/softfp/libgcc_eh.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc /scratch/nsidwell/nokia/install/lib/gcc/arm-none-symbianelf/4.7.3/libgcc_eh.a || true
popenv

echo Task: [73/74] /x86_64-pc-linux-gnu/package_tbz2
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH /scratch/nsidwell/nokia/install/bin
rm -f /scratch/nsidwell/nokia/pkg/arm-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu.tar.bz2
pushd /scratch/nsidwell/nokia/obj
rm -f arm-2012.03
ln -s /scratch/nsidwell/nokia/install arm-2012.03
tar cjf /scratch/nsidwell/nokia/pkg/arm-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu.tar.bz2 --owner=0 --group=0 --exclude=host-x86_64-pc-linux-gnu --exclude=host-x86_64-mingw32 arm-2012.03/arm-none-symbianelf arm-2012.03/bin arm-2012.03/lib arm-2012.03/libexec arm-2012.03/share
rm -f arm-2012.03
popd
popenv

echo Task: [74/74] /fini/sources_package
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
mkdir -p /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
cp /scratch/nsidwell/nokia/obj/gnu-2012.03-42-arm-none-symbianelf.txt /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
cp /scratch/nsidwell/nokia/logs/arm-2012.03-42-arm-none-symbianelf.sh /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd /scratch/nsidwell/nokia/obj/pkg-2012.03-42-arm-none-symbianelf
tar cjf /scratch/nsidwell/nokia/pkg/arm-2012.03-42-arm-none-symbianelf.src.tar.bz2 --owner=0 --group=0 arm-2012.03-42-arm-none-symbianelf
popd

