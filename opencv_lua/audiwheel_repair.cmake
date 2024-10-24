cmake_minimum_required(VERSION 3.25)

macro(cmake_script_append_var content_var)
  foreach(var_name ${ARGN})
    set(${content_var} "${${content_var}}
set(${var_name} \"${${var_name}}\")
")
  endforeach()
endmacro()

if (NOT ENABLE_REPAIR)
  #
  # Configuration for standalone repair
  #
  set(REPAIR_CONFIG_SCRIPT "")
  cmake_script_append_var(REPAIR_CONFIG_SCRIPT
    target_name
    PROJECT_VERSION
    Python3_EXECUTABLE
    CMAKE_SOURCE_DIR
    CMAKE_CURRENT_SOURCE_DIR
    CMAKE_CURRENT_BINARY_DIR
    TARGET_FILE
  )
  set(repair_rock_config "${CMAKE_SOURCE_DIR}/luarocks/lua_modules/repair_rock_config.cmake")
  file(WRITE "${repair_rock_config}" "${REPAIR_CONFIG_SCRIPT}")

  return()
endif()

include("${CMAKE_SOURCE_DIR}/luarocks/lua_modules/repair_rock_config.cmake")

message(STATUS "PostInstall: CMAKE_SOURCE_DIR = \"${CMAKE_SOURCE_DIR}\"")
message(STATUS "PostInstall: CMAKE_CURRENT_SOURCE_DIR = \"${CMAKE_CURRENT_SOURCE_DIR}\"")
message(STATUS "PostInstall: CMAKE_CURRENT_BINARY_DIR = \"${CMAKE_CURRENT_BINARY_DIR}\"")
message(STATUS "PostInstall: CMAKE_INSTALL_PREFIX = \"${CMAKE_INSTALL_PREFIX}\"")
message(STATUS "PostInstall: CMAKE_INSTALL_LIBDIR = \"${CMAKE_INSTALL_LIBDIR}\"")
message(STATUS "PostInstall: TARGET_FILE = \"${TARGET_FILE}\"")
message(STATUS "PostInstall: PACKAGE_DATA = \"${PACKAGE_DATA}\"")
message(STATUS "PostInstall: CMAKE_INSTALL_LIBSDIR = \"${CMAKE_INSTALL_LIBSDIR}\"")
message(STATUS "PostInstall: target_name = \"${target_name}\"")

# !!! Do not remove, otherwise you may end up deleting you whole OS files
if (NOT (target_name MATCHES "^[A-Za-z0-9_]+$"))
  message(FATAL_ERROR "For security reasons, target name variable cannot be empty and must only contains alpha numeric characters")
endif()

get_filename_component(LIB_NAME "${TARGET_FILE}" NAME)

set(INSTALL_LIBDIR "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}")
set(INSTALL_LIB_NAME "${INSTALL_LIBDIR}/${LIB_NAME}")

message(STATUS "PostInstall: Set non-toolchain portion of runtime path of \"${INSTALL_LIB_NAME}\"")

set(PYPROJECT "${CMAKE_CURRENT_BINARY_DIR}/pyproject")

file(REMOVE_RECURSE "${PYPROJECT}/")

configure_file("${CMAKE_CURRENT_SOURCE_DIR}/setup.py.in" "${PYPROJECT}/setup.py" @ONLY)
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/pyproject.toml" "${PYPROJECT}/pyproject.toml" COPYONLY)

execute_process(
  COMMAND "${Python3_EXECUTABLE}" -m build --wheel
  WORKING_DIRECTORY "${PYPROJECT}"
  OUTPUT_VARIABLE WHEEL_BUILD_LOGS
  COMMAND_ECHO STDERR
  OUTPUT_STRIP_TRAILING_WHITESPACE
  COMMAND_ERROR_IS_FATAL ANY
)

# get WHEEL_FILE
string(REGEX MATCH "Successfully built (.+)" WHEEL_FILE "${WHEEL_BUILD_LOGS}")
string(LENGTH "Successfully built " WHEEL_FILE_BEGIN)
string(LENGTH "${WHEEL_FILE}" WHEEL_FILE_LENGTH)
math(EXPR WHEEL_FILE_LENGTH "${WHEEL_FILE_LENGTH} - ${WHEEL_FILE_BEGIN}")
string(SUBSTRING "${WHEEL_FILE}" ${WHEEL_FILE_BEGIN} ${WHEEL_FILE_LENGTH} WHEEL_FILE)

message(STATUS "PostInstall: WHEEL_FILE=\"${WHEEL_FILE}\"")

# get LD_LIBRARY_PATH
execute_process(
  COMMAND readelf -d "${TARGET_FILE}"
  WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
  OUTPUT_VARIABLE ELF_SYMBOLS
  COMMAND_ECHO STDERR
  OUTPUT_STRIP_TRAILING_WHITESPACE
  COMMAND_ERROR_IS_FATAL ANY
)

string(REGEX MATCH "Library rpath: \\[([^]]+)\\]" LD_LIBRARY_PATH "${ELF_SYMBOLS}")
string(LENGTH "Library rpath: [" LD_LIBRARY_PATH_BEGIN)
string(LENGTH "${LD_LIBRARY_PATH}" LD_LIBRARY_PATH_LENGTH)
math(EXPR LD_LIBRARY_PATH_LENGTH "${LD_LIBRARY_PATH_LENGTH} - ${LD_LIBRARY_PATH_BEGIN} - 1")
string(SUBSTRING "${LD_LIBRARY_PATH}" ${LD_LIBRARY_PATH_BEGIN} ${LD_LIBRARY_PATH_LENGTH} LD_LIBRARY_PATH)

message(STATUS "PostInstall: LD_LIBRARY_PATH=\"${LD_LIBRARY_PATH}\"")

set(ENV{LD_LIBRARY_PATH} "${LD_LIBRARY_PATH}")

execute_process(
  COMMAND "${Python3_EXECUTABLE}" -m auditwheel repair "dist/${WHEEL_FILE}"
  WORKING_DIRECTORY "${PYPROJECT}"
  ERROR_VARIABLE AUDITWHEEL_BUILD_LOGS
  COMMAND_ECHO STDERR
  ERROR_STRIP_TRAILING_WHITESPACE
  COMMAND_ERROR_IS_FATAL ANY
)

# get FIXED_WHEEL_FILE
string(REGEX MATCH "Fixed-up wheel written to (.+)" FIXED_WHEEL_FILE "${AUDITWHEEL_BUILD_LOGS}")
string(LENGTH "Fixed-up wheel written to " FIXED_WHEEL_FILE_BEGIN)
string(LENGTH "${FIXED_WHEEL_FILE}" FIXED_WHEEL_FILE_LENGTH)
math(EXPR FIXED_WHEEL_FILE_LENGTH "${FIXED_WHEEL_FILE_LENGTH} - ${FIXED_WHEEL_FILE_BEGIN}")
string(SUBSTRING "${FIXED_WHEEL_FILE}" ${FIXED_WHEEL_FILE_BEGIN} ${FIXED_WHEEL_FILE_LENGTH} FIXED_WHEEL_FILE)

message(STATUS "PostInstall: FIXED_WHEEL_FILE=\"${FIXED_WHEEL_FILE}\"")

# Replace shared library with the fixed one
execute_process(
  COMMAND unzip -o -d "${INSTALL_LIBDIR}" "${FIXED_WHEEL_FILE}" "${target_name}/*" "${target_name}.libs/*"
  WORKING_DIRECTORY "${PYPROJECT}"
  COMMAND_ECHO STDERR
  COMMAND_ERROR_IS_FATAL ANY
)

file(REMOVE_RECURSE "${CMAKE_INSTALL_PREFIX}/${target_name}.libs/")

execute_process(
  COMMAND bash -c "cp -rf ${CMAKE_INSTALL_LIBDIR}/${target_name}/${target_name} ${CMAKE_INSTALL_LIBDIR}/${target_name}/${LIB_NAME} ${CMAKE_INSTALL_LIBDIR}/"
  COMMAND mv "${CMAKE_INSTALL_LIBDIR}/${target_name}.libs" ./
  WORKING_DIRECTORY "${CMAKE_INSTALL_PREFIX}"
  COMMAND_ECHO STDERR
  COMMAND_ERROR_IS_FATAL ANY
)

execute_process(
  COMMAND rm -rf "${target_name}/${LIB_NAME}" "${target_name}/${target_name}"
  WORKING_DIRECTORY "${INSTALL_LIBDIR}"
  COMMAND_ECHO STDERR
  COMMAND_ERROR_IS_FATAL ANY
)

# Set RPATH to $ORIGIN/${target_name}/libs
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/set_rpath.py.in" "${PYPROJECT}/set_rpath.py" @ONLY)
execute_process(
  COMMAND "${Python3_EXECUTABLE}" "${PYPROJECT}/set_rpath.py"
  WORKING_DIRECTORY "${INSTALL_LIBDIR}"
  COMMAND_ECHO STDERR
  COMMAND_ERROR_IS_FATAL ANY
)
