#!/bin/bash

#Absolute path to this script
SCRIPT=$(readlink -f "$0")
#Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")
NDK="/Users/yangjiayu/Library/Android/sdk/ndk/28.0.12433566"
ABI="arm64-v8a"
TOOLCHAIN="clang"

skip_build=0
skip_config=0
has_install=0
is_dry_run=0
has_test=0
PLATFORM=Android

CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}"
CONFIG_NAME=${CONFIG_NAME:-$PLATFORM-$CMAKE_BUILD_TYPE}
CMAKE_INSTALL_PREFIX="${PREFIX:-$PWD/out/install/$CONFIG_NAME}"

BUILD_FOLDER_NAME=build

EXTRA_CMAKE_OPTIONS="'-DLUA_DIR:PATH=${LUA_DIR:-${CMAKE_INSTALL_PREFIX}}' $EXTRA_CMAKE_OPTIONS"


BUILD_FOLDER="${BUILD_FOLDER:-$PWD/out/${BUILD_FOLDER_NAME}/$CONFIG_NAME}"

mkdir -p "$BUILD_FOLDER" || die "Cannot access build directory $BUILD_FOLDER" $?

eval "set -- $EXTRA_CMAKE_OPTIONS"
echo "CMAKE_BUILD_TYPE: $CMAKE_BUILD_TYPE"
cmake -DCMAKE_TOOLCHAIN_FILE=${NDK}/build/cmake/android.toolchain.cmake                 \
      -DANDROID=ON \
      -DANDROID_NDK=${NDK}                                                   \
      -DANDROID_ABI=${ABI}                                                        \
      -DANDROID_TOOLCHAIN_NAME=${TOOLCHAIN}                                       \                                                  \
      -DANDROID_NATIVE_API_LEVEL=29                                               \
      -DCMAKE_BUILD_TYPE=Release                                                  \
      -DCMAKE_BUILD_TYPE:STRING=$CMAKE_BUILD_TYPE \
      -DBUILD_ANDROID_PROJECTS=OFF \
      -DBUILD_ANDROID_EXAMPLES=OFF \
      -DCMAKE_CXX_STANDARD=20 \
      "-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}" \
      -S "$SCRIPTPATH" \
      -B "$BUILD_FOLDER" "$@"\
      $*      

cmake --build "$BUILD_FOLDER" -j8 || exit $?
cmake --install "$BUILD_FOLDER" --prefix "$CMAKE_INSTALL_PREFIX" || exit $?

