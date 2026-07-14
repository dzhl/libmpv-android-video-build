#!/bin/bash -e

. ../../include/depinfo.sh
. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	[ -f Makefile ] && make clean || true
	exit 0
else
	exit 255
fi

if [ -f Makefile ]; then
	$0 clean || true
fi

ssl_arch=""
[[ "$ndk_triple" == "aarch64"* ]] && ssl_arch="android-arm64"
[[ "$ndk_triple" == "arm"* ]] && ssl_arch="android-arm"
[[ "$ndk_triple" == "i686"* ]] && ssl_arch="android-x86"
[[ "$ndk_triple" == "x86_64"* ]] && ssl_arch="android-x86_64"

export ANDROID_NDK_ROOT="$DIR/sdk/android-sdk-linux/ndk/$v_ndk"

./Configure $ssl_arch -D__ANDROID_API__=21 no-shared --prefix="$prefix_dir"
make -j$cores
make install_sw
