#!/bin/sh
set -e

SDL_VERSION="SDL2-2.0.14"
SDL_SRC_ROOT="/tmp/${SDL_VERSION}"
ARCH="$1"

if [ ! -d "${SDL_SRC_ROOT}" ]; then
  wget -qO- https://www.libsdl.org/release/${SDL_VERSION}.tar.gz | tar xz -C /tmp
fi

case "${ARCH}" in
  "armv6l")
    export CFLAGS="-march=armv6zk -mfloat-abi=hard -mfpu=vfp"
    export LDFLAGS="-march=armv6zk -mfloat-abi=hard -mfpu=vfp"
    ;;
  "armv7l")
    export CFLAGS="-march=armv7-a -mfloat-abi=hard -mfpu=neon"
    export LDFLAGS="-march=armv7-a -mfloat-abi=hard -mfpu=neon"
    ;;
  *)
    echo "Argument must be an architecture of [armv6l, armv7l]"
    exit 1
    ;;
esac

VIDEO_DRIVER_FLAGS="--enable-video-rpi --enable-video-kmsdrm --enable-video-x11"

cd "${SDL_SRC_ROOT}"
rm -rf "${SDL_SRC_ROOT}/build"
./configure ${VIDEO_DRIVER_FLAGS} --disable-video-wayland --disable-video-dummy --disable-video-opengl --disable-video-vulkan
make ${MAKE_FLAGS:--j2}
cd -

TARGET="${SDL_VERSION}-${ARCH}-pi"
TARGET_ROOT="./${TARGET}"

if [ -d "${TARGET_ROOT}" ]; then
  rm -r "${TARGET_ROOT}"/*
fi

cp -L "${SDL_SRC_ROOT}/build/.libs/libSDL2-2.0.so.0" "${TARGET_ROOT}/libSDL2.so"
strip "${TARGET_ROOT}/libSDL2.so"

tar -czf "${TARGET}.tar.gz" ${TARGET}
