file(TO_NATIVE_PATH "${CMAKE_SOURCE_DIR}" VS_DEBUGGER_WORKING_DIRECTORY)
file(TO_NATIVE_PATH "${CMAKE_SOURCE_DIR}/luarocks/lua.bat" VS_DEBUGGER_COMMAND)

get_filename_component(OPENCV_SAMPLES_DATA_PATH "${opencv_SOURCE_DIR}/samples/data" REALPATH)
file(TO_NATIVE_PATH "${OPENCV_SAMPLES_DATA_PATH}" OPENCV_SAMPLES_DATA_PATH)

set_target_properties(${target_name} PROPERTIES
  VS_DEBUGGER_COMMAND           "${VS_DEBUGGER_COMMAND}"
  VS_DEBUGGER_COMMAND_ARGUMENTS "samples/01-show-image.lua"
  VS_DEBUGGER_WORKING_DIRECTORY "${VS_DEBUGGER_WORKING_DIRECTORY}"
  VS_DEBUGGER_ENVIRONMENT       "BUILD_TYPE=$(Configuration)\nOPENCV_SAMPLES_DATA_PATH=${OPENCV_SAMPLES_DATA_PATH}"
)

set_property(DIRECTORY "${CMAKE_SOURCE_DIR}" PROPERTY VS_STARTUP_PROJECT ${target_name})