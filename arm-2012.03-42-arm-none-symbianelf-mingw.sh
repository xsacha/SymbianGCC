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

# modified by xsacha to work for 32-bit MingW GCC 4.8.3
# Configuration:
# Build Directory
BUILD="$(pwd)/build"

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

extract_tar_move() {
    mkdir -p "$2"
    cd "$2" && tar xf $1
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
pushenvvar MAKEINFO 'makeinfo --css-ref=../cs.css'
clean_environment

echo Task: [001/142] /init/cleanup
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
# Clean last install
rm -rf ${BUILD}/install
rm -rf ${BUILD}/logs
rm -rf ${BUILD}/obj/!(pkg-2014.07)
popenv

echo Task: [002/142] /init/dirs
pushenv
mkdir -p ${BUILD}/src
mkdir -p ${BUILD}/obj
mkdir -p ${BUILD}/install
mkdir -p ${BUILD}/pkg
mkdir -p ${BUILD}/logs/data
mkdir -p ${BUILD}/pkg-2014.07/arm-2014.07-arm-none-symbianelf
popenv

echo Task: [003/142] /init/source_package/binutils
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
copy_tar_if_not_found binutils-2012.03-42.tar.bz2
popenv

echo Task: [004/142] /init/source_package/gcc
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
copy_tar_if_not_found gcc-2012.03-42.tar.bz2
popenv

echo Task: [005/142] /init/source_package/zlib
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
copy_tar_if_not_found zlib-2012.03-42.tar.bz2
popenv

echo Task: [006/142] /init/source_package/gmp
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
copy_tar_if_not_found gmp-2012.03-42.tar.bz2
popenv

echo Task: [007/142] /init/source_package/mpfr
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
copy_tar_if_not_found mpfr-2012.03-42.tar.bz2
popenv

echo Task: [008/142] /init/source_package/mpc
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
copy_tar_if_not_found mpc-2012.03-42.tar.bz2
popenv

echo Task: [009/142] /init/source_package/cloog
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
copy_tar_if_not_found cloog-2012.03-42.tar.bz2
popenv

echo Task: [010/142] /init/source_package/ppl
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
copy_tar_if_not_found ppl-2012.03-42.tar.bz2
popenv

echo Task: [018/142] /init/source_package/libiconv
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
copy_tar_if_not_found libiconv-2012.03-42.tar.bz2
popenv

echo Task: [019/142] /init/source_package/libelf
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
copy_tar_if_not_found libelf-2012.03-42.tar.bz2
popenv

echo Task: [023/142] /init/source_package/coreutils
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
copy_tar_if_not_found coreutils-2012.03-42.tar.bz2
popenv

echo Task: [082/142] /mingw32/host_cleanup
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
popenv

echo Task: [083/142] /mingw32/host_unpack
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
rm -rf ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32
mkdir ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32
pushd ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32
ln -s . arm-2012.03
tar xf ${BUILD}/pkg/arm-2012.03-42-arm-none-symbianelf-pc-linux-gnu.tar.bz2 --bzip2
rm arm-2012.03
popd
popenv

echo Task: [084/142] /mingw32/libiconv/0/configure
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/libiconv-2012.03-42-arm-none-symbianelf-mingw32
mkdir -p ${BUILD}/obj/libiconv-2012.03-42-arm-none-symbianelf-mingw32
pushd ${BUILD}/obj/libiconv-2012.03-42-arm-none-symbianelf-mingw32
${BUILD}/src/libiconv-1.11/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --disable-shared --build=pc-linux-gnu --target=arm-none-symbianelf --host=mingw32 --disable-nls
popd
popenv
popenv
popenv

echo Task: [085/142] /mingw32/libiconv/0/build
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/libiconv-2012.03-42-arm-none-symbianelf-mingw32
make -j1
popd
popenv
popenv
popenv

echo Task: [086/142] /mingw32/libiconv/0/install
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/libiconv-2012.03-42-arm-none-symbianelf-mingw32
make install
popd
popenv
popenv
popenv

echo Task: [087/142] /mingw32/make/copy
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/make-src-2012.03-42-arm-none-symbianelf-mingw32
copy_dir_clean ${BUILD}/src/make-3.81 ${BUILD}/obj/make-src-2012.03-42-arm-none-symbianelf-mingw32
chmod -R u+w ${BUILD}/obj/make-src-2012.03-42-arm-none-symbianelf-mingw32
touch ${BUILD}/obj/make-src-2012.03-42-arm-none-symbianelf-mingw32/.gnu-stamp
popenv
popenv
popenv

echo Task: [088/142] /mingw32/make/configure
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/make-2012.03-42-arm-none-symbianelf-mingw32
mkdir -p ${BUILD}/obj/make-2012.03-42-arm-none-symbianelf-mingw32
pushd ${BUILD}/obj/make-2012.03-42-arm-none-symbianelf-mingw32
${BUILD}/obj/make-src-2012.03-42-arm-none-symbianelf-mingw32/configure --prefix=/opt/codesourcery --build=pc-linux-gnu --target=arm-none-symbianelf --host=mingw32 '--with-pkgversion=Sourcery CodeBench Lite 2012.03-42' --disable-nls --program-prefix=cs-
popd
popenv
popenv
popenv

echo Task: [089/142] /mingw32/make/build
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/make-2012.03-42-arm-none-symbianelf-mingw32
make -j4
popd
popenv
popenv
popenv

echo Task: [090/142] /mingw32/make/install
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/make-2012.03-42-arm-none-symbianelf-mingw32
make install prefix=${BUILD}/install/host-mingw32 exec_prefix=${BUILD}/install/host-mingw32 libdir=${BUILD}/install/host-mingw32/lib htmldir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html pdfdir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info mandir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/man datadir=${BUILD}/install/host-mingw32/share
popd
popenv
popenv
popenv

echo Task: [091/142] /mingw32/coreutils/copy
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/coreutils-src-2012.03-42-arm-none-symbianelf-mingw32
copy_dir_clean ${BUILD}/src/coreutils-5.94 ${BUILD}/obj/coreutils-src-2012.03-42-arm-none-symbianelf-mingw32
chmod -R u+w ${BUILD}/obj/coreutils-src-2012.03-42-arm-none-symbianelf-mingw32
touch ${BUILD}/obj/coreutils-src-2012.03-42-arm-none-symbianelf-mingw32/.gnu-stamp
popenv
popenv
popenv

echo Task: [092/142] /mingw32/coreutils/configure
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/coreutils-2012.03-42-arm-none-symbianelf-mingw32
mkdir -p ${BUILD}/obj/coreutils-2012.03-42-arm-none-symbianelf-mingw32
pushd ${BUILD}/obj/coreutils-2012.03-42-arm-none-symbianelf-mingw32
${BUILD}/obj/coreutils-src-2012.03-42-arm-none-symbianelf-mingw32/configure --prefix=/opt/codesourcery --build=pc-linux-gnu --target=arm-none-symbianelf --host=mingw32 '--with-pkgversion=Sourcery CodeBench Lite 2012.03-42' --disable-nls --program-prefix=cs-
popd
popenv
popenv
popenv

echo Task: [093/142] /mingw32/coreutils/build
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/coreutils-2012.03-42-arm-none-symbianelf-mingw32
make -j4
popd
popenv
popenv
popenv

echo Task: [094/142] /mingw32/coreutils/install
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/coreutils-2012.03-42-arm-none-symbianelf-mingw32
make install prefix=${BUILD}/install/host-mingw32 exec_prefix=${BUILD}/install/host-mingw32 libdir=${BUILD}/install/host-mingw32/lib htmldir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html pdfdir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info mandir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/man datadir=${BUILD}/install/host-mingw32/share
popd
popenv
popenv
popenv

echo Task: [095/142] /mingw32/zlib_first/copy
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
rm -rf ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-mingw32
copy_dir_clean ${BUILD}/src/zlib-1.2.3 ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-mingw32
chmod -R u+w ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-mingw32
popenv

echo Task: [096/142] /mingw32/zlib_first/configure
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushd ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-mingw32
pushenv
pushenvvar CFLAGS '-O3 -fPIC'
pushenvvar CC 'mingw32-gcc '
pushenvvar AR 'mingw32-ar rc'
pushenvvar RANLIB mingw32-ranlib
./configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr
popenv
popd
popenv

echo Task: [097/142] /mingw32/zlib_first/build
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushd ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-mingw32
make -j4
popd
popenv

echo Task: [098/142] /mingw32/zlib_first/install
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushd ${BUILD}/obj/zlib-first-2012.03-42-arm-none-symbianelf-mingw32
make install
popd
popenv

echo Task: [099/142] /mingw32/gmp/configure
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushenvvar CFLAGS '-g -O2'
rm -rf ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-mingw32
mkdir -p ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-mingw32
pushd ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-mingw32
${BUILD}/src/gmp-2012.03/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --disable-shared --build=pc-linux-gnu --target=mingw32 --host=mingw32 --enable-cxx --disable-nls
popd
popenv
popenv
popenv

echo Task: [100/142] /mingw32/gmp/build
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushenvvar CFLAGS '-g -O2'
pushd ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-mingw32
make -j4
popd
popenv
popenv
popenv

echo Task: [101/142] /mingw32/gmp/install
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushenvvar CFLAGS '-g -O2'
pushd ${BUILD}/obj/gmp-2012.03-42-arm-none-symbianelf-mingw32
make install
popd
popenv
popenv
popenv

echo Task: [102/142] /mingw32/gmp/postinstall
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushenvvar CFLAGS '-g -O2'
popenv
popenv
popenv

echo Task: [103/142] /mingw32/mpfr/configure
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-mingw32
mkdir -p ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-mingw32
pushd ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-mingw32
${BUILD}/src/mpfr-2012.03/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --disable-shared --build=pc-linux-gnu --target=arm-none-symbianelf --host=mingw32 --disable-nls --with-gmp=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr
popd
popenv
popenv
popenv

echo Task: [104/142] /mingw32/mpfr/build
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-mingw32
make -j4
popd
popenv
popenv
popenv

echo Task: [105/142] /mingw32/mpfr/install
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/mpfr-2012.03-42-arm-none-symbianelf-mingw32
make install
popd
popenv
popenv
popenv

echo Task: [106/142] /mingw32/mpfr/postinstall
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
popenv
popenv
popenv

echo Task: [107/142] /mingw32/mpc/configure
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-mingw32
mkdir -p ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-mingw32
pushd ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-mingw32
${BUILD}/src/mpc-0.9/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --disable-shared --build=pc-linux-gnu --target=arm-none-symbianelf --host=mingw32 --disable-nls --with-gmp=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --with-mpfr=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr
popd
popenv
popenv
popenv

echo Task: [108/142] /mingw32/mpc/build
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-mingw32
make -j4
popd
popenv
popenv
popenv

echo Task: [109/142] /mingw32/mpc/install
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/mpc-2012.03-42-arm-none-symbianelf-mingw32
make install
popd
popenv
popenv
popenv

echo Task: [110/142] /mingw32/mpc/postinstall
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
popenv
popenv
popenv

echo Task: [111/142] /mingw32/ppl/configure
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-mingw32
mkdir -p ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-mingw32
pushd ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-mingw32
${BUILD}/src/ppl-0.11/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --disable-shared --build=pc-linux-gnu --target=arm-none-symbianelf --host=mingw32 --disable-nls --with-libgmp-prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --with-gmp-prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr CPPFLAGS=-I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/include LDFLAGS=-L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/lib --disable-watchdog
popd
popenv
popenv
popenv

echo Task: [112/142] /mingw32/ppl/build
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-mingw32
make -j4
popd
popenv
popenv
popenv

echo Task: [113/142] /mingw32/ppl/install
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/ppl-2012.03-42-arm-none-symbianelf-mingw32
make install
popd
popenv
popenv
popenv

echo Task: [114/142] /mingw32/cloog/configure
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-mingw32
mkdir -p ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-mingw32
pushd ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-mingw32
${BUILD}/src/cloog-0.15/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --disable-shared --build=pc-linux-gnu --target=arm-none-symbianelf --host=mingw32 --disable-nls --with-ppl=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --with-gmp=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr
popd
popenv
popenv
popenv

echo Task: [115/142] /mingw32/cloog/build
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-mingw32
make -j4
popd
popenv
popenv
popenv

echo Task: [116/142] /mingw32/cloog/install
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/cloog-2012.03-42-arm-none-symbianelf-mingw32
make install
popd
popenv
popenv
popenv

echo Task: [117/142] /mingw32/cloog/postinstall
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
popenv
popenv
popenv

echo Task: [118/142] /mingw32/libelf/configure
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
rm -rf ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-mingw32
mkdir -p ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-mingw32
pushd ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-mingw32
${BUILD}/src/libelf-2012.03/configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --disable-shared --build=pc-linux-gnu --target=arm-none-symbianelf --host=mingw32 --disable-nls
popd
popenv
popenv
popenv

echo Task: [119/142] /mingw32/libelf/build
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-mingw32
make -j4
popd
popenv
popenv
popenv

echo Task: [120/142] /mingw32/libelf/install
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushd ${BUILD}/obj/libelf-2012.03-42-arm-none-symbianelf-mingw32
make install
popd
popenv
popenv
popenv

echo Task: [121/142] /mingw32/toolchain/binutils/copy
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/lib
rm -rf ${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-mingw32
copy_dir_clean ${BUILD}/src/binutils-2012.03 ${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-mingw32
chmod -R u+w ${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-mingw32
touch ${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-mingw32/.gnu-stamp
popenv
popenv
popenv

echo Task: [122/142] /mingw32/toolchain/binutils/configure
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/lib
rm -rf ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-mingw32
mkdir -p ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-mingw32
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-mingw32
${BUILD}/obj/binutils-src-2012.03-42-arm-none-symbianelf-mingw32/configure --prefix=/opt/codesourcery --build=pc-linux-gnu --target=arm-none-symbianelf --host=mingw32 '--with-pkgversion=Sourcery CodeBench Lite 2012.03-42' --with-bugurl=https://support.codesourcery.com/GNUToolchain/ --disable-nls --enable-poison-system-directories
popd
popenv
popenv
popenv

echo Task: [123/142] /mingw32/toolchain/binutils/libiberty
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/lib
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-mingw32
make -j4 all-libiberty
popd
copy_dir_clean ${BUILD}/src/binutils-2012.03/include ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-mingw32/usr/include
chmod -R u+w ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-mingw32/usr/include
mkdir -p ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-mingw32/usr/lib
cp ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-mingw32/libiberty/libiberty.a ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-mingw32/usr/lib
popenv
popenv
popenv

echo Task: [124/142] /mingw32/toolchain/binutils/build
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/lib
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-mingw32
make -j4
popd
popenv
popenv
popenv

echo Task: [125/142] /mingw32/toolchain/binutils/install
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/lib
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-mingw32
make install prefix=${BUILD}/install/host-mingw32 exec_prefix=${BUILD}/install/host-mingw32 libdir=${BUILD}/install/host-mingw32/lib htmldir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html pdfdir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info mandir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/man datadir=${BUILD}/install/host-mingw32/share
popd
popenv
popenv
popenv

echo Task: [126/142] /mingw32/toolchain/binutils/postinstall
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenv
pushenvvar CPPFLAGS -I${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/include
pushenvvar LDFLAGS -L${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr/lib
pushd ${BUILD}/install/host-mingw32
rm lib/charset.alias
rm ./lib/libiberty.a
rmdir ./lib
popd
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-mingw32
make prefix=${BUILD}/install/host-mingw32 exec_prefix=${BUILD}/install/host-mingw32 libdir=${BUILD}/install/host-mingw32/lib htmldir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html pdfdir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info mandir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/man datadir=${BUILD}/install/host-mingw32/share install-html
popd
pushd ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-mingw32
make prefix=${BUILD}/install/host-mingw32 exec_prefix=${BUILD}/install/host-mingw32 libdir=${BUILD}/install/host-mingw32/lib htmldir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html pdfdir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info mandir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/man datadir=${BUILD}/install/host-mingw32/share install-pdf
popd
cp ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-mingw32/bfd/.libs/libbfd.a ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-mingw32/usr/lib
cp ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-mingw32/bfd/bfd.h ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-mingw32/usr/include
cp ${BUILD}/src/binutils-2012.03/bfd/elf-bfd.h ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-mingw32/usr/include
cp ${BUILD}/obj/binutils-2012.03-42-arm-none-symbianelf-mingw32/opcodes/.libs/libopcodes.a ${BUILD}/obj/host-binutils-2012.03-42-arm-none-symbianelf-mingw32/usr/lib
rm -f ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html/configure.html ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf/etc/configure.pdf
rm -f ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info/configure.info
install-info --infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info --remove-exactly configure
rm -f ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html/standards.html ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf/etc/standards.pdf
rm -f ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info/standards.info
install-info --infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info --remove-exactly standards
rmdir ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf/etc
rm -rf ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html/bfd.html ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf/bfd.pdf
rm -f ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info/bfd.info
install-info --infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info --remove-exactly bfd
rm -f ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html/libiberty.html ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf/libiberty.pdf
rm -f ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-ld.bfd.exe
rm -f ${BUILD}/install/host-mingw32/bin/ld.bfd.exe
rm -f ${BUILD}/install/host-mingw32/arm-none-symbianelf/bin/ld.bfd.exe
popenv
popenv
popenv

echo Task: [127/142] /mingw32/toolchain/copy_libs
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
copy_dir ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/share/doc/arm-arm-none-symbianelf/html ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html
copy_dir ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/share/doc/arm-arm-none-symbianelf/pdf ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf
copy_dir ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/share/doc/arm-arm-none-symbianelf/info ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info
copy_dir ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/share/doc/arm-arm-none-symbianelf/man ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/man
cp ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/share/doc/arm-arm-none-symbianelf/LICENSE.txt ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf
popenv

echo Task: [128/142] /mingw32/toolchain/gcc_final/configure
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
pushenvvar CC_FOR_TARGET arm-none-symbianelf-gcc
pushenvvar GCC_FOR_TARGET arm-none-symbianelf-gcc
pushenvvar CXX_FOR_TARGET arm-none-symbianelf-g++
rm -rf ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-mingw32
mkdir -p ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-mingw32
pushd ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-mingw32
${BUILD}/src/gcc-4.6-2012.03/configure --build=pc-linux-gnu --host=mingw32 --target=arm-none-symbianelf --enable-threads --disable-libmudflap --disable-libssp --disable-libstdcxx-pch --enable-extra-sgxxlite-multilibs --with-gnu-as --with-gnu-ld '--with-specs=%{save-temps: -fverbose-asm} -D__CS_SOURCERYGXX_MAJ__=2012 -D__CS_SOURCERYGXX_MIN__=3 -D__CS_SOURCERYGXX_REV__=42 %{O2:%{!fno-remove-local-statics: -fremove-local-statics}} %{O*:%{O|O0|O1|O2|Os:;:%{!fno-remove-local-statics: -fremove-local-statics}}}' --enable-languages=c,c++ --enable-shared --enable-lto --disable-hosted-libstdcxx '--with-pkgversion=Sacha GCC ${GCC_VER}' --with-bugurl=https://support.codesourcery.com/GNUToolchain/ --disable-nls --prefix=/opt/codesourcery --with-libiconv-prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --with-gmp=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --with-mpfr=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --with-mpc=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --with-ppl=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr '--with-host-libstdcxx=-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm' --with-cloog=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --with-libelf=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr --disable-libgomp --enable-poison-system-directories --with-build-time-tools=${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/arm-none-symbianelf/bin --with-build-time-tools=${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/arm-none-symbianelf/bin
popd
popenv
popenv

echo Task: [129/142] /mingw32/toolchain/gcc_final/build
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
pushenvvar CC_FOR_TARGET arm-none-symbianelf-gcc
pushenvvar GCC_FOR_TARGET arm-none-symbianelf-gcc
pushenvvar CXX_FOR_TARGET arm-none-symbianelf-g++
pushd ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-mingw32
make -j4 all-gcc
popd
popenv
popenv

echo Task: [130/142] /mingw32/toolchain/gcc_final/install
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
pushenvvar CC_FOR_TARGET arm-none-symbianelf-gcc
pushenvvar GCC_FOR_TARGET arm-none-symbianelf-gcc
pushenvvar CXX_FOR_TARGET arm-none-symbianelf-g++
pushd ${BUILD}/obj/gcc-2012.03-42-arm-none-symbianelf-mingw32
make prefix=${BUILD}/install/host-mingw32 exec_prefix=${BUILD}/install/host-mingw32 libdir=${BUILD}/install/host-mingw32/lib htmldir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html pdfdir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info mandir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/man install-gcc
make prefix=${BUILD}/install/host-mingw32 exec_prefix=${BUILD}/install/host-mingw32 libdir=${BUILD}/install/host-mingw32/lib htmldir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html pdfdir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info mandir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/man install-html-gcc
make prefix=${BUILD}/install/host-mingw32 exec_prefix=${BUILD}/install/host-mingw32 libdir=${BUILD}/install/host-mingw32/lib htmldir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html pdfdir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info mandir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/man install-pdf-gcc
popd
popenv
popenv

echo Task: [131/142] /mingw32/toolchain/gcc_final/postinstall
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushenv
pushenvvar AR_FOR_TARGET arm-none-symbianelf-ar
pushenvvar NM_FOR_TARGET arm-none-symbianelf-nm
pushenvvar OBJDUMP_FOR_TARET arm-none-symbianelf-objdump
pushenvvar STRIP_FOR_TARGET arm-none-symbianelf-strip
pushenvvar CC_FOR_TARGET arm-none-symbianelf-gcc
pushenvvar GCC_FOR_TARGET arm-none-symbianelf-gcc
pushenvvar CXX_FOR_TARGET arm-none-symbianelf-g++
pushd ${BUILD}/install/host-mingw32
rmdir include
popd
copy_dir ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/lib/gcc/arm-none-symbianelf ${BUILD}/install/host-mingw32/lib/gcc/arm-none-symbianelf
copy_dir ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/arm-none-symbianelf/lib ${BUILD}/install/host-mingw32/arm-none-symbianelf/lib
copy_dir ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/arm-none-symbianelf/include/c++ ${BUILD}/install/host-mingw32/arm-none-symbianelf/include/c++
rm -rf ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html/gccinstall ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf/gcc/gccinstall.pdf
rm -f ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info/gccinstall.info
install-info --infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info --remove-exactly gccinstall
rm -rf ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html/gccint ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf/gcc/gccint.pdf
rm -f ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info/gccint.info
install-info --infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info --remove-exactly gccint
rm -rf ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html/cppinternals ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf/gcc/cppinternals.pdf
rm -f ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info/cppinternals.info
install-info --infodir=${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/info --remove-exactly cppinternals
rm -f ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/html/libiberty.html ${BUILD}/install/host-mingw32/share/doc/arm-arm-none-symbianelf/pdf/libiberty.pdf
popenv
popenv

echo Task: [132/142] /mingw32/toolchain/zlib/0/copy
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
rm -rf ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-mingw32
copy_dir_clean ${BUILD}/src/zlib-1.2.3 ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-mingw32
chmod -R u+w ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-mingw32
popenv

echo Task: [133/142] /mingw32/toolchain/zlib/0/configure
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushd ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-mingw32
pushenv
pushenvvar CFLAGS '-O3 -fPIC'
pushenvvar CC 'mingw32-gcc '
pushenvvar AR 'mingw32-ar rc'
pushenvvar RANLIB mingw32-ranlib
./configure --prefix=${BUILD}/obj/host-libs-2012.03-42-arm-none-symbianelf-mingw32/usr
popenv
popd
popenv

echo Task: [134/142] /mingw32/toolchain/zlib/0/build
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushd ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-mingw32
make -j4
popd
popenv

echo Task: [135/142] /mingw32/toolchain/zlib/0/install
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushd ${BUILD}/obj/zlib-2012.03-42-arm-none-symbianelf-mingw32
make install
popd
popenv

echo Task: [136/142] /mingw32/pretidy_installation
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushd ${BUILD}/install/host-mingw32
popd
popenv

echo Task: [137/142] /mingw32/remove_libtool_archives
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
find ${BUILD}/install/host-mingw32 -name '*.la' -exec rm '{}' ';'
popenv

echo Task: [138/142] /mingw32/remove_copied_libs
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
popenv

echo Task: [139/142] /mingw32/remove_fixed_headers
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
pushd ${BUILD}/install/host-mingw32/lib/gcc/arm-none-symbianelf/${GCC_VER}/include-fixed
popd
popenv

echo Task: [140/142] /mingw32/add_tooldir_readme
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
cat > ${BUILD}/install/host-mingw32/arm-none-symbianelf/bin/README.txt <<'EOF0'
The executables in this directory are for internal use by the compiler
and may not operate correctly when used directly.  This directory
should not be placed on your PATH.  Instead, you should use the
executables in ../../bin/ and place that directory on your PATH.
EOF0
popenv

echo Task: [141/142] /mingw32/strip_host_objects
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-addr2line.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-ar.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-as.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-c++.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-c++filt.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-cpp.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-elfedit.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-g++.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-gcc-${GCC_VER}.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-gcc.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-gcov.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-gprof.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-ld.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-nm.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-objcopy.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-objdump.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-ranlib.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-readelf.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-size.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-strings.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/arm-none-symbianelf-strip.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/cs-make.exe
mingw32-strip ${BUILD}/install/host-mingw32/bin/cs-rm.exe
mingw32-strip ${BUILD}/install/host-mingw32/arm-none-symbianelf/bin/ar.exe
mingw32-strip ${BUILD}/install/host-mingw32/arm-none-symbianelf/bin/as.exe
mingw32-strip ${BUILD}/install/host-mingw32/arm-none-symbianelf/bin/c++.exe
mingw32-strip ${BUILD}/install/host-mingw32/arm-none-symbianelf/bin/g++.exe
mingw32-strip ${BUILD}/install/host-mingw32/arm-none-symbianelf/bin/gcc.exe
mingw32-strip ${BUILD}/install/host-mingw32/arm-none-symbianelf/bin/ld.exe
mingw32-strip ${BUILD}/install/host-mingw32/arm-none-symbianelf/bin/nm.exe
mingw32-strip ${BUILD}/install/host-mingw32/arm-none-symbianelf/bin/objcopy.exe
mingw32-strip ${BUILD}/install/host-mingw32/arm-none-symbianelf/bin/objdump.exe
mingw32-strip ${BUILD}/install/host-mingw32/arm-none-symbianelf/bin/ranlib.exe
mingw32-strip ${BUILD}/install/host-mingw32/arm-none-symbianelf/bin/strip.exe
mingw32-strip ${BUILD}/install/host-mingw32/libexec/gcc/arm-none-symbianelf/${GCC_VER}/cc1.exe
mingw32-strip ${BUILD}/install/host-mingw32/libexec/gcc/arm-none-symbianelf/${GCC_VER}/collect2.exe
mingw32-strip ${BUILD}/install/host-mingw32/libexec/gcc/arm-none-symbianelf/${GCC_VER}/install-tools/fixincl.exe
mingw32-strip ${BUILD}/install/host-mingw32/libexec/gcc/arm-none-symbianelf/${GCC_VER}/cc1plus.exe
mingw32-strip ${BUILD}/install/host-mingw32/libexec/gcc/arm-none-symbianelf/${GCC_VER}/lto-wrapper.exe
mingw32-strip ${BUILD}/install/host-mingw32/libexec/gcc/arm-none-symbianelf/${GCC_VER}/lto1.exe
popenv

echo Task: [142/142] /mingw32/package_tbz2
pushenv
pushenvvar CC_FOR_BUILD pc-linux-gnu-gcc
pushenvvar CC mingw32-gcc
pushenvvar CXX mingw32-g++
pushenvvar AR mingw32-ar
pushenvvar RANLIB mingw32-ranlib
prepend_path PATH ${BUILD}/obj/tools-pc-linux-gnu-2012.03-42-arm-none-symbianelf-mingw32/bin
rm -f ${BUILD}/pkg/arm-2012.03-42-arm-none-symbianelf-mingw32.tar.bz2
pushd ${BUILD}/install/host-mingw32
popd
pushd ${BUILD}/obj
rm -f arm-2012.03
ln -s ${BUILD}/install/host-mingw32 arm-2012.03
tar cjf ${BUILD}/pkg/arm-2012.03-42-arm-none-symbianelf-mingw32.tar.bz2 --owner=0 --group=0 --exclude=host-pc-linux-gnu --exclude=host-mingw32 arm-2012.03/arm-none-symbianelf arm-2012.03/bin arm-2012.03/lib arm-2012.03/libexec arm-2012.03/share
rm -f arm-2012.03
popd
popenv

echo "Complete. Files are in ${BUILD}/install or ${BUILD}/pkg/arm-2012.03-42-arm-none-symbianelf-pc-linux-gnu.tar.bz2"
