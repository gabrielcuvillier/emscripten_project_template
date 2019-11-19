# Copyright (c) 2019 Gabriel Cuvillier, Continuation Labs (www.continuation-labs.com)
# Licensed under CC0 1.0 Universal

##############################################
# Template CMake file for emscripten projects
##############################################
project(your_emscripten_project)

# Minimum version supported to be able to do "set(CMAKE_CXX_STANDARD 17)"
cmake_minimum_required(VERSION 3.8.2)

## Customizable Options

# Use 'O1' optimization level instead of O2 for RelWithDebInfo (default=ON)
set(ENABLE_O1 ON CACHE BOOL "Enable O1 build for RelWithDebInfo")
# Use 'Oz' optimization level instead of Os for MinSizeRel (default=OFF)
set(ENABLE_OZ OFF CACHE BOOL "Enable Oz build for MinSizeRel")
# Use 'O3' optimization level instead of O2 fo Release (default=OFF)
set(ENABLE_O3 OFF CACHE BOOL "Enable O3 build for Release")
# Use LTO for MinSizeRel (default=OFF)
set(ENABLE_LTO OFF CACHE BOOL "Enable LTO")
# Use 'Closure compiler' (default=OFF)
set(ENABLE_CLOSURE OFF CACHE BOOL "Enable Closure compiler")

## Global compilation options

# Use C++ 17 standard for the whole project
set(CMAKE_CXX_STANDARD 17)

# Enable all warnings
add_compile_options(-Wall)
add_compile_options(-Wextra)
# disable exception support
add_compile_options(-fno-exceptions)
# enable Emscripten STRICT mode for compilation
add_compile_options(-s STRICT=1)
# save a couple of additional bytes...
add_compile_options(-fno-c++-static-destructors)

# LTO
if (ENABLE_LTO)
  add_compile_options(-flto)
endif ()

# Oz and MinSizeRel
if (ENABLE_OZ)
  string(REGEX MATCH "-Os" IS_Os_CXX "${CMAKE_CXX_FLAGS_MINSIZEREL}")
  if (IS_Os_CXX)
    string(REGEX REPLACE "-Os" "-Oz" CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL}")
  else ()
    set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} -Oz")
  endif ()

  string(REGEX MATCH "-Os" IS_Os_C "${CMAKE_C_FLAGS_MINSIZEREL}")
  if (IS_Os_C)
    string(REGEX REPLACE "-Os" "-Oz" CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL}")
  else ()
    set(CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} -Oz")
  endif ()

  string(REGEX MATCH "-Os" IS_Os_EXE "${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL}")
  if (IS_Os_EXE)
    string(REGEX REPLACE "-Os" "-Oz" CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL}")
  else ()
    set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL} -Oz")
  endif ()
endif ()

