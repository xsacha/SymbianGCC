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

# modified by xsacha to work for 64-bit Linux GCC 4.8.3
# Configuration:
# Build Directory
BUILD="$(pwd)"

# GCC Target Version
GCC_VER=4.8.3


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
pushenvvar CSL_SCRIPTDIR ${BUILD}/src/scripts-trunk
pushenvvar FLEXLM_NO_CKOUT_INSTALL_LIC 1
pushenvvar LM_APP_DISABLE_CACHE_READ 1
pushenvvar MAKEINFO 'makeinfo --css-ref=../cs.css'
clean_environment

echo Task: [01/62] /init/dirs
pushenv
mkdir -p ${BUILD}/obj
mkdir -p ${BUILD}/install
mkdir -p ${BUILD}/pkg
mkdir -p ${BUILD}/logs/data
popenv

echo Task: [02/62] /init/cleanup
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f ${BUILD}/pkg/arm-2012.03-42-arm-none-symbianelf.src.tar.bz2 ${BUILD}/pkg/arm-2012.03-42-arm-none-symbianelf.backup.tar.bz2
# Clean last install
rm -rf ${BUILD}/install
rm -rf ${BUILD}/logs
rm -rf ${BUILD}/obj
popenv

echo Task: [03/62] /init/source_package/binutils
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/binutils-2012.03-42.tar.bz2
mkdir -p ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd ${BUILD}/src
tar cf ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/binutils-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' binutils-2012.03
popd
popenv

echo Task: [04/62] /init/source_package/gcc
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/gcc-2012.03-42.tar.bz2
mkdir -p ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd ${BUILD}/src
tar cf ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/gcc-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' gcc-4.6-2012.03
popd
popenv

echo Task: [05/62] /init/source_package/zlib
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/zlib-2012.03-42.tar.bz2
mkdir -p ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd ${BUILD}/src
tar cf ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/zlib-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' zlib-1.2.3
popd
popenv

echo Task: [06/62] /init/source_package/gmp
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/gmp-2012.03-42.tar.bz2
mkdir -p ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd ${BUILD}/src
tar cf ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/gmp-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' gmp-2012.03
popd
popenv

echo Task: [07/62] /init/source_package/mpfr
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/mpfr-2012.03-42.tar.bz2
mkdir -p ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd ${BUILD}/src
tar cf ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/mpfr-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' mpfr-2012.03
popd
popenv

echo Task: [08/62] /init/source_package/mpc
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/mpc-2012.03-42.tar.bz2
mkdir -p ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd ${BUILD}/src
tar cf ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/mpc-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' mpc-0.9
popd
popenv

echo Task: [09/62] /init/source_package/cloog
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/cloog-2012.03-42.tar.bz2
mkdir -p ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd ${BUILD}/src
tar cf ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/cloog-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' cloog-0.15
popd
popenv

echo Task: [10/62] /init/source_package/ppl
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/ppl-2012.03-42.tar.bz2
mkdir -p ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd ${BUILD}/src
tar cf ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/ppl-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' ppl-0.11
popd
popenv

echo Task: [11/62] /init/source_package/libiconv
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/libiconv-2012.03-42.tar.bz2
mkdir -p ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd ${BUILD}/src
tar cf ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/libiconv-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' libiconv-1.11
popd
popenv

echo Task: [12/62] /init/source_package/libelf
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/libelf-2012.03-42.tar.bz2
mkdir -p ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd ${BUILD}/src
tar cf ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/libelf-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' libelf-2012.03
popd
popenv

echo Task: [13/62] /init/source_package/coreutils
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
rm -f ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/coreutils-2012.03-42.tar.bz2
mkdir -p ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf
pushd ${BUILD}/src
tar cf ${BUILD}/obj/pkg-2012.03-42-arm-none-symbianelf/arm-2012.03-42-arm-none-symbianelf/coreutils-2012.03-42.tar.bz2 --bzip2 --owner=0 --group=0 --exclude=CVS --exclude=.svn --exclude=.git --exclude=.pc '--exclude=*~' '--exclude=.#*' '--exclude=*.orig' '--exclude=*.rej' coreutils-5.94
popd
popenv

echo Task: [14/62] /x86_64-pc-linux-gnu/host_cleanup
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
popenv

