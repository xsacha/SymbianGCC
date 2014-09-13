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

# modified by xsacha to work for 32-bit/64-bit Linux/Windows GCC 4.8.3
# Configuration:
# Build Directory
BUILD="$(pwd)/build"

# GCC Target Version
GCC_VER=4.8.3
# If you checkout from git, this is the gcc src dir.
# Otherwise if testing a new version, change this.
GCC_SRC_DIR="$(pwd)"
# Original: ${BUILD}/src/gcc-4.6-2012.03

# Compiler Host
# Note: the support files in the toolchain do not work on GCC > 4.7
export CC=gcc-4.7
export CXX=g++-4.7
export AR_HOST=ar
export RANLIB=ranlib
export STRIP=strip

# Note: the support files in the toolchain do not work on mingw > 4.7
#export CC=mingw32-gcc
#export CXX=mingw32-g++
#export AR_HOST=mingw32-ar
#export RANLIB=ming32-ranlib
#export STRIP=mingw32-strip
#export EXT='.exe'

export CC_FOR_BUILD=${CC}

# Host architecture
#ARCH_HOST=x86_64
ARCH_HOST=x86
if [[ "$ARCH_HOST" = "x86" ]]; then
    export CC="$CC -m32"
    export CXX="$CXX -m32"
fi

CLEANUP=true
BUILDONLYGCC=false

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

extract_tar_move() {
    mkdir -p "$2"
    cd "$2" && tar xf $1
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
	    HOME|HOSTNAME|LOGNAME|PWD|SHELL|SHLVL|SSH_*|TERM|USER|CC|CXX|AR|RANLIB|STRIP|CC_FOR_BUILD)


		;;
	    LD_LIBRARY_PATH|PATH| \
		FLEXLM_NO_CKOUT_INSTALL_LIC|LM_APP_DISABLE_CACHE_READ)


		;;
	    MAKEINFO)

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
    local pushenv_val="$2"
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

copy_tar_if_not_found() {
    if [ ! -f ${BUILD}/pkg-2014.07/arm-2014.07-arm-none-symbianelf/$1 ]; then
        echo "Tar: $1 not found. Copying from checkout dir."
        cp ${BUILD}/../$1 ${BUILD}/pkg-2014.07/arm-2014.07-arm-none-symbianelf/
# Also extracts to src
        pushd ${BUILD}/src/
        tar xf ${BUILD}/../$1
        popd
    fi
}

pushenvvar CSL_SCRIPTDIR ${BUILD}/src/scripts-trunk
pushenvvar FLEXLM_NO_CKOUT_INSTALL_LIC 1
pushenvvar LM_APP_DISABLE_CACHE_READ 1
pushenvvar MAKEINFO false
#'makeinfo --css-ref=../cs.css'
prepend_path PATH ${BUILD}/install/bin
clean_environment

if [ "$BUILDONLYGCC" == "false" ]; then


echo Task: [01/45] /init/cleanup
# Clean last install
if [ "$CLEANUP" == "true" ]; then
  rm -rf ${BUILD}/install
  rm -rf ${BUILD}/logs
  rm -rf ${BUILD}/obj
fi

mkdir -p ${BUILD}/src
mkdir -p ${BUILD}/obj
mkdir -p ${BUILD}/install
mkdir -p ${BUILD}/pkg
mkdir -p ${BUILD}/logs/data
mkdir -p ${BUILD}/pkg-2014.07/arm-2014.07-arm-none-symbianelf

echo Task: [02/45] /init/source_packages
copy_tar_if_not_found binutils-2012.03-42.tar.bz2
copy_tar_if_not_found zlib-2012.03-42.tar.bz2
copy_tar_if_not_found gmp-2012.03-42.tar.bz2
copy_tar_if_not_found mpfr-2012.03-42.tar.bz2
copy_tar_if_not_found mpc-2012.03-42.tar.bz2
copy_tar_if_not_found cloog-2012.03-42.tar.bz2
copy_tar_if_not_found ppl-2012.03-42.tar.bz2
copy_tar_if_not_found libiconv-2012.03-42.tar.bz2
copy_tar_if_not_found libelf-2012.03-42.tar.bz2
copy_tar_if_not_found coreutils-2012.03-42.tar.bz2
# If you want to use the original GCC 4.6.3
#copy_tar_if_not_found gcc-2012.03-42.tar.bz2