# O3 and Release
if (ENABLE_O3)
  string(REGEX MATCH "-O2" IS_O2_CXX "${CMAKE_CXX_FLAGS_RELEASE}")
  if (IS_O2_CXX)
    string(REGEX REPLACE "-O2" "-O3" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
  else ()
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
  endif ()

  string(REGEX MATCH "-O2" IS_O2_C "${CMAKE_C_FLAGS_RELEASE}")
  if (IS_O2_C)
    string(REGEX REPLACE "-O2" "-O3" CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")
  else ()
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3")
  endif ()

  string(REGEX MATCH "-O2" IS_O2_EXE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
  if (IS_O2_EXE)
    string(REGEX REPLACE "-O2" "-O3" CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
  else ()
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} -O3")
  endif ()
endif ()

# O1 and RelWithDebInfo
if (ENABLE_O1)
  string(REGEX MATCH "-O2" IS_O2_CXX "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
  if (IS_O2_CXX)
    string(REGEX REPLACE "-O2" "-O1" CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
  else ()
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -O1")
  endif ()

  string(REGEX MATCH "-O2" IS_O2_C "${CMAKE_C_FLAGS_RELWITHDEBINFO}")
  if (IS_O2_C)
    string(REGEX REPLACE "-O2" "-O1" CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO}")
  else ()
    set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} -O1")
  endif ()

  string(REGEX MATCH "-O2" IS_O2_EXE "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO}")
  if (IS_O2_EXE)
    string(REGEX REPLACE "-O2" "-O1" CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO}")
  else ()
    set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO} -O1")
  endif ()
endif ()

## Linker options

# Assertions => by default, this is driven by optimization flags.
#set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s ASSERTIONS=1")

# Do not exit the runtime => this is already the default
# set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s EXIT_RUNTIME=0")

# Force Strict mode
set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s STRICT=1")

# Initial memory size
# set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s TOTAL_MEMORY=<whatever_needed>")

# Force Allow memory growth
set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s ALLOW_MEMORY_GROWTH=1")

# Force Modularize the output
set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s MODULARIZE=1")

# Force exposition of Filesystem JS code to module object
#set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s FORCE_FILESYSTEM=1")

# Enable embind, as it is almost always used
set(emscripten_common_ldflags "${emscripten_common_ldflags} --bind")

# Optionally enable JS closure compiler
if (ENABLE_CLOSURE)
  set(emscripten_common_ldflags "${emscripten_common_ldflags} --closure 1")
endif ()

# Set back standard behavior (malloc does not abort on failure)
set(emscripten_common_ldflags "${emscripten_common_ldflags} -s ABORTING_MALLOC=0")

#set(emscripten_common_ldflags "${emscripten_common_ldflags} -s PRECISE_F32=2")

# Additional linker option for LTO
if (ENABLE_LTO)
  set(emscripten_common_ldflags "${emscripten_common_ldflags} --llvm-lto 1")
  set(emscripten_common_ldflags "${emscripten_common_ldflags} -s WASM_OBJECT_FILES=0")
endif ()

#if (SOURCE_MAP)
#set(emscripten_common_ldflags "${emscripten_common_ldflags} --source-map-base ${CMAKE_CURRENT_BINARY_DIR}")
#set(emscripten_common_ldflags "${emscripten_common_ldflags} --pre-js $ENV{EMSCRIPTEN}/src/emscripten-source-map.min.js")
#endif()

# setup environment variables
set(emscripten_common_ldflags "${emscripten_common_ldflags} --pre-js ${CMAKE_CURRENT_SOURCE_DIR}/src/js/environment_variables.js")

# LONGJMP support code
#set(emscripten_common_ldflags "${emscripten_common_ldflags} -s SUPPORT_LONGJMP=0")

# export Filesystem functions to JS (definitively needed in case CLOSURE compiler is used)
set(emscripten_common_ldflags "${emscripten_common_ldflags} --post-js ${CMAKE_CURRENT_SOURCE_DIR}/src/js/export_fs.js")
set(emscripten_common_ldflags "${emscripten_common_ldflags} -s EXTRA_EXPORTED_RUNTIME_METHODS=[\"FS\",\"FS_readFile\",\"FS_mkdir\",\"FS_writeFile\",\"FS_unlink\",\"FS_mount\"\"FS_rmdir\"]")

# typical exports, so that closure compiler does not change their names
set(emscripten_common_ldflags "${emscripten_common_ldflags} -s EXTRA_EXPORTED_RUNTIME_METHODS=[\"ENV\",\"IDBFS\",\"FS_readFile\",\"FS_mkdir\",\"FS_writeFile\",\"FS_unlink\",\"FS_mount\",\"FS_rmdir\",\"FS_createPath\",\"FS_syncfs\"]")

# Main browser thread linker options
# Environment is 'web'
set(emscripten_main_ldflags "${emscripten_main_ldflags}   -s ENVIRONMENT=web")
# Export as ES6 module
# set(emscripten_main_ldflags "${emscripten_main_ldflags} -s EXPORT_ES6=1")
# set(emscripten_main_ldflags "${emscripten_main_ldflags} -s USE_ES6_IMPORT_META=0")

# GL Tweaking to reduce JS support code
#set(emscripten_main_ldflags "${emscripten_main_ldflags} -s GL_POOL_TEMP_BUFFERS=0")
#set(emscripten_main_ldflags "${emscripten_main_ldflags} -s GL_TRACK_ERRORS=0")

#set(emscripten_main_ldflags "${emscripten_main_ldflags} -s SUPPORT_LONGJMP=0")

# Worker thread linker options
# Environment is 'worker'
set(emscripten_worker_ldflags "${emscripten_worker_ldflags}   -s ENVIRONMENT=worker")
