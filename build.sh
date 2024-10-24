#!/bin/bash

die() {
    echo "ERROR: $1" 1>&2
    [ $2 ] && exit $2 || exit 1
}

SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

skip_build=0
skip_config=0
has_install=0
is_dry_run=0
has_test=0
GENERATOR=
PLATFORM=android-26
TARGET=all
ANDROID_NDK_PATH="/Users/yangjiayu/Library/Android/sdk/ndk/21.1.6352462"

print_help() {
    echo '
Usage: ./build.sh [options]

Options:
    --help|h|help               显示帮助信息
    --dry-run                   显示将要执行的命令而不实际运行它们
    --g                         仅生成 CMake 配置
    --d                         使用 Debug 编译类型
    --no-config                 不生成 CMake 配置
    --build                     仅构建
    --no-build                  不构建
    --install                   执行安装
    --test                      执行测试
    -G <generator-name>         指定生成系统 ('${GENERATOR}')
    -A <platform-name>          指定平台 ('${PLATFORM}')
    --prefix <directory>        安装目录 ('$PREFIX')
    --target <target-name>      构建目标 ('$TARGET')
    --ndk <ndk-path>            Android NDK 路径 ('$ANDROID_NDK_PATH')
'
}

ac_opt=0
ac_prev=
for ac_option in "$@"; do
    if test ${#ac_prev} -ne 0; then
        eval "$ac_prev='$ac_option'"
        ac_prev=
        continue
    fi

    case "$ac_option" in
        --dry-run)
            is_dry_run=1
            continue
            ;;
        -d)
            CMAKE_BUILD_TYPE=Debug
            continue
            ;;
        -g)
            skip_build=1
            skip_config=0
            continue
            ;;
        --no-config)
            skip_config=1
            continue
            ;;
        --build)
            skip_build=0
            skip_config=1
            continue
            ;;
        --no-build)
            skip_build=1
            continue
            ;;
        --install)
            has_install=1
            continue
            ;;
        --test)
            has_test=1
            continue
            ;;
        -D*)
            EXTRA_CMAKE_OPTIONS="$EXTRA_CMAKE_OPTIONS '$ac_option'"
            continue
            ;;
        --ndk)
            ac_prev=ANDROID_NDK_PATH
            continue
            ;;
    esac

    case "$ac_option" in
        *=*)
            ac_opt=0
            key="${ac_option%%=*}"
            value="${ac_option#*=}"
            ;;
        *)
            ac_opt=1
            key="${ac_option}"
            value=
            ;;
    esac

    case "$key" in
        -C)
            key=--binary-dir
            ;;
        -G)
            key=--generator
            ;;
        -G*)
            if test $ac_opt -eq 1; then
                ac_opt=0
                value="${key:2}"
                key=--generator
            else
                echo "Unknown option $key" 1>&2
                exit 1
            fi
            ;;
        -A)
            key=--platform
            ;;
        --config)
            key=--config-name
            ;;
        --binary-dir|--generator|--platform|--config-name )
            echo "Unknown option $key" 1>&2
            exit 1
            ;;
    esac

    case "$key" in
        --binary-dir|--generator|--platform|--prefix|--target|--config-name|--ndk )
            key="${key:2}"
            key="${key//-/_}"

            if test $ac_opt -eq 1; then
                ac_prev="${key^^}"
            else
                eval "${key^^}='${value}'"
            fi
            ;;
        --help|-h|-help )
            print_help
            exit 0
            ;;
        * )
            echo "Unknown option $key" 1>&2
            exit 1
            ;;
    esac
done

try_run=
test $is_dry_run -eq 0 || try_run="echo "

CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}"
CONFIG_NAME=${CONFIG_NAME:-Android-$CMAKE_BUILD_TYPE}
CMAKE_INSTALL_PREFIX="${PREFIX:-$PWD/out/install/$CONFIG_NAME}"

if [[ "$TARGET" == 'lua' || "$TARGET" == 'luajit' || "$TARGET" == 'luarocks' ]]; then
    export LUA_ONLY=ON
    BUILD_FOLDER_NAME=build.luaonly
else
    BUILD_FOLDER_NAME=build
fi

if [[ "$TARGET" != 'lua' && "$TARGET" != 'luajit' ]]; then
    EXTRA_CMAKE_OPTIONS="'-DLUA_DIR:PATH=${LUA_DIR:-${CMAKE_INSTALL_PREFIX}}' $EXTRA_CMAKE_OPTIONS"
fi

BUILD_FOLDER="${BUILD_FOLDER:-$PWD/out/${BUILD_FOLDER_NAME}/$CONFIG_NAME}"
${try_run}mkdir -p "$BUILD_FOLDER" || die "Cannot access build directory $BUILD_FOLDER" $?

TOOLCHAIN_FILE="$ANDROID_NDK_PATH/build/cmake/android.toolchain.cmake"

eval "set -- $EXTRA_CMAKE_OPTIONS"

test $skip_config -eq 1 || ${try_run}cmake \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
    -DANDROID_ABI="arm64-v8a" \
    -DANDROID_PLATFORM="$PLATFORM" \
    -DCMAKE_BUILD_TYPE:STRING=$CMAKE_BUILD_TYPE \
    "-DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_INSTALL_PREFIX}" \
    -S "$SCRIPTPATH" -B "$BUILD_FOLDER" "$@" || exit $?

test $skip_build -eq 1 || ${try_run}cmake --build "$BUILD_FOLDER" --target $TARGET -j$(nproc) || exit $?
test $has_install -eq 0 || ${try_run}cmake --install "$BUILD_FOLDER" --prefix "$CMAKE_INSTALL_PREFIX" || exit $?

if test $has_test -eq 1; then
    LUA_CPATH="$("$BUILD_FOLDER/bin/luajit" -e 'print(package.cpath)');$BUILD_FOLDER/luajit/lib/?.so" \
    ctest -C $CMAKE_BUILD_TYPE -R test_build

    if test -x "$CMAKE_INSTALL_PREFIX/bin/luajit"; then
        LUA_CPATH="$("$CMAKE_INSTALL_PREFIX/bin/luajit" -e 'print(package.cpath)');$CMAKE_INSTALL_PREFIX/lib/lua/?.so" \
        ctest -C $CMAKE_BUILD_TYPE -R test_install
    fi
fi