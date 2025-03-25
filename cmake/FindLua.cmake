# - Try to find LUA
#
# The following variables are optionally searched for defaults
#  LUA_ROOT_DIR:            Base directory where all LUA components are found
#
# The following are set after configuration is done: 
#  LUA_FOUND
#  LUA_INCLUDE_DIRS
#  LUA_LIBRARIES

include(${CMAKE_CURRENT_LIST_DIR}/3rd.cmake)
include(FindPackageHandleStandardArgs)

set(LUA_ROOT_DIR ${THIRDPARTY_PATH}/lua-5.4.3)
set(LUA_VERSION "5.4")

ENSURE_MODULE(${LUA_ROOT_DIR})

if(WIN32)
  set(WINDOWS_PLATFORM win64)
  set(CHECK_PLATFOR_VAR ${CMAKE_GENERATOR_PLATFORM})
  if ("${CMAKE_GENERATOR_PLATFORM}" STREQUAL "")
    set(CHECK_PLATFOR_VAR ${CMAKE_GENERATOR})
  endif()
  if (NOT "${CHECK_PLATFOR_VAR}" MATCHES "(Win64|IA64|x64)")
    set(WINDOWS_PLATFORM win32)
  endif()
endif()

if(WIN32)
  find_path(LUA_INCLUDE_DIR lua.hpp
    PATHS ${LUA_ROOT_DIR}/include)
elseif(ANDROID OR IOS)
  # because android.toolchain.cmake set CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY
  # so need set NO_CMAKE_FIND_ROOT_PATH
  find_path(LUA_INCLUDE_DIR lua.hpp
    HINTS ${LUA_ROOT_DIR}/include NO_CMAKE_FIND_ROOT_PATH)

else()
  find_path(LUA_INCLUDE_DIR lua.hpp
    HINTS ${LUA_ROOT_DIR}/include)
endif()

if(MSVC)
  find_library(LUA_LIBRARY_RELEASE lua${LUA_VERSION}.lib PATHS ${LUA_ROOT_DIR}/lib/${WINDOWS_PLATFORM}/Release)
  find_library(LUA_LIBRARY_DEBUG lua${LUA_VERSION}.lib PATHS ${LUA_ROOT_DIR}/lib/${WINDOWS_PLATFORM}/Debug)
  set(LUA_LIBRARY optimized ${LUA_LIBRARY_RELEASE} debug ${LUA_LIBRARY_DEBUG})
elseif(ANDROID)
  if(ANDROID_ABI MATCHES "^armeabi(-v7a)?$")
    find_library(LUA_LIBRARY lua${LUA_VERSION} HINTS ${LUA_ROOT_DIR}/lib/android/armeabi-v7a NO_CMAKE_FIND_ROOT_PATH)
  elseif(ANDROID_ABI STREQUAL arm64-v8a)
    find_library(LUA_LIBRARY lua${LUA_VERSION} HINTS ${LUA_ROOT_DIR}/lib/android/arm64-v8a NO_CMAKE_FIND_ROOT_PATH)
  else()
    message(FATAL_ERROR "Invalid Android ABI: ${ANDROID_ABI}.")
  endif()
elseif(IOS)
  find_library(LUA_LIBRARY lua${LUA_VERSION} HINTS ${LUA_ROOT_DIR}/lib/ios/arm64 NO_CMAKE_FIND_ROOT_PATH)
else()
  #find_library(LUA_LIBRARY lua${LUA_VERSION} HINTS ${LUA_ROOT_DIR}/lib/linux)
  list(APPEND LUA_INCLUDE_DIR ${LUA_ROOT_DIR}/include)
  unset(MY_LIBS)
  list(APPEND MY_LIBS lua${LUA_VERSION})
  FIND_LIBS_NO_ROOT(LUA_LIBRARY ${LUA_ROOT_DIR}/lib/linux ${MY_LIBS})
endif()

find_package_handle_standard_args(Lua DEFAULT_MSG
  LUA_INCLUDE_DIR LUA_LIBRARY)

if(LUA_FOUND)
  set(LUA_INCLUDE_DIRS ${LUA_INCLUDE_DIR})
  set(LUA_LIBRARIES ${LUA_LIBRARY})
  ENSURE_INSTALL(${LUA_ROOT_DIR})
endif()

message("LUA_FOUND= ${LUA_FOUND}")
message("LUA_INCLUDE_DIRS= ${LUA_INCLUDE_DIRS}")
message("LUA_LIBRARIES= ${LUA_LIBRARIES}")