echo Task: [03/45] /${ARCH_HOST}-pc-linux-gnu/zlib_first/copy
rm -rf ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
extract_tar_move ${BUILD}/pkg-2014.07/arm-2014.07-arm-none-symbianelf/zlib-2012.03-42.tar.bz2 ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
chmod -R u+w ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu

echo Task: [04/45] /${ARCH_HOST}-pc-linux-gnu/zlib_first/configure
pushd ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/zlib-1.2.3
pushenv
pushenvvar AR ${AR_HOST}' rc'
pushenvvar CFLAGS '-O3 -fPIC'
./configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr
popenv
popd

echo Task: [05/45] /${ARCH_HOST}-pc-linux-gnu/zlib_first/build
pushenv
pushenvvar CFLAGS '-O3 -fPIC'
pushenvvar AR $AR_HOST
pushd ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/zlib-1.2.3
make -j4
popd
popenv

echo Task: [06/45] /${ARCH_HOST}-pc-linux-gnu/zlib_first/install
pushd ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/zlib-1.2.3
make install
popd

echo Task: [07/45] /${ARCH_HOST}-pc-linux-gnu/gmp/configure
pushenv
pushenvvar CFLAGS '-O2'
rm -rf ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
mkdir -p ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
pushd ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
${BUILD}/src/gmp-2012.03/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --disable-shared --build=${ARCH_HOST}-pc-linux-gnu --target=${ARCH_HOST}-pc-linux-gnu --host=${ARCH_HOST}-pc-linux-gnu --enable-cxx --disable-nls
popd
popenv

echo Task: [08/45] /${ARCH_HOST}-pc-linux-gnu/gmp/build
pushenv
pushenvvar CFLAGS '-O2'
pushd ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make -j4
popd
popenv

echo Task: [09/45] /${ARCH_HOST}-pc-linux-gnu/gmp/install
pushenv
pushenvvar CFLAGS '-O2'
pushd ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make install
popd
popenv

#echo Task: [10/45] /${ARCH_HOST}-pc-linux-gnu/gmp/postinstall
# on 64-bit, 1 of 58 tests fail (t-scan)
#pushenv
#pushenvvar CFLAGS '-O2'
#pushd ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
#make check
#popd
#popenv

echo Task: [10/45] /${ARCH_HOST}-pc-linux-gnu/mpfr/configure
rm -rf ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
mkdir -p ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
pushd ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
${BUILD}/src/mpfr-2012.03/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --disable-shared --build=${ARCH_HOST}-pc-linux-gnu --target=arm-none-symbianelf --host=${ARCH_HOST}-pc-linux-gnu --disable-nls --with-gmp=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr
popd

echo Task: [11/45] /${ARCH_HOST}-pc-linux-gnu/mpfr/build
pushd ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make -j4
popd

echo Task: [12/45] /${ARCH_HOST}-pc-linux-gnu/mpfr/install
pushd ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make install
popd

echo Task: [13/45] /${ARCH_HOST}-pc-linux-gnu/mpfr/postinstall
pushd ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make check
popd

echo Task: [14/45] /${ARCH_HOST}-pc-linux-gnu/mpc/configure
rm -rf ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
mkdir -p ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
pushd ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
${BUILD}/src/mpc-0.9/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --disable-shared --build=${ARCH_HOST}-pc-linux-gnu --target=arm-none-symbianelf --host=${ARCH_HOST}-pc-linux-gnu --disable-nls --with-gmp=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --with-mpfr=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr
popd

echo Task: [15/45] /${ARCH_HOST}-pc-linux-gnu/mpc/build
pushd ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make -j4
popd

echo Task: [16/45] /${ARCH_HOST}-pc-linux-gnu/mpc/install
pushenv
pushd ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make install
popd

echo Task: [17/45] /${ARCH_HOST}-pc-linux-gnu/mpc/postinstall
pushenv
pushd ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make check
popd

