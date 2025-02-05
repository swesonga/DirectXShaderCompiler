# Find the TAEF path that supports x86 and x64.
get_filename_component(WINDOWS_KIT_10_PATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot10]" ABSOLUTE CACHE)
get_filename_component(WINDOWS_KIT_81_PATH "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot81]" ABSOLUTE CACHE)

# Find the TAEF path, it will typically look something like this.
# "C:\Program Files (x86)\Windows Kits\8.1\Testing\Development\inc"
set(pfx86 "programfiles(x86)")  # Work around behavior for environment names allows chars.
find_path(TAEF_INCLUDE_DIR      # Set variable TAEF_INCLUDE_DIR
          Wex.Common.h          # Find a path with Wex.Common.h
          HINTS "$ENV{TAEF_PATH}/../../../Include"
          HINTS "$ENV{TAEF_PATH}/../../../Development/inc"
          HINTS "${CMAKE_SOURCE_DIR}/external/taef/build/Include"
          HINTS "${WINDOWS_KIT_10_PATH}/Testing/Development/inc"
          HINTS "${WINDOWS_KIT_81_PATH}/Testing/Development/inc"
          DOC "path to TAEF header files"
          HINTS
          )

macro(find_taef_libraries targetplatform)
  set(TAEF_LIBRARIES)
  foreach(L Te.Common.lib Wex.Common.lib Wex.Logger.lib)
    find_library(TAEF_LIB_${L} NAMES ${L}
                HINTS ${TAEF_INCLUDE_DIR}/../Library/${targetplatform}
                HINTS ${TAEF_INCLUDE_DIR}/../lib/${targetplatform})
    set(TAEF_LIBRARIES ${TAEF_LIBRARIES} ${TAEF_LIB_${L}})
  endforeach()
  set(TAEF_COMMON_LIBRARY ${TAEF_LIB_Te.Common.lib})
endmacro(find_taef_libraries)

if(CMAKE_C_COMPILER_ARCHITECTURE_ID STREQUAL "ARM64EC")
  find_taef_libraries(arm64)
elseif(CMAKE_C_COMPILER_ARCHITECTURE_ID STREQUAL "ARMV7")
  find_taef_libraries(arm)
else()
  find_taef_libraries(${CMAKE_C_COMPILER_ARCHITECTURE_ID})
endif()

set(TAEF_INCLUDE_DIRS ${TAEF_INCLUDE_DIR})

# Get TAEF binaries path from the header location
set(TAEF_NUGET_BIN ${TAEF_INCLUDE_DIR}/../Binaries/Release)
set(TAEF_SDK_BIN ${TAEF_INCLUDE_DIR}/../../Runtimes/TAEF)

find_program(TAEF_EXECUTABLE te.exe PATHS
  $ENV{HLSL_TAEF_DIR}/${CMAKE_C_COMPILER_ARCHITECTURE_ID}
  ${TAEF_NUGET_BIN}/${CMAKE_C_COMPILER_ARCHITECTURE_ID}
  ${TAEF_SDK_BIN}/${CMAKE_C_COMPILER_ARCHITECTURE_ID}
  ${WINDOWS_KIT_10_PATH}
  ${WINDOWS_KIT_81_PATH}
  )

if (TAEF_EXECUTABLE)
  get_filename_component(TAEF_BIN_DIR ${TAEF_EXECUTABLE} DIRECTORY)
else()
  message(ERROR "Unable to find TAEF binaries.")
endif()

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set TAEF_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(TAEF  DEFAULT_MSG
                                  TAEF_COMMON_LIBRARY TAEF_INCLUDE_DIR)

mark_as_advanced(TAEF_INCLUDE_DIR TAEF_LIBRARY)
