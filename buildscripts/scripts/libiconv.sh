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

mkdir -p $build
cd $build

# libiconv has autotools
../configure \
    --host=$ndk_triple \
    --disable-shared \
    --enable-static \
    --prefix="$prefix_dir"

make -j$cores
make install

# GNU libiconv does not generate a pkg-config file, but meson needs it
mkdir -p "$prefix_dir"/lib/pkgconfig
cat >"$prefix_dir"/lib/pkgconfig/iconv.pc <<"END"
prefix=@PREFIX_DIR@
libdir=${prefix}/lib
includedir=${prefix}/include

Name: iconv
Description: GNU libiconv
Version: @ICONV_VERSION@
Libs: -L${libdir} -liconv
Cflags: -I${includedir}
END
sed -i "s|@PREFIX_DIR@|$prefix_dir|g" "$prefix_dir/lib/pkgconfig/iconv.pc"
sed -i "s|@ICONV_VERSION@|$v_libiconv|g" "$prefix_dir/lib/pkgconfig/iconv.pc"

# Hack: Meson's find_library() ignores user-provided -L flags when prefer-static is set.
# To ensure Meson finds libiconv.a without patching meson.build, we inject it directly into the NDK sysroot.
sysroot_dir="$toolchain/sysroot"
cp "$prefix_dir/lib/libiconv.a" "$sysroot_dir/usr/lib/$ndk_triple/" 2>/dev/null || cp "$prefix_dir/lib/libiconv.a" "$sysroot_dir/usr/lib/"
cp "$prefix_dir/include/iconv.h" "$sysroot_dir/usr/include/"
cp "$prefix_dir/include/localcharset.h" "$sysroot_dir/usr/include/" 2>/dev/null || true
cp "$prefix_dir/include/libcharset.h" "$sysroot_dir/usr/include/" 2>/dev/null || true