echo Task: [18/45] /${ARCH_HOST}-pc-linux-gnu/ppl/configure
pushenv
rm -rf ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
mkdir -p ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
pushd ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
${BUILD}/src/ppl-0.11/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --disable-shared --build=${ARCH_HOST}-pc-linux-gnu --target=arm-none-symbianelf --host=${ARCH_HOST}-pc-linux-gnu --disable-nls --with-libgmp-prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --with-gmp-prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr CPPFLAGS=-I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/include LDFLAGS=-L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/lib --disable-watchdog
popd

echo Task: [19/45] /${ARCH_HOST}-pc-linux-gnu/ppl/build
pushd ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make -j4
popd

echo Task: [20/45] /${ARCH_HOST}-pc-linux-gnu/ppl/install
pushd ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make install
popd

echo Task: [21/45] /${ARCH_HOST}-pc-linux-gnu/cloog/configure
rm -rf ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
mkdir -p ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
pushd ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
${BUILD}/src/cloog-0.15/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --disable-shared --build=${ARCH_HOST}-pc-linux-gnu --target=arm-none-symbianelf --host=${ARCH_HOST}-pc-linux-gnu --disable-nls --with-ppl=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --with-gmp=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr
popd

echo Task: [22/45] /${ARCH_HOST}-pc-linux-gnu/cloog/build
pushd ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make -j4
popd

echo Task: [23/45] /${ARCH_HOST}-pc-linux-gnu/cloog/install
pushd ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make install
popd

echo Task: [24/45] /${ARCH_HOST}-pc-linux-gnu/cloog/postinstall
pushd ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make check
popd

echo Task: [25/45] /${ARCH_HOST}-pc-linux-gnu/libelf/configure
pushenv
rm -rf ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
mkdir -p ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
pushd ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
${BUILD}/src/libelf-2012.03/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --disable-shared --build=${ARCH_HOST}-pc-linux-gnu --target=arm-none-symbianelf --host=${ARCH_HOST}-pc-linux-gnu --disable-nls
popd

echo Task: [26/45] /${ARCH_HOST}-pc-linux-gnu/libelf/build
pushd ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make -j4
popd

echo Task: [27/45] /${ARCH_HOST}-pc-linux-gnu/libelf/install
pushd ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make install
popd

