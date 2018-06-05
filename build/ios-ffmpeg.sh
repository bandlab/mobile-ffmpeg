#!/bin/bash

if [[ -z ${ARCH} ]]; then
    echo "ARCH not defined"
    exit 1
fi

if [[ -z ${IOS_MIN_VERSION} ]]; then
    echo "IOS_MIN_VERSION not defined"
    exit 1
fi

if [[ -z ${TARGET_SDK} ]]; then
    echo "TARGET_SDK not defined"
    exit 1
fi

if [[ -z ${SDK_PATH} ]]; then
    echo "SDK_PATH not defined"
    exit 1
fi

if [[ -z ${BASEDIR} ]]; then
    echo "BASEDIR not defined"
    exit 1
fi

HOST_PKG_CONFIG_PATH=`type pkg-config 2>/dev/null | sed 's/.*is //g'`
if [[ -z ${HOST_PKG_CONFIG_PATH} ]]; then
    echo "pkg-config not found"
    exit 1
fi

# ENABLE COMMON FUNCTIONS
. ${BASEDIR}/build/ios-common.sh

# PREPARING PATHS & DEFINING ${INSTALL_PKG_CONFIG_DIR}
set_toolchain_clang_paths

# PREPARING FLAGS
TARGET_HOST=$(get_target_host)
FFMPEG_CFLAGS=""
FFMPEG_LDFLAGS=""
export PKG_CONFIG_PATH="${INSTALL_PKG_CONFIG_DIR}"

TARGET_CPU=""
TARGET_ARCH=""
NEON_FLAG=""
case ${ARCH} in
    armv7)
        TARGET_CPU="armv7"
        TARGET_ARCH="armv7"
        NEON_FLAG="	--enable-neon"
    ;;
    armv7s)
        TARGET_CPU="armv7s"
        TARGET_ARCH="armv7s"
        NEON_FLAG="	--enable-neon"
    ;;
    arm64)
        TARGET_CPU="armv8"
        TARGET_ARCH="aarch64"
        NEON_FLAG="	--enable-neon"
    ;;
    i386)
        TARGET_CPU="i386"
        TARGET_ARCH="i386"
        NEON_FLAG="	--disable-neon"
    ;;
    x86-64)
        TARGET_CPU="x86_64"
        TARGET_ARCH="x86_64"
        NEON_FLAG="	--disable-neon"
    ;;
esac

CONFIGURE_POSTFIX=""

for library in {1..26}
do
    if [[ ${!library} -eq 1 ]]; then
        ENABLED_LIBRARY=$(get_library_name $((library - 1)))

        echo -e "INFO: Enabling library ${ENABLED_LIBRARY}" >> ${BASEDIR}/build.log

        case $ENABLED_LIBRARY in
            fontconfig)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags fontconfig)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static fontconfig)"
                CONFIGURE_POSTFIX+=" --enable-libfontconfig"
            ;;
            freetype)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags freetype2)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static freetype2)"
                CONFIGURE_POSTFIX+=" --enable-libfreetype"
            ;;
            fribidi)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags fribidi)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static fribidi)"
                CONFIGURE_POSTFIX+=" --enable-libfribidi"
            ;;
            gmp)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags gmp)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static gmp)"
                CONFIGURE_POSTFIX+=" --enable-gmp"
            ;;
            gnutls)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags gnutls)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static gnutls)"
                CONFIGURE_POSTFIX+=" --enable-gnutls"
            ;;
            kvazaar)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags kvazaar)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static kvazaar)"
                CONFIGURE_POSTFIX+=" --enable-libkvazaar"
            ;;
            lame)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags libmp3lame)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static libmp3lame)"
                CONFIGURE_POSTFIX+=" --enable-libmp3lame"
            ;;
            libass)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags libass)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static libass)"
                CONFIGURE_POSTFIX+=" --enable-libass"
            ;;
            libiconv)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags libiconv)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static libiconv)"
                CONFIGURE_POSTFIX+=" --enable-iconv"
            ;;
            libtheora)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags theora)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static theora)"
                CONFIGURE_POSTFIX+=" --enable-libtheora"
            ;;
            libvorbis)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags vorbis)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static vorbis)"
                CONFIGURE_POSTFIX+=" --enable-libvorbis"
            ;;
            libvpx)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags vpx)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs vpx)"
                CONFIGURE_POSTFIX+=" --enable-libvpx"
            ;;
            libwebp)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags libwebp)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static libwebp)"
                CONFIGURE_POSTFIX+=" --enable-libwebp"
            ;;
            libxml2)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags libxml-2.0)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static libxml-2.0)"
                CONFIGURE_POSTFIX+=" --enable-libxml2"
            ;;
            opencore-amr)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags opencore-amrnb)"
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags opencore-amrwb)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static opencore-amrnb)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static opencore-amrwb)"
                CONFIGURE_POSTFIX+=" --enable-libopencore-amrnb"
                CONFIGURE_POSTFIX+=" --enable-libopencore-amrwb"
            ;;
            shine)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags shine)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static shine)"
                CONFIGURE_POSTFIX+=" --enable-libshine"
            ;;
            speex)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags speex)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static speex)"
                CONFIGURE_POSTFIX+=" --enable-libspeex"
            ;;
            wavpack)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags wavpack)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static wavpack)"
                CONFIGURE_POSTFIX+=" --enable-libwavpack"
            ;;
            libogg)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags ogg)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static ogg)"
            ;;
            libpng)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags libpng)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static libpng)"
            ;;
            libuuid)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags uuid)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static uuid)"
            ;;
            nettle)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags nettle)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static nettle)"
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags hogweed)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static hogweed)"
            ;;
            ios-zlib)
                FFMPEG_CFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --cflags zlib)"
                FFMPEG_LDFLAGS+=" $(${HOST_PKG_CONFIG_PATH} --libs --static zlib)"
                CONFIGURE_POSTFIX+=" --enable-zlib"
            ;;
        esac
    else
        if [[ ${library} -eq 26 ]]; then
            CONFIGURE_POSTFIX+=" --disable-zlib"
        fi
    fi
