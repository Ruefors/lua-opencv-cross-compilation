# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

# If CMAKE_DISABLE_SOURCE_CHANGES is set to true and the source directory is an
# existing directory in our source tree, calling file(MAKE_DIRECTORY) on it
# would cause a fatal error, even though it would be a no-op.
if(NOT EXISTS "/Users/yangjiayu/project/lualib/lua-opencv-0.0.5/luarocks/luarocks-prefix/src/luarocks")
  file(MAKE_DIRECTORY "/Users/yangjiayu/project/lualib/lua-opencv-0.0.5/luarocks/luarocks-prefix/src/luarocks")
endif()
file(MAKE_DIRECTORY
  "/Users/yangjiayu/project/lualib/lua-opencv-0.0.5/luarocks/luarocks-prefix/src/luarocks-build"
  "/Users/yangjiayu/project/lualib/lua-opencv-0.0.5/luarocks/luarocks-prefix"
  "/Users/yangjiayu/project/lualib/lua-opencv-0.0.5/luarocks/luarocks-prefix/tmp"
  "/Users/yangjiayu/project/lualib/lua-opencv-0.0.5/luarocks/luarocks-prefix/src/luarocks-stamp"
  "/Users/yangjiayu/project/lualib/lua-opencv-0.0.5/luarocks/luarocks-prefix/src"
  "/Users/yangjiayu/project/lualib/lua-opencv-0.0.5/luarocks/luarocks-prefix/src/luarocks-stamp"
)

set(configSubDirs Debug;Release;MinSizeRel;RelWithDebInfo)
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/yangjiayu/project/lualib/lua-opencv-0.0.5/luarocks/luarocks-prefix/src/luarocks-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "/Users/yangjiayu/project/lualib/lua-opencv-0.0.5/luarocks/luarocks-prefix/src/luarocks-stamp${cfgdir}") # cfgdir has leading slash
endif()
