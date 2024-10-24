# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

# If CMAKE_DISABLE_SOURCE_CHANGES is set to true and the source directory is an
# existing directory in our source tree, calling file(MAKE_DIRECTORY) on it
# would cause a fatal error, even though it would be a no-op.
if(NOT EXISTS "/Users/yangjiayu/project/lualib/lua-opencv-cross-compilation/out/build/Android-Release/_deps/lua-src")
  file(MAKE_DIRECTORY "/Users/yangjiayu/project/lualib/lua-opencv-cross-compilation/out/build/Android-Release/_deps/lua-src")
endif()
file(MAKE_DIRECTORY
  "/Users/yangjiayu/project/lualib/lua-opencv-cross-compilation/out/build/Android-Release/_deps/lua-build"
  "/Users/yangjiayu/project/lualib/lua-opencv-cross-compilation/out/build/Android-Release/_deps/lua-subbuild/lua-populate-prefix"
  "/Users/yangjiayu/project/lualib/lua-opencv-cross-compilation/out/build/Android-Release/_deps/lua-subbuild/lua-populate-prefix/tmp"
  "/Users/yangjiayu/project/lualib/lua-opencv-cross-compilation/out/build/Android-Release/_deps/lua-subbuild/lua-populate-prefix/src/lua-populate-stamp"
  "/Users/yangjiayu/project/lualib/lua-opencv-cross-compilation/out/build/Android-Release/_deps/lua-subbuild/lua-populate-prefix/src"
  "/Users/yangjiayu/project/lualib/lua-opencv-cross-compilation/out/build/Android-Release/_deps/lua-subbuild/lua-populate-prefix/src/lua-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/yangjiayu/project/lualib/lua-opencv-cross-compilation/out/build/Android-Release/_deps/lua-subbuild/lua-populate-prefix/src/lua-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/Users/yangjiayu/project/lualib/lua-opencv-cross-compilation/out/build/Android-Release/_deps/lua-subbuild/lua-populate-prefix/src/lua-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