done

# CFLAGS PARTS
ARCH_CFLAGS=$(get_arch_specific_cflags);
APP_CFLAGS=$(get_app_specific_cflags "ffmpeg");
COMMON_CFLAGS=$(get_common_cflags);
OPTIMIZATION_CFLAGS=$(get_size_optimization_cflags "ffmpeg");
MIN_VERSION_CFLAGS=$(get_min_version_cflags);
COMMON_INCLUDES=$(get_common_includes);

# LDFLAGS PARTS
ARCH_LDFLAGS=$(get_arch_specific_ldflags);
LINKED_LIBRARIES=$(get_common_linked_libraries);
COMMON_LDFLAGS=$(get_common_ldflags);

# REORDERED FLAGS
CFLAGS="${ARCH_CFLAGS} ${APP_CFLAGS} ${COMMON_CFLAGS} ${OPTIMIZATION_CFLAGS} ${MIN_VERSION_CFLAGS} ${FFMPEG_CFLAGS} ${COMMON_INCLUDES}"
CXXFLAGS=$(get_cxxflags "ffmpeg")
LDFLAGS="${ARCH_LDFLAGS} ${FFMPEG_LDFLAGS} ${LINKED_LIBRARIES} ${COMMON_LDFLAGS}"

cd ${BASEDIR}/src/ffmpeg || exit 1

echo -n -e "\nffmpeg: "

make distclean 2>/dev/null 1>/dev/null

./configure \
    --sysroot=${SDK_PATH} \
    --prefix=${BASEDIR}/prebuilt/ios-$(get_target_host)/ffmpeg \
    --pkg-config="${HOST_PKG_CONFIG_PATH}" \
    --extra-cflags="${CFLAGS}" \
    --extra-cxxflags="${CXXFLAGS}" \
    --extra-ldflags="${LDFLAGS}" \
    --enable-version3 \
    --arch="${TARGET_ARCH}" \
    --cpu="${TARGET_CPU}" \
    --target-os=darwin \
    --ar="${AR}" \
    --cc="${CC}" \
    --cxx="${CXX}" \
    --as="${AS}" \
    --ranlib="${RANLIB}" \
    --strip="${STRIP}" \
    ${NEON_FLAG} \
    --enable-cross-compile \
    --enable-pic \
    --enable-asm \
    --enable-inline-asm \
    --enable-optimizations \
    --enable-small  \
    --enable-swscale \
    --enable-shared \
    --disable-xmm-clobber-test \
    --disable-debug \
    --disable-neon-clobber-test \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-videotoolbox \
    --disable-doc \
    --disable-htmlpages \
    --disable-manpages \
    --disable-podpages \
    --disable-txtpages \
    --disable-static \
    --disable-xlib \
    ${CONFIGURE_POSTFIX} 1>>${BASEDIR}/build.log 2>>${BASEDIR}/build.log

if [ $? -ne 0 ]; then
    echo "failed"
    exit 1
fi

make -j$(get_cpu_count) 1>>${BASEDIR}/build.log 2>>${BASEDIR}/build.log

if [ $? -ne 0 ]; then
    echo "failed"
    exit 1
fi

make install 1>>${BASEDIR}/build.log 2>>${BASEDIR}/build.log

if [ $? -ne 0 ]; then
    echo "failed"
    exit 1
fi

# MANUALLY ADD CONFIG HEADER
cp -f ${BASEDIR}/src/ffmpeg/config.h ${BASEDIR}/prebuilt/ios-$(get_target_host)/ffmpeg/include

if [ $? -eq 0 ]; then
    echo "ok"
else
    echo "failed"
    exit 1
fi