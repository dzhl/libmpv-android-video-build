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

unset CC CXX # meson wants these unset

# Meson famously forbids pkg-config for iconv, so we MUST use standard C compiler environment variables 
# to tell the compiler where our sysroot dependencies (like libiconv.a) are located.
# CPATH and LIBRARY_PATH are processed natively by clang without emitting unused argument warnings.
export CPATH="$prefix_dir/include"
export LIBRARY_PATH="$prefix_dir/lib"

meson setup $build --cross-file "$prefix_dir"/crossfile.txt \
	-Dc_args="-I$prefix_dir/include" \
	-Dc_link_args="-L$prefix_dir/lib" \
	--prefer-static \
	--default-library shared \
	-Dgpl=false \
	-Dlibmpv=true \
 	-Dlua=disabled \
 	-Dcplayer=false \
 	-Diconv=enabled \
	-Dvulkan=enabled \
   	-Dlibplacebo=enabled \
 	-Dmanpage-build=disabled

ninja -C $build -j$cores
DESTDIR="$prefix_dir" ninja -C $build install

ln -sf "$prefix_dir"/lib/libmpv.so "$native_dir"
