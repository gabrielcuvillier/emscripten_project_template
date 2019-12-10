# Copyright (c) 2019 Gabriel Cuvillier, Continuation Labs (www.continuation-labs.com)
# Licensed under CC0 1.0 Universal

##############################################
# Template CMake file for emscripten projects
##############################################
project(your_emscripten_project)

# Minimum version supported to be able to do "set(CMAKE_CXX_STANDARD 17)"
cmake_minimum_required(VERSION 3.8.2)

## Customizable Options

# Enable memory growth (unused if ENABLE_THREADS) (default=ON)
set(ALLOW_MEMORY_GROWTH 1)
# Total Fixed Memory (unused if ALLOW_MEMORY_GROWTH) (default=16MB)
set(TOTAL_MEMORY 16777216)
# Use 'O1' optimization level instead of O0 for Debug (default=ON)
set(ENABLE_O1 ON CACHE BOOL "Enable O1 build for Debug")
# Use 'Oz' optimization level instead of Os for MinSizeRel (default=ON)
set(ENABLE_OZ ON CACHE BOOL "Enable Oz build for MinSizeRel")
# Use 'O3' optimization level instead of O2 fo Release/RelWithDebInfo (default=ON)
set(ENABLE_O3 ON CACHE BOOL "Enable O3 build for Release/RelWithDebInfo")
# Use LTO (default=OFF)
set(ENABLE_LTO OFF CACHE BOOL "Enable LTO")
# Use 'Closure compiler' (unused if ENABLE_THREADS) (default=OFF)
set(ENABLE_CLOSURE OFF CACHE BOOL "Enable Closure compiler")
# Use Threads (default=OFF)
set(ENABLE_THREADS OFF CACHE BOOL "Enable Threads support")
# Thread pool size (unused if not ENABLE_THREADS) (default=3)
set(THREAD_POOL_SIZE 3)
# Use RTTI (default=OFF)
set(ENABLE_RTTI OFF CACHE BOOL "Enable RTTI")
# Use Exceptions (default=OFF)
set(ENABLE_EXCEPTIONS OFF CACHE BOOL "Enable Exceptions")
# Enable Embind (unused if ENABLE_THREADS) (default=OFF)
set(ENABLE_EMBIND OFF CACHE BOOL "Enable Embind")
# Enable extra compilations options (default=OFF)
set(ENABLE_EXTRA_COMPILATION_OPTIONS OFF CACHE BOOL "")

## Global compilation options

# Use C++ 17 standard for the whole project
set(CMAKE_CXX_STANDARD 17)

# Enable all warnings
add_compile_options(-Wall)
# Strict mode ON by default
add_compile_options("-s STRICT=1")

if (ENABLE_EXTRA_COMPILATION_OPTIONS)
  # save a couple of additional bytes...
  add_compile_options(-fno-c++-static-destructors)
endif ()

# LTO
if (ENABLE_LTO)
  add_compile_options(-flto)
endif ()

if (ENABLE_THREADS)
  add_compile_options(-threads)
  add_compile_options("-s USE_PTHREADS=1")
endif ()

if (ENABLE_EXCEPTIONS)
  add_compile_options(-fexceptions)
  add_compile_options("-s DISABLE_EXCEPTION_CATCHING=0")
else ()
  add_compile_options(-fno-exceptions)
  add_compile_options("-s DISABLE_EXCEPTION_CATCHING=1")
endif ()

if (ENABLE_RTTI)
  add_compile_options(-frtti)
else ()
  add_compile_options(-fno-rtti)
endif ()

SET(CMAKE_EXE_LINKER_FLAGS "" CACHE INTERNAL "")

if (ENABLE_O1)
  SET(CMAKE_C_FLAGS_DEBUG "-O1 -g2" CACHE INTERNAL "")
  SET(CMAKE_CXX_FLAGS_DEBUG "-O1 -g2" CACHE INTERNAL "")
  SET(CMAKE_EXE_LINKER_FLAGS_DEBUG "-O1 -g2" CACHE INTERNAL "")
else ()
  SET(CMAKE_C_FLAGS_DEBUG "-O0 -g2" CACHE INTERNAL "")
  SET(CMAKE_CXX_FLAGS_DEBUG "-O0 -g2" CACHE INTERNAL "")
  SET(CMAKE_EXE_LINKER_FLAGS_DEBUG "-O0 -g2" CACHE INTERNAL "")
endif ()

if (ENABLE_O3)
  SET(CMAKE_C_FLAGS_RELEASE "-O3" CACHE INTERNAL "")
  SET(CMAKE_C_FLAGS_RELWITHDEBINFO "-O3 -g2" CACHE INTERNAL "")
  SET(CMAKE_CXX_FLAGS_RELEASE "-O3" CACHE INTERNAL "")
  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O3 -g2" CACHE INTERNAL "")
  SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "-O3" CACHE INTERNAL "")
  SET(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "-O3" CACHE INTERNAL "")
