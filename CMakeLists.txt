# Copyright (c) 2019 Gabriel Cuvillier, Continuation Labs (www.continuation-labs.com)
# Licensed under CC0 1.0 Universal

# Template CMake file for emscripten projects
project(your_emscripten_project)

cmake_minimum_required(VERSION 3.8.2)

# Global options
set(CMAKE_CXX_STANDARD 17)

# Use LTO for MinSizeRel (default=OFF)
set(ENABLE_LTO OFF CACHE BOOL "Enable LTO")
# Use 'Oz' optimization level instead of Os for MinSizeRel (default=OFF)
set(ENABLE_OZ OFF CACHE BOOL "Enable Oz build for MinSizeRel")
# Use 'O3' optimization level instead of O2 fo Release (default=OFF)
set(ENABLE_O3 OFF CACHE BOOL "Enable O3 build for Release")
# Use 'O1' optimization level instead of O2 for RelWithDebInfo (default=ON)
set(ENABLE_O1 ON CACHE BOOL "Enable O1 build for RelWithDebInfo")
# Use CLOSURE compiler
set(ENABLE_CLOSURE OFF CACHE BOOL "Enable Closure compiler")

# Enable all warnings
add_compile_options(-Wall -Wextra)

# disable exception support
add_compile_options(-fno-exceptions)

# enable Emscripten STRICT mode
add_compile_options(-s STRICT=1)

# LTO support (only in MinSizeRel)
if (ENABLE_LTO)
  set(CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} -s WASM_OBJECT_FILES=0 -flto")
  set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} -s WASM_OBJECT_FILES=0 -flto")
  set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL} -s WASM_OBJECT_FILES=0 --llvm-lto 1 -flto")
endif ()

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

# Common linker options

  # Assertions => by default, this is driven by optimization flags.
  #set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s ASSERTIONS=1")

  # Force to not exit the runtime
  set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s EXIT_RUNTIME=0")

  # Force Strict mode
  set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s STRICT=1")

  # Initial memory size
  # set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s TOTAL_MEMORY=<whatever_needed>")

  # Force Allow memory growth
  set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s ALLOW_MEMORY_GROWTH=1")

  # Force Modularize the output
  set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s MODULARIZE=1")

  # Force exposition of Filesystem JS code to module object
  set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s FORCE_FILESYSTEM=1")

  # Enable embind, as it is almost always used
  set(emscripten_common_ldflags "${emscripten_common_ldflags} --bind")

  # Optionally enable JS closure compiler
  if (ENABLE_CLOSURE)
    set(emscripten_common_ldflags "${emscripten_common_ldflags} --closure 1")
  endif ()

  # setup environment variables
  set(emscripten_common_ldflags "${emscripten_common_ldflags} --pre-js ${CMAKE_CURRENT_SOURCE_DIR}/src/js/environment_variables.js")

  # export Filesystem functions to JS (definitively needed in case CLOSURE compiler is used)
  set(emscripten_common_ldflags "${emscripten_common_ldflags} --post-js ${CMAKE_CURRENT_SOURCE_DIR}/src/js/export_fs.js")
  set(emscripten_common_ldflags "${emscripten_common_ldflags} -s EXTRA_EXPORTED_RUNTIME_METHODS=[\"FS\",\"FS_readFile\",\"FS_mkdir\",\"FS_writeFile\",\"FS_unlink\",\"FS_mount\"]")

  # Main browser thread linker options
  # Environment is 'web'
  set(emscripten_main_ldflags "${emscripten_main_ldflags}   -s ENVIRONMENT=web")
  # Export as ES6 module
  # set(emscripten_main_ldflags "${emscripten_main_ldflags}   -s EXPORT_ES6=1")

  # Worker thread linker options
  # Environment is 'worker'
  set(emscripten_worker_ldflags "${emscripten_worker_ldflags}   -s ENVIRONMENT=worker")