echo Task: [15/62] /x86_64-pc-linux-gnu/zlib_first/copy
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
rm -rf ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
copy_dir_clean ${BUILD}/src/zlib-1.2.3 ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
chmod -R u+w ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
popenv

echo Task: [16/62] /x86_64-pc-linux-gnu/zlib_first/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushd ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushenv
pushenvvar CFLAGS '-O3 -fPIC'
pushenvvar CC 'gcc-4.7 '
pushenvvar AR 'ar rc'
pushenvvar RANLIB ranlib
./configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr
popenv
popd
popenv

echo Task: [17/62] /x86_64-pc-linux-gnu/zlib_first/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushd ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv

echo Task: [18/62] /x86_64-pc-linux-gnu/zlib_first/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushd ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv

echo Task: [19/62] /x86_64-pc-linux-gnu/gmp/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushenvvar CFLAGS '-g -O2'
rm -rf ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
${BUILD}/src/gmp-2012.03/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-shared --build=x86_64-pc-linux-gnu --target=x86_64-pc-linux-gnu --host=x86_64-pc-linux-gnu --enable-cxx --disable-nls
popd
popenv
popenv
popenv

echo Task: [20/62] /x86_64-pc-linux-gnu/gmp/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushenvvar CFLAGS '-g -O2'
pushd ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [21/62] /x86_64-pc-linux-gnu/gmp/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushenvvar CFLAGS '-g -O2'
pushd ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv
popenv
popenv

#echo Task: [22/62] /x86_64-pc-linux-gnu/gmp/postinstall
# on 64-bit, 1 of 58 tests fails (t-scan)
#pushenv
#pushenvvar CC_FOR_BUILD gcc-4.7
#pushenvvar CC gcc-4.7
#pushenvvar CXX g++-4.7
#pushenvvar AR ar
#pushenvvar RANLIB ranlib
#prepend_path PATH ${BUILD}/install/bin
#pushenv
#pushenv
#pushenvvar CFLAGS '-g -O2'
#pushd ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
#make check
#popd
#popenv
#popenv
#popenv

echo Task: [22/62] /x86_64-pc-linux-gnu/mpfr/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
${BUILD}/src/mpfr-2012.03/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-shared --build=x86_64-pc-linux-gnu --target=arm-none-symbianelf --host=x86_64-pc-linux-gnu --disable-nls --with-gmp=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr
popd
popenv
popenv
popenv

echo Task: [23/62] /x86_64-pc-linux-gnu/mpfr/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushd ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [24/62] /x86_64-pc-linux-gnu/mpfr/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushd ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv
popenv
popenv

echo Task: [25/62] /x86_64-pc-linux-gnu/mpfr/postinstall
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushd ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make check
popd
popenv
popenv
popenv

echo Task: [26/62] /x86_64-pc-linux-gnu/mpc/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
${BUILD}/src/mpc-0.9/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-shared --build=x86_64-pc-linux-gnu --target=arm-none-symbianelf --host=x86_64-pc-linux-gnu --disable-nls --with-gmp=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-mpfr=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr
popd
popenv
popenv
popenv

echo Task: [27/62] /x86_64-pc-linux-gnu/mpc/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushd ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [28/62] /x86_64-pc-linux-gnu/mpc/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushd ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv
popenv
popenv

echo Task: [29/62] /x86_64-pc-linux-gnu/mpc/postinstall
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushd ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make check
popd
popenv
popenv
popenv

echo Task: [30/62] /x86_64-pc-linux-gnu/ppl/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
${BUILD}/src/ppl-0.11/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-shared --build=x86_64-pc-linux-gnu --target=arm-none-symbianelf --host=x86_64-pc-linux-gnu --disable-nls --with-libgmp-prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-gmp-prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr CPPFLAGS=-I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include LDFLAGS=-L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib --disable-watchdog
popd
popenv
popenv
popenv

echo Task: [31/62] /x86_64-pc-linux-gnu/ppl/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushd ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [32/62] /x86_64-pc-linux-gnu/ppl/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushd ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv
popenv
popenv

echo Task: [33/62] /x86_64-pc-linux-gnu/cloog/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
${BUILD}/src/cloog-0.15/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-shared --build=x86_64-pc-linux-gnu --target=arm-none-symbianelf --host=x86_64-pc-linux-gnu --disable-nls --with-ppl=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-gmp=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr
popd
popenv
popenv
popenv