else ()
  SET(CMAKE_C_FLAGS_RELEASE "-O2" CACHE INTERNAL "")
  SET(CMAKE_C_FLAGS_RELWITHDEBINFO "-O2 -g2" CACHE INTERNAL "")
  SET(CMAKE_CXX_FLAGS_RELEASE "-O2" CACHE INTERNAL "")
  SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g2" CACHE INTERNAL "")
  SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "-O2" CACHE INTERNAL "")
  SET(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "-O2" CACHE INTERNAL "")
endif ()

if (ENABLE_OZ)
  SET(CMAKE_C_FLAGS_MINSIZEREL "-Oz" CACHE INTERNAL "")
  SET(CMAKE_CXX_FLAGS_MINSIZEREL "-Oz" CACHE INTERNAL "")
  SET(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "-Oz" CACHE INTERNAL "")
else()
  SET(CMAKE_C_FLAGS_MINSIZEREL "-Os" CACHE INTERNAL "")
  SET(CMAKE_CXX_FLAGS_MINSIZEREL "-Os" CACHE INTERNAL "")
  SET(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "-Os" CACHE INTERNAL "")
endif ()

## Linker options

# Assertions => by default, this is driven by optimization flags.
#set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s ASSERTIONS=1")

# Do not exit the runtime => this is already the default
# set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s EXIT_RUNTIME=0")

# Force Strict mode
set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s STRICT=1")

# Memory requirements
if (ENABLE_THREADS)
  set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s TOTAL_MEMORY=${TOTAL_MEMORY}")
else ()
  if (ALLOW_MEMORY_GROWTH)
    set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s ALLOW_MEMORY_GROWTH=1")
  else ()
    set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s TOTAL_MEMORY=${TOTAL_MEMORY}")
  endif ()
endif ()

# Force Modularize the output
set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s MODULARIZE=1")

# Force exposition of Filesystem JS code to module object
#set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s FORCE_FILESYSTEM=1")

# Enable embind, as it is almost always used
if (ENABLE_EMBIND AND NOT ENABLE_THREADS)
  set(emscripten_common_ldflags "${emscripten_common_ldflags} --bind")
endif ()

# Optionally enable JS closure compiler
if (ENABLE_CLOSURE AND NOT ENABLE_THREADS)
  set(emscripten_common_ldflags "${emscripten_common_ldflags} --closure 1")
endif ()

# Set back standard behavior fo malloc (does not abort on failure)
set(emscripten_common_ldflags "${emscripten_common_ldflags} -s ABORTING_MALLOC=0")

# Additional linker option for LTO
if (ENABLE_LTO)
  set(emscripten_common_ldflags "${emscripten_common_ldflags} --llvm-lto 1")
  set(emscripten_common_ldflags "${emscripten_common_ldflags} -s WASM_OBJECT_FILES=0")
endif ()

if (ENABLE_EXCEPTIONS)
  set(emscripten_common_ldflags "${emscripten_common_ldflags} -s DISABLE_EXCEPTION_CATCHING=0")
else ()
  set(emscripten_common_ldflags "${emscripten_common_ldflags} -s DISABLE_EXCEPTION_CATCHING=1")
endif ()

# Specific thread options
if (ENABLE_THREADS)
  set(emscripten_common_ldflags "${emscripten_common_ldflags} \
                                  -s USE_PTHREADS=1 \
                                  -s PTHREAD_POOL_SIZE=${THREAD_POOL_SIZE} \
                                  -s ALLOW_BLOCKING_ON_MAIN_THREAD=1")
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
# Environment is 'web', unless with Threads enabled for which 'worker' is additionally needed
if (ENABLE_THREADS)
  set(emscripten_main_ldflags "${emscripten_main_ldflags}   -s ENVIRONMENT=web,worker")
else ()
  set(emscripten_main_ldflags "${emscripten_main_ldflags}   -s ENVIRONMENT=web")
endif ()

# Export as ES6 module
# set(emscripten_main_ldflags "${emscripten_main_ldflags} -s EXPORT_ES6=1")
# set(emscripten_main_ldflags "${emscripten_main_ldflags} -s USE_ES6_IMPORT_META=0")

# GL Tweaking to reduce JS support code
#set(emscripten_main_ldflags "${emscripten_main_ldflags} -s GL_POOL_TEMP_BUFFERS=0")
#set(emscripten_main_ldflags "${emscripten_main_ldflags} -s GL_TRACK_ERRORS=0")
# Other misc tweakings to reduce size
#set(emscripten_main_ldflags "${emscripten_main_ldflags} -s SUPPORT_LONGJMP=0")
#set(emscripten_main_ldflags "${emscripten_main_ldflags} -s SUPPORT_ERRNO=0")

# Worker thread linker options
# Environment is 'worker'
set(emscripten_worker_ldflags "${emscripten_worker_ldflags}   -s ENVIRONMENT=worker")
