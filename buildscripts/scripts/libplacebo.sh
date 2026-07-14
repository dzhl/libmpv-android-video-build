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

unset CC CXX

# Android provides Vulkan, but no pkgconfig file
# you can double-check the version in vk.xml (ctrl+f VK_API_VERSION)
mkdir -p "$prefix_dir"/lib/pkgconfig
cat >"$prefix_dir"/lib/pkgconfig/vulkan.pc <<"END"
Name: Vulkan
Description:
Version: 1.2.0
Cflags:
END

# libplacebo uses meson
meson setup $build --cross-file "$prefix_dir"/crossfile.txt \
	--prefer-static \
	--default-library static \
	--prefix=$prefix_dir \
	-Dvulkan=enabled \
	-Dshaderc=enabled \
	-Dglslang=disabled \
	-Ddemos=false

ninja -C $build -j$cores
ninja -C $build install
