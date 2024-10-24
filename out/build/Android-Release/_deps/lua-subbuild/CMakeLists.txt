# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.30.5)

# Reject any attempt to use a toolchain file. We must not use one because
# we could be downloading it here. If the CMAKE_TOOLCHAIN_FILE environment
# variable is set, the cache variable will have been initialized from it.
unset(CMAKE_TOOLCHAIN_FILE CACHE)
unset(ENV{CMAKE_TOOLCHAIN_FILE})

# We name the project and the target for the ExternalProject_Add() call
# to something that will highlight to the user what we are working on if
# something goes wrong and an error message is produced.

project(lua-populate NONE)



include(ExternalProject)
ExternalProject_Add(lua-populate
                     "UPDATE_DISCONNECTED" "False" "DOWNLOAD_EXTRACT_TIMESTAMP" "FALSE" "EXTERNALPROJECT_INTERNAL_ARGUMENT_SEPARATOR" "URL" "https://sources.buildroot.net/lua/lua-5.4.6.tar.gz" "https://ftp.wrz.de/pub/BLFS/conglomeration/lua/lua-5.4.6.tar.gz" "https://ftp2.osuosl.org/pub/blfs/conglomeration/lua/lua-5.4.6.tar.gz" "https://mirror-hk.koddos.net/blfs/conglomeration/lua/lua-5.4.6.tar.gz" "https://mirror.dogado.de/BLFS/conglomeration/lua/lua-5.4.6.tar.gz" "https://mirror.koddos.net/blfs/conglomeration/lua/lua-5.4.6.tar.gz" "https://repo.jing.rocks/blfs/conglomeration/lua/lua-5.4.6.tar.gz" "https://www.lua.org/ftp/lua-5.4.6.tar.gz" "URL_HASH" "SHA256=7d5ea1b9cb6aa0b59ca3dde1c6adcb57ef83a1ba8e5432c0ecd06bf439b3ad88" "PATCH_COMMAND" "/usr/bin/patch" "-p" "1" "-d" "<SOURCE_DIR>" "-i" "/Users/yangjiayu/project/lualib/lua-opencv-cross-compilation/lua/patches/001-lua-5.4-src.patch"
                    SOURCE_DIR          "/Users/yangjiayu/project/lualib/lua-opencv-cross-compilation/out/build/Android-Release/_deps/lua-src"
                    BINARY_DIR          "/Users/yangjiayu/project/lualib/lua-opencv-cross-compilation/out/build/Android-Release/_deps/lua-build"
                    CONFIGURE_COMMAND   ""
                    BUILD_COMMAND       ""
                    INSTALL_COMMAND     ""
                    TEST_COMMAND        ""
                    USES_TERMINAL_DOWNLOAD  YES
                    USES_TERMINAL_UPDATE    YES
                    USES_TERMINAL_PATCH     YES
)