echo Task: [28/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/binutils/copy
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/lib
rm -rf ${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
extract_tar_move ${BUILD}/pkg-2014.07/arm-2014.07-arm-none-symbianelf/binutils-2012.03-42.tar.bz2 ${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
# Stop makeinfo from terminating when it isn't found
sed -i 's/ || exit 1//g' ${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/binutils-2012.03/missing
chmod -R u+w ${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
touch ${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/binutils-2012.03/.gnu-stamp
popenv

echo Task: [29/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/binutils/configure
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/lib
rm -rf ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
mkdir -p ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/binutils-2012.03/configure --prefix=/opt/codesourcery --build=${ARCH_HOST}-pc-linux-gnu --target=arm-none-symbianelf --host=${ARCH_HOST}-pc-linux-gnu '--with-pkgversion=Sourcery CodeBench Lite 2012.03-42' --with-bugurl=https://support.codesourcery.com/GNUToolchain/ --disable-nls --disable-werror --enable-poison-system-directories
popd
popenv

echo Task: [30/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/binutils/libiberty
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/lib
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make -j4 all-libiberty
popd
mkdir -p ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/include
cp -R ${BUILD}/src/binutils-2012.03/include ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/include
chmod -R u+w ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/include
mkdir -p ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/lib
cp ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/libiberty/libiberty.a ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/lib
popenv

echo Task: [31/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/binutils/build
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/lib
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make -j4
popd
popenv

echo Task: [32/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/binutils/install
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/lib
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make install prefix=${BUILD}/install exec_prefix=${BUILD}/install libdir=${BUILD}/install/lib datadir=${BUILD}/install/share
popd
popenv

echo Task: [33/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/binutils/postinstall
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/lib
pushd ${BUILD}/install
# Could be either dir for 32-bit. Ignore error
rm -rf ./lib ./lib32 || true
popd
cp ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/bfd/.libs/libbfd.a ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/lib
cp ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/bfd/bfd.h ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/include
cp ${BUILD}/src/binutils-2012.03/bfd/elf-bfd.h ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/include
cp ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/opcodes/.libs/libopcodes.a ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr/lib
rm -f ${BUILD}/install/bin/arm-none-symbianelf-ld.bfd$EXT
rm -f ${BUILD}/install/bin/ld.bfd$EXT
rm -f ${BUILD}/install/arm-none-symbianelf/bin/ld.bfd$EXT
popenv

fi

echo Task: [34/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/gcc_final/configure
pushenv
pushenvvar AR $AR_HOST
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
rm -rf ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
mkdir -p ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
pushd ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
${GCC_SRC_DIR}/configure --build=${ARCH_HOST}-pc-linux-gnu --host=${ARCH_HOST}-pc-linux-gnu --target=arm-none-symbianelf --with-cpu=arm1176jzf-s --with-arch=armv6zk --enable-threads --disable-libmudflap --disable-libssp --disable-libstdcxx-pch --with-gnu-as --with-gnu-ld '--with-specs=%{save-temps: -fverbose-asm} -D__CS_SOURCERYGXX_MAJ__=2012 -D__CS_SOURCERYGXX_MIN__=3 -D__CS_SOURCERYGXX_REV__=42' --enable-languages=c,c++ --enable-shared --disable-hosted-libstdcxx '--with-pkgversion=Sacha GCC ${GCC_VER}' --with-bugurl=http://github.com/xsacha/SymbianGCC --disable-nls --prefix=/opt/codesourcery --with-gmp=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --with-mpfr=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --with-mpc=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --with-ppl=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr '--with-host-libstdcxx=-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm' --with-cloog=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --with-libelf=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr --disable-libgomp --with-build-time-tools=${BUILD}/install/arm-none-symbianelf/bin
popd
popenv

echo Task: [35/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/gcc_final/build
pushenv
pushenvvar AR $AR_HOST
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
pushd ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make -j4
popd
popenv

echo Task: [36/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/gcc_final/install
pushenv
pushenvvar AR $AR_HOST
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
pushd ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
make prefix=${BUILD}/install exec_prefix=${BUILD}/install libdir=${BUILD}/install/lib  install
popd
popenv

echo Task: [37/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/gcc_final/postinstall
pushenv
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
pushd ${BUILD}/install
rm ./lib/libiberty.a || true
rm ./lib32/libiberty.a || true
rmdir include
popd
popenv

echo Task: [38/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/zlib/0/copy
rm -rf ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
extract_tar_move ${BUILD}/pkg-2014.07/arm-2014.07-arm-none-symbianelf/zlib-2012.03-42.tar.bz2 ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu
chmod -R u+w ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu

echo Task: [39/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/zlib/0/configure
pushd ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/zlib-1.2.3
pushenv
pushenvvar CFLAGS '-O3 -fPIC'
pushenvvar AR ${AR_HOST}' rc'
./configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/usr
popenv
popd

echo Task: [40/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/zlib/0/build
pushenv
pushenvvar AR $AR_HOST
pushd ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/zlib-1.2.3
make -j4
popd
popenv

echo Task: [41/45] /${ARCH_HOST}-pc-linux-gnu/toolchain/zlib/0/install
pushd ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu/zlib-1.2.3
make install
popd

echo Task: [42/45] /${ARCH_HOST}-pc-linux-gnu/remove_libtool_archives
find ${BUILD}/install -name '*.la' -exec rm '{}' ';'


echo Task: [43/45] /${ARCH_HOST}-pc-linux-gnu/strip_host_objects
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-addr2line$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-ar$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-as$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-c++$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-c++filt$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-cpp$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-elfedit$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-g++$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-gcc$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-gcc-${GCC_VER}$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-gcov$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-gprof$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-ld$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-nm$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-objcopy$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-objdump$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-ranlib$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-readelf$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-size$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-strings$EXT
$STRIP ${BUILD}/install/bin/arm-none-symbianelf-strip$EXT
$STRIP ${BUILD}/install/arm-none-symbianelf/bin/ar$EXT
$STRIP ${BUILD}/install/arm-none-symbianelf/bin/as$EXT
$STRIP ${BUILD}/install/arm-none-symbianelf/bin/c++$EXT
$STRIP ${BUILD}/install/arm-none-symbianelf/bin/g++$EXT
$STRIP ${BUILD}/install/arm-none-symbianelf/bin/gcc$EXT
$STRIP ${BUILD}/install/arm-none-symbianelf/bin/ld$EXT
$STRIP ${BUILD}/install/arm-none-symbianelf/bin/nm$EXT
$STRIP ${BUILD}/install/arm-none-symbianelf/bin/objcopy$EXT
$STRIP ${BUILD}/install/arm-none-symbianelf/bin/objdump$EXT
$STRIP ${BUILD}/install/arm-none-symbianelf/bin/ranlib$EXT
$STRIP ${BUILD}/install/arm-none-symbianelf/bin/strip$EXT
$STRIP ${BUILD}/install/libexec/gcc/arm-none-symbianelf/${GCC_VER}/cc1$EXT
$STRIP ${BUILD}/install/libexec/gcc/arm-none-symbianelf/${GCC_VER}/collect2$EXT
$STRIP ${BUILD}/install/libexec/gcc/arm-none-symbianelf/${GCC_VER}/install-tools/fixincl$EXT
$STRIP ${BUILD}/install/libexec/gcc/arm-none-symbianelf/${GCC_VER}/cc1plus$EXT
$STRIP ${BUILD}/install/libexec/gcc/arm-none-symbianelf/${GCC_VER}/lto-wrapper$EXT
$STRIP ${BUILD}/install/libexec/gcc/arm-none-symbianelf/${GCC_VER}/lto1$EXT

echo Task: [44/45] /${ARCH_HOST}-pc-linux-gnu/strip_target_objects
${BUILD}/install/bin/arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/arm-none-symbianelf/lib/libsupc++.a || true
${BUILD}/install/bin/arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/arm-none-symbianelf/lib/libgcc_s.dll || true
${BUILD}/install/bin/arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/arm-none-symbianelf/lib/softfp/libsupc++.a || true
${BUILD}/install/bin/arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/arm-none-symbianelf/lib/softfp/libgcc_s.dll || true
${BUILD}/install/bin/arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/lib/gcc/arm-none-symbianelf/${GCC_VER}/libgcc.a || true
${BUILD}/install/bin/arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/lib/gcc/arm-none-symbianelf/${GCC_VER}/libgcov.a || true
${BUILD}/install/bin/arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/lib/gcc/arm-none-symbianelf/${GCC_VER}/softfp/libgcc.a || true
${BUILD}/install/bin/arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/lib/gcc/arm-none-symbianelf/${GCC_VER}/softfp/libgcov.a || true
${BUILD}/install/bin/arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/lib/gcc/arm-none-symbianelf/${GCC_VER}/softfp/libgcc_eh.a || true
${BUILD}/install/bin/arm-none-symbianelf-objcopy -R .comment -R .note -R .debug_info -R .debug_aranges -R .debug_pubnames -R .debug_pubtypes -R .debug_abbrev -R .debug_line -R .debug_str -R .debug_ranges -R .debug_loc ${BUILD}/install/lib/gcc/arm-none-symbianelf/${GCC_VER}/libgcc_eh.a || true

echo Task: [45/45] /${ARCH_HOST}-pc-linux-gnu/package_tbz2
rm -f ${BUILD}/pkg/arm-2014.07-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu.tar.bz2
pushd ${BUILD}/obj
rm -f arm-2012.03
ln -s ${BUILD}/install arm-2012.03
tar cjf ${BUILD}/pkg/arm-2014.07-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu.tar.bz2 --owner=0 --group=0 --exclude=host-${ARCH_HOST}-pc-linux-gnu --exclude=host-${ARCH_HOST}-mingw32 arm-2012.03/arm-none-symbianelf arm-2012.03/bin arm-2012.03/lib arm-2012.03/libexec arm-2012.03/share
rm -f arm-2012.03
popd

echo "Complete. Files are in ${BUILD}/install or ${BUILD}/pkg/arm-2014.07-arm-none-symbianelf-${ARCH_HOST}-pc-linux-gnu.tar.bz2"

