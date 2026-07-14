#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf _build$ndk_suffix
	exit 0
else
	exit 255
fi

[ -f configure ] || ./bootstrap

mkdir -p $build
cd $build

# libbluray has autotools
PKG_CONFIG_PATH=$prefix_dir/lib/pkgconfig \
../configure \
    --host=$ndk_triple \
    --disable-shared \
    --enable-static \
    --disable-bdjava-jar \
    --without-fontconfig

make -j$cores
make DESTDIR="$prefix_dir" install