echo Task: [34/62] /x86_64-pc-linux-gnu/cloog/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushd ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [35/62] /x86_64-pc-linux-gnu/cloog/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushd ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv
popenv
popenv

echo Task: [36/62] /x86_64-pc-linux-gnu/cloog/postinstall
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushd ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make check
popd
popenv
popenv
popenv

echo Task: [37/62] /x86_64-pc-linux-gnu/libelf/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
${BUILD}/src/libelf-2012.03/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-shared --build=x86_64-pc-linux-gnu --target=arm-none-symbianelf --host=x86_64-pc-linux-gnu --disable-nls
popd
popenv
popenv
popenv

echo Task: [38/62] /x86_64-pc-linux-gnu/libelf/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushd ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [39/62] /x86_64-pc-linux-gnu/libelf/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushd ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv
popenv
popenv

echo Task: [40/62] /x86_64-pc-linux-gnu/toolchain/binutils/copy
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
rm -rf ${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
copy_dir_clean ${BUILD}/src/binutils-2012.03 ${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
chmod -R u+w ${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
touch ${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/.gnu-stamp
popenv
popenv
popenv

echo Task: [41/62] /x86_64-pc-linux-gnu/toolchain/binutils/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
rm -rf ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/configure --prefix=/opt/codesourcery --build=x86_64-pc-linux-gnu --target=arm-none-symbianelf --host=x86_64-pc-linux-gnu '--with-pkgversion=Sourcery CodeBench Lite 2012.03-42' --with-bugurl=https://support.codesourcery.com/GNUToolchain/ --disable-nls --enable-poison-system-directories
popd
popenv
popenv
popenv

echo Task: [42/62] /x86_64-pc-linux-gnu/toolchain/binutils/libiberty
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4 all-libiberty
popd
copy_dir_clean ${BUILD}/src/binutils-2012.03/include ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
chmod -R u+w ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
mkdir -p ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
cp ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/libiberty/libiberty.a ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
popenv
popenv
popenv

echo Task: [43/62] /x86_64-pc-linux-gnu/toolchain/binutils/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv
popenv

echo Task: [44/62] /x86_64-pc-linux-gnu/toolchain/binutils/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install prefix=${BUILD}/install exec_prefix=${BUILD}/install libdir=${BUILD}/install/lib datadir=${BUILD}/install/share
popd
popenv
popenv
popenv

echo Task: [45/62] /x86_64-pc-linux-gnu/toolchain/binutils/postinstall
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
pushd ${BUILD}/install
rm ./lib/libiberty.a
rmdir ./lib
popd
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make prefix=${BUILD}/install exec_prefix=${BUILD}/install libdir=${BUILD}/install/lib datadir=${BUILD}/install/share install-html
popd
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make prefix=${BUILD}/install exec_prefix=${BUILD}/install libdir=${BUILD}/install/lib datadir=${BUILD}/install/share install-pdf
popd
cp ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/bfd/.libs/libbfd.a ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
cp ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/bfd/bfd.h ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
cp ${BUILD}/src/binutils-2012.03/bfd/elf-bfd.h ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/include
cp ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/opcodes/.libs/libopcodes.a ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr/lib
rm -f ${BUILD}/install/bin/arm-none-symbianelf-ld.bfd
rm -f ${BUILD}/install/bin/ld.bfd
rm -f ${BUILD}/install/arm-none-symbianelf/bin/ld.bfd
popenv
popenv
popenv

echo Task: [46/62] /x86_64-pc-linux-gnu/toolchain/gcc_final/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
rm -rf ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
mkdir -p ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushd ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
${BUILD}/src/gcc-4.6-2012.03/configure --build=x86_64-pc-linux-gnu --host=x86_64-pc-linux-gnu --target=arm-none-symbianelf --enable-threads --disable-libmudflap --disable-libssp --disable-libstdcxx-pch --with-gnu-as --with-gnu-ld '--with-specs=%{save-temps: -fverbose-asm} -D__CS_SOURCERYGXX_MAJ__=2012 -D__CS_SOURCERYGXX_MIN__=3 -D__CS_SOURCERYGXX_REV__=42' --enable-languages=c,c++ --enable-shared --disable-hosted-libstdcxx '--with-pkgversion=Sacha GCC ${GCC_VER}' --with-bugurl=http://github.com/xsacha/SymbianGCC --disable-nls --prefix=/opt/codesourcery --with-gmp=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-mpfr=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-mpc=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-ppl=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr '--with-host-libstdcxx=-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm' --with-cloog=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --with-libelf=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr --disable-libgomp --with-build-time-tools=${BUILD}/install/arm-none-symbianelf/bin --with-build-time-tools=${BUILD}/install/arm-none-symbianelf/bin
popd
popenv
popenv

echo Task: [47/62] /x86_64-pc-linux-gnu/toolchain/gcc_final/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
pushd ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv
popenv

echo Task: [48/62] /x86_64-pc-linux-gnu/toolchain/gcc_final/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
pushd ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make prefix=${BUILD}/install exec_prefix=${BUILD}/install libdir=${BUILD}/install/lib  install
make prefix=${BUILD}/install exec_prefix=${BUILD}/install libdir=${BUILD}/install/lib  install-html
make prefix=${BUILD}/install exec_prefix=${BUILD}/install libdir=${BUILD}/install/lib  install-pdf
popd
popenv
popenv

echo Task: [49/62] /x86_64-pc-linux-gnu/toolchain/gcc_final/postinstall
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushenv
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
pushd ${BUILD}/install
rm ./lib/libiberty.a
rmdir include
popd
popenv
popenv

echo Task: [50/62] /x86_64-pc-linux-gnu/toolchain/zlib/0/copy
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
rm -rf ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
copy_dir_clean ${BUILD}/src/zlib-1.2.3 ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
chmod -R u+w ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
popenv

echo Task: [51/62] /x86_64-pc-linux-gnu/toolchain/zlib/0/configure
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushd ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
pushenv
pushenvvar CFLAGS '-O3 -fPIC'
pushenvvar CC 'gcc-4.7 '
pushenvvar AR 'ar rc'
pushenvvar RANLIB ranlib
./configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu/usr
popenv
popd
popenv

echo Task: [52/62] /x86_64-pc-linux-gnu/toolchain/zlib/0/build
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushd ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make -j4
popd
popenv

echo Task: [53/62] /x86_64-pc-linux-gnu/toolchain/zlib/0/install
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushd ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu
make install
popd
popenv

echo Task: [54/62] /x86_64-pc-linux-gnu/finalize_libc_installation
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
popenv

echo Task: [55/62] /x86_64-pc-linux-gnu/pretidy_installation
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushd ${BUILD}/install
popd
popenv

echo Task: [56/62] /x86_64-pc-linux-gnu/remove_libtool_archives
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
find ${BUILD}/install -name '*.la' -exec rm '{}' ';'
popenv

echo Task: [57/62] /x86_64-pc-linux-gnu/remove_copied_libs
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
popenv

echo Task: [58/62] /x86_64-pc-linux-gnu/remove_fixed_headers
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
pushd ${BUILD}/install/lib/gcc/arm-none-symbianelf/${GCC_VER}/include-fixed
popd
popenv

echo Task: [59/62] /x86_64-pc-linux-gnu/add_tooldir_readme
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
cat > ${BUILD}/install/arm-none-symbianelf/bin/README.txt <<'EOF0'
The executables in this directory are for internal use by the compiler
and may not operate correctly when used directly.  This directory
should not be placed on your PATH.  Instead, you should use the
executables in ../../bin/ and place that directory on your PATH.
EOF0
popenv

echo Task: [60/62] /x86_64-pc-linux-gnu/strip_host_objects
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
strip ${BUILD}/install/bin/arm-none-symbianelf-addr2line
strip ${BUILD}/install/bin/arm-none-symbianelf-ar
strip ${BUILD}/install/bin/arm-none-symbianelf-as
strip ${BUILD}/install/bin/arm-none-symbianelf-c++
strip ${BUILD}/install/bin/arm-none-symbianelf-c++filt
strip ${BUILD}/install/bin/arm-none-symbianelf-cpp
strip ${BUILD}/install/bin/arm-none-symbianelf-elfedit
strip ${BUILD}/install/bin/arm-none-symbianelf-g++
strip ${BUILD}/install/bin/arm-none-symbianelf-gcc
strip ${BUILD}/install/bin/arm-none-symbianelf-gcc-${GCC_VER}
strip ${BUILD}/install/bin/arm-none-symbianelf-gcov
strip ${BUILD}/install/bin/arm-none-symbianelf-gprof
strip ${BUILD}/install/bin/arm-none-symbianelf-ld
strip ${BUILD}/install/bin/arm-none-symbianelf-nm
strip ${BUILD}/install/bin/arm-none-symbianelf-objcopy
strip ${BUILD}/install/bin/arm-none-symbianelf-objdump
strip ${BUILD}/install/bin/arm-none-symbianelf-ranlib
strip ${BUILD}/install/bin/arm-none-symbianelf-readelf
strip ${BUILD}/install/bin/arm-none-symbianelf-size
strip ${BUILD}/install/bin/arm-none-symbianelf-strings
strip ${BUILD}/install/bin/arm-none-symbianelf-strip
strip ${BUILD}/install/arm-none-symbianelf/bin/ar
strip ${BUILD}/install/arm-none-symbianelf/bin/as
strip ${BUILD}/install/arm-none-symbianelf/bin/c++
strip ${BUILD}/install/arm-none-symbianelf/bin/g++
strip ${BUILD}/install/arm-none-symbianelf/bin/gcc
strip ${BUILD}/install/arm-none-symbianelf/bin/ld
strip ${BUILD}/install/arm-none-symbianelf/bin/nm
strip ${BUILD}/install/arm-none-symbianelf/bin/objcopy
strip ${BUILD}/install/arm-none-symbianelf/bin/objdump
strip ${BUILD}/install/arm-none-symbianelf/bin/ranlib
strip ${BUILD}/install/arm-none-symbianelf/bin/strip
strip ${BUILD}/install/libexec/gcc/arm-none-symbianelf/${GCC_VER}/cc1
strip ${BUILD}/install/libexec/gcc/arm-none-symbianelf/${GCC_VER}/collect2
strip ${BUILD}/install/libexec/gcc/arm-none-symbianelf/${GCC_VER}/install-tools/fixincl
strip ${BUILD}/install/libexec/gcc/arm-none-symbianelf/${GCC_VER}/cc1plus
strip ${BUILD}/install/libexec/gcc/arm-none-symbianelf/${GCC_VER}/lto-wrapper
strip ${BUILD}/install/libexec/gcc/arm-none-symbianelf/${GCC_VER}/lto1
popenv

echo Task: [61/62] /x86_64-pc-linux-gnu/strip_target_objects
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/arm-none-symbianelf/lib/libsupc++.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/arm-none-symbianelf/lib/libgcc_s.dll || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/arm-none-symbianelf/lib/softfp/libsupc++.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/arm-none-symbianelf/lib/softfp/libgcc_s.dll || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/lib/gcc/arm-none-symbianelf/${GCC_VER}/libgcc.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/lib/gcc/arm-none-symbianelf/${GCC_VER}/libgcov.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/lib/gcc/arm-none-symbianelf/${GCC_VER}/softfp/libgcc.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/lib/gcc/arm-none-symbianelf/${GCC_VER}/softfp/libgcov.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/lib/gcc/arm-none-symbianelf/${GCC_VER}/softfp/libgcc_eh.a || true
arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/lib/gcc/arm-none-symbianelf/${GCC_VER}/libgcc_eh.a || true
popenv

echo Task: [62/62] /x86_64-pc-linux-gnu/package_tbz2
pushenv
pushenvvar CC_FOR_BUILD gcc-4.7
pushenvvar CC gcc-4.7
pushenvvar CXX g++-4.7
pushenvvar AR ar
pushenvvar RANLIB ranlib
prepend_path PATH ${BUILD}/install/bin
rm -f ${BUILD}/pkg/arm-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu.tar.bz2
pushd ${BUILD}/obj
rm -f arm-2012.03
ln -s ${BUILD}/install arm-2012.03
tar cjf ${BUILD}/pkg/arm-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu.tar.bz2 --owner=0 --group=0 --exclude=host-x86_64-pc-linux-gnu --exclude=host-x86_64-mingw32 arm-2012.03/arm-none-symbianelf arm-2012.03/bin arm-2012.03/lib arm-2012.03/libexec arm-2012.03/share
rm -f arm-2012.03
popd
popenv

echo "Complete. Files are in ${BUILD}/install or ${BUILD}/pkg/arm-2012.03-42-arm-none-symbianelf-x86_64-pc-linux-gnu.tar.bz2"

