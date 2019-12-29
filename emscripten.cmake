# Copyright (c) 2019 Gabriel Cuvillier, Continuation Labs (www.continuation-labs.com)
# Licensed under CC0 1.0 Universal

##############################################
# Template CMake file for emscripten projects
##############################################
SET(CMAKE_EXE_LINKER_FLAGS "")
SET(CMAKE_EXE_LINKER_FLAGS_DEBUG "")
SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "")
SET(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL "")
SET(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "")
SET(CMAKE_CXX_FLAGS "")
SET(CMAKE_CXX_FLAGS_DEBUG "")
SET(CMAKE_CXX_FLAGS_RELEASE "")
SET(CMAKE_CXX_FLAGS_MINSIZEREL "")
SET(CMAKE_CXX_FLAGS_RELWITHDEBINFO "")
SET(CMAKE_C_FLAGS "")
SET(CMAKE_C_FLAGS_DEBUG "")
SET(CMAKE_C_FLAGS_RELEASE "")
SET(CMAKE_C_FLAGS_MINSIZEREL "")
SET(CMAKE_C_FLAGS_RELWITHDEBINFO "")

## Customizable Options

# Enable memory growth (unused if ENABLE_THREADS) (default=ON)
option(ALLOW_MEMORY_GROWTH "Enable Memory Growth" ON)
# Total Fixed Memory (unused if ALLOW_MEMORY_GROWTH) (default=16MB)
set(TOTAL_MEMORY 16777216 CACHE INTERNAL "Total fixed wasm memory")
# Use 'O1' optimization level instead of O0 for Debug (default=ON)
option(ENABLE_O1 "Enable O1 build for Debug" ON)
# Use 'Oz' optimization level instead of Os for MinSizeRel (default=ON)
option(ENABLE_OZ "Enable Oz build for MinSizeRel" ON)
# Use 'O3' optimization level instead of O2 fo Release/RelWithDebInfo (default=ON)
option(ENABLE_O3 "Enable O3 build for Release/RelWithDebInfo" ON)
# Use LTO (default=OFF)
option(ENABLE_LTO "Enable LTO" OFF)
# Use 'Closure compiler' (unused if ENABLE_THREADS) (default=OFF)
option(ENABLE_CLOSURE "Enable Closure compiler" OFF)
# Use Threads (default=OFF)
option(ENABLE_THREADS "Enable Threads support" OFF)
# Thread pool size (unused if not ENABLE_THREADS) (default=3)
set(THREAD_POOL_SIZE 3 CACHE INTERNAL "")
# Use RTTI (default=OFF)
option(ENABLE_RTTI "Enable RTTI" OFF)
# Enable Longjmp
option(ENABLE_LONGJMP "Enable setjmp/longjmp" ON)
# Enable Errno
option(ENABLE_ERRNO "Enable errno" ON)
# Use Exceptions (default=OFF)
option(ENABLE_EXCEPTIONS "Enable Exceptions" OFF)
# Enable Embind (unused if ENABLE_THREADS) (default=OFF)
option(ENABLE_EMBIND "Enable Embind" OFF)
# Enable extra compilations options (default=OFF)
option(ENABLE_EXTRA_COMPILATION_OPTIONS "" OFF)

option(ENABLE_MODULARIZE "" ON)

option(ENABLE_LZ4 "" OFF)

set(BROWSER_CONTEXT "MAIN_THREAD" CACHE INTERNAL "Browser Context: MAIN_THREAD or WORKER")
set_property(CACHE BROWSER_CONTEXT PROPERTY STRINGS MAIN_THREAD WORKER)

set(JS_PACKAGING_MODE "ESM" CACHE INTERNAL "JS packaging mode: Bundling (with Closure compiler) or ES6 module imports")
set_property(CACHE JS_PACKAGING_MODE PROPERTY STRINGS BUNDLE ESM)

set(BUNDLING_MODE "SIMPLE" CACHE INTERNAL "Closure compiler bundling mode: BUNDLE, SIMPLE, ADVANCED")
set_property(CACHE BUNDLING_MODE PROPERTY STRINGS BUNDLE SIMPLE ADVANCED)

## Global compilation options

function(configure_emscripten_target target)

  unset(emscripten_c_flags)
  unset(emscripten_c_defs)
  unset(emscripten_c_flags_DEBUG)
  unset(emscripten_c_defs_DEBUG)
  unset(emscripten_c_flags_RELEASE)
  unset(emscripten_c_defs_RELEASE)
  unset(emscripten_c_flags_MINSIZEREL)
  unset(emscripten_c_defs_MINSIZEREL)
  unset(emscripten_c_flags_RELWITHDEBINFO)
  unset(emscripten_c_defs_RELWITHDEBINFO)
  unset(emscripten_cxx_flags)
  unset(emscripten_cxx_defs)
  unset(emscripten_cxx_flags_DEBUG)
  unset(emscripten_cxx_defs_DEBUG)
  unset(emscripten_cxx_flags_RELEASE)
  unset(emscripten_cxx_defs_RELEASE)
  unset(emscripten_cxx_flags_MINSIZEREL)
  unset(emscripten_cxx_defs_MINSIZEREL)
  unset(emscripten_cxx_flags_RELWITHDEBINFO)
  unset(emscripten_cxx_defs_RELWITHDEBINFO)
  unset(emscripten_exe_linker_flags)
  unset(emscripten_exe_linker_flags_DEBUG)
  unset(emscripten_exe_linker_flags_RELEASE)
  unset(emscripten_exe_linker_flags_MINSIZEREL)
  unset(emscripten_exe_linker_flags_RELWITHDEBINFO)

  # Strict mode ON by default
  list(APPEND emscripten_c_flags "SHELL:-s STRICT=1")
  list(APPEND emscripten_cxx_flags "SHELL:-s STRICT=1")

  if (ENABLE_EXTRA_COMPILATION_OPTIONS)
    # save a couple of additional bytes...
    list(APPEND emscripten_cxx_flags -fno-c++-static-destructors)
  endif ()

  # LTO
  if (ENABLE_LTO)
    list(APPEND emscripten_c_flags -flto)
    list(APPEND emscripten_cxx_flags -flto)
  endif ()

  if (ENABLE_THREADS)
    list(APPEND emscripten_c_flags -threads)
    list(APPEND emscripten_c_flags "SHELL:-s USE_PTHREADS=1")
    list(APPEND emscripten_cxx_flags -threads)
    list(APPEND emscripten_cxx_flags "SHELL:-s USE_PTHREADS=1")
  endif ()

  if (ENABLE_EXCEPTIONS)
    list(APPEND emscripten_cxx_flags -fexceptions)
    list(APPEND emscripten_cxx_flags "SHELL:-s DISABLE_EXCEPTION_CATCHING=0")
  else ()
    list(APPEND emscripten_cxx_flags -fno-exceptions)
    list(APPEND emscripten_cxx_flags "SHELL:-s DISABLE_EXCEPTION_CATCHING=1")
  endif ()

  if (ENABLE_RTTI)
    list(APPEND emscripten_cxx_flags -frtti)
  else ()
    list(APPEND emscripten_cxx_flags -fno-rtti)
  endif ()

  if (ENABLE_O1)
    LIST(APPEND emscripten_c_flags_DEBUG -O1 -g2)
    LIST(APPEND emscripten_c_defs_DEBUG _DEBUG)
    LIST(APPEND emscripten_cxx_flags_DEBUG -O1 -g2)
    LIST(APPEND emscripten_cxx_defs_DEBUG _DEBUG)
    LIST(APPEND emscripten_exe_linker_flags_DEBUG -O1 -g2)
  else ()
    LIST(APPEND emscripten_c_flags_DEBUG -O0 -g2)
    LIST(APPEND emscripten_c_defs_DEBUG _DEBUG)
    LIST(APPEND emscripten_cxx_flags_DEBUG -O0 -g2)
    LIST(APPEND emscripten_cxx_defs_DEBUG _DEBUG)
    LIST(APPEND emscripten_exe_linker_flags_DEBUG -O0 -g2)
  endif ()

  if (ENABLE_O3)
    LIST(APPEND emscripten_c_flags_RELEASE -O3)
    LIST(APPEND emscripten_c_defs_RELEASE NDEBUG)
    LIST(APPEND emscripten_c_flags_RELWITHDEBINFO -O3 -g2)
    LIST(APPEND emscripten_cxx_flags_RELEASE -O3)
    LIST(APPEND emscripten_cxx_defs_RELEASE NDEBUG)
    LIST(APPEND emscripten_cxx_flags_RELWITHDEBINFO -O3 -g2)
    LIST(APPEND emscripten_exe_linker_flags_RELEASE -O3)
    LIST(APPEND emscripten_exe_linker_flags_RELWITHDEBINFO -O3)
  else ()
    LIST(APPEND emscripten_c_flags_RELEASE -O2)
    LIST(APPEND emscripten_c_defs_RELEASE NDEBUG)
    LIST(APPEND emscripten_c_flags_RELWITHDEBINFO -O2 -g2)
    LIST(APPEND emscripten_cxx_flags_RELEASE -O2)
    LIST(APPEND emscripten_cxx_defs_RELEASE NDEBUG)
    LIST(APPEND emscripten_cxx_flags_RELWITHDEBINFO -O2 -g2)
    LIST(APPEND emscripten_exe_linker_flags_RELEASE -O2)
    LIST(APPEND emscripten_exe_linker_flags_RELWITHDEBINFO -O2)
  endif ()

  if (ENABLE_OZ)
    LIST(APPEND emscripten_c_flags_MINSIZEREL -Oz)
    LIST(APPEND emscripten_c_defs_MINSIZEREL NDEBUG)
    LIST(APPEND emscripten_cxx_flags_MINSIZEREL -Oz)
    LIST(APPEND emscripten_cxx_defs_MINSIZEREL NDEBUG)
    LIST(APPEND emscripten_exe_linker_flags_MINSIZEREL -Oz)
  else ()
    LIST(APPEND emscripten_c_flags_MINSIZEREL -Os)
    LIST(APPEND emscripten_c_defs_MINSIZEREL NDEBUG)
    LIST(APPEND emscripten_cxx_flags_MINSIZEREL -Os)
    LIST(APPEND emscripten_cxx_defs_MINSIZEREL NDEBUG)
    LIST(APPEND emscripten_exe_linker_flags_MINSIZEREL -Os)
  endif ()

  target_compile_options(${target} PRIVATE
          $<$<COMPILE_LANGUAGE:CXX>:${emscripten_cxx_flags}>
          $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CONFIG:DEBUG>>:${emscripten_cxx_flags_DEBUG}>
          $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CONFIG:RELEASE>>:${emscripten_cxx_flags_RELEASE}>
          $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CONFIG:MINSIZEREL>>:${emscripten_cxx_flags_MINSIZEREL}>
          $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CONFIG:RELWITHDEBINFO>>:${emscripten_cxx_flags_RELWITHDEBINFO}>
          $<$<COMPILE_LANGUAGE:C>:${emscripten_c_flags}>
          $<$<AND:$<COMPILE_LANGUAGE:C>,$<CONFIG:DEBUG>>:${emscripten_cxx_flags_DEBUG}>
          $<$<AND:$<COMPILE_LANGUAGE:C>,$<CONFIG:RELEASE>>:${emscripten_cxx_flags_RELEASE}>
          $<$<AND:$<COMPILE_LANGUAGE:C>,$<CONFIG:MINSIZEREL>>:${emscripten_cxx_flags_MINSIZEREL}>
          $<$<AND:$<COMPILE_LANGUAGE:C>,$<CONFIG:RELWITHDEBINFO>>:${emscripten_cxx_flags_RELWITHDEBINFO}>
          )

  target_compile_definitions(${target} PRIVATE
          $<$<COMPILE_LANGUAGE:CXX>:${emscripten_cxx_defs}>
          $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CONFIG:DEBUG>>:${emscripten_cxx_defs_DEBUG}>
          $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CONFIG:RELEASE>>:${emscripten_cxx_defs_RELEASE}>
          $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CONFIG:MINSIZEREL>>:${emscripten_cxx_defs_MINSIZEREL}>
          $<$<AND:$<COMPILE_LANGUAGE:CXX>,$<CONFIG:RELWITHDEBINFO>>:${emscripten_cxx_defs_RELWITHDEBINFO}>
          $<$<COMPILE_LANGUAGE:C>:${emscripten_c_defs}>
          $<$<AND:$<COMPILE_LANGUAGE:C>,$<CONFIG:DEBUG>>:${emscripten_cxx_defs_DEBUG}>
          $<$<AND:$<COMPILE_LANGUAGE:C>,$<CONFIG:RELEASE>>:${emscripten_cxx_defs_RELEASE}>
          $<$<AND:$<COMPILE_LANGUAGE:C>,$<CONFIG:MINSIZEREL>>:${emscripten_cxx_defs_MINSIZEREL}>
          $<$<AND:$<COMPILE_LANGUAGE:C>,$<CONFIG:RELWITHDEBINFO>>:${emscripten_cxx_defs_RELWITHDEBINFO}>
          )

  ## Linker options

  # Assertions => by default, this is driven by optimization flags.
  #set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s ASSERTIONS=1")

  LIST(APPEND emscripten_exe_linker_flags "SHELL:-s EXPORT_NAME=${target}")

  # Do not exit the runtime => this is already the default
  LIST(APPEND emscripten_exe_linker_flags "SHELL:-s EXIT_RUNTIME=0")

  # Force Strict mode
  LIST(APPEND emscripten_exe_linker_flags "SHELL:-s STRICT=1")

  # Memory requirements
  if (ENABLE_THREADS)
    LIST(APPEND emscripten_exe_linker_flags "SHELL:-s TOTAL_MEMORY=${TOTAL_MEMORY}")
  else ()
    if (ALLOW_MEMORY_GROWTH)
      LIST(APPEND emscripten_exe_linker_flags "SHELL:-s ALLOW_MEMORY_GROWTH=1")
    else ()
      LIST(APPEND emscripten_exe_linker_flags "SHELL:-s TOTAL_MEMORY=${TOTAL_MEMORY}")
    endif ()
  endif ()

  # Force Modularize the output
  if (ENABLE_MODULARIZE)
    LIST(APPEND emscripten_exe_linker_flags "SHELL:-s MODULARIZE=1")
  endif()

  if (ENABLE_LZ4)
    LIST(APPEND emscripten_exe_linker_flags "SHELL:-s LZ4=1")
  endif()

  # Force exposition of Filesystem JS code to module object
  #set(emscripten_common_ldflags "${emscripten_common_ldflags}  -s FORCE_FILESYSTEM=1")

  # Enable embind
  if (ENABLE_EMBIND)
    LIST(APPEND emscripten_exe_linker_flags --bind)
  endif ()

  # Optionally enable JS closure compiler
  if (ENABLE_CLOSURE AND NOT ENABLE_THREADS)
    LIST(APPEND emscripten_exe_linker_flags "SHELL:--closure 1")
  endif ()

  # Set back standard behavior fo malloc (does not abort on failure)
  LIST(APPEND emscripten_exe_linker_flags "SHELL:-s ABORTING_MALLOC=0")

  # Additional linker option for LTO
  if (ENABLE_LTO)
    LIST(APPEND emscripten_exe_linker_flags "SHELL:--llvm-lto 1")
    LIST(APPEND emscripten_exe_linker_flags "SHELL:-s WASM_OBJECT_FILES=0")
  endif ()

  if (ENABLE_EXCEPTIONS)
    LIST(APPEND emscripten_exe_linker_flags "SHELL:-s DISABLE_EXCEPTION_CATCHING=0")
  else ()
    LIST(APPEND emscripten_exe_linker_flags "SHELL:-s DISABLE_EXCEPTION_CATCHING=1")
  endif ()

  # Specific thread options
  if (ENABLE_THREADS)
    LIST(APPEND emscripten_exe_linker_flags "SHELL:-s USE_PTHREADS=1")
    LIST(APPEND emscripten_exe_linker_flags "SHELL:-s PTHREAD_POOL_SIZE=${THREAD_POOL_SIZE}")
    LIST(APPEND emscripten_exe_linker_flags "SHELL:-s ALLOW_BLOCKING_ON_MAIN_THREAD=1")
  endif ()

  #if (SOURCE_MAP)
  #set(emscripten_common_ldflags "${emscripten_common_ldflags} --source-map-base ${CMAKE_CURRENT_BINARY_DIR}")
  #set(emscripten_common_ldflags "${emscripten_common_ldflags} --pre-js $ENV{EMSCRIPTEN}/src/emscripten-source-map.min.js")
  #endif()

  # setup environment variables
  LIST(APPEND emscripten_exe_linker_flags "SHELL:--pre-js ${CMAKE_CURRENT_SOURCE_DIR}/src/js/environment_variables.js")

  # LONGJMP support code
  if (NOT ENABLE_LONGJMP)
    LIST(APPEND emscripten_exe_linker_flags "SHELL:-s SUPPORT_LONGJMP=0")
  endif ()

  if (NOT ENABLE_ERRNO)
    LIST(APPEND emscripten_exe_linker_flags "SHELL:-s SUPPORT_ERRNO=0")
  endif ()

  # export Filesystem functions to JS (definitively needed in case CLOSURE compiler is used)
  LIST(APPEND emscripten_exe_linker_flags "SHELL:--post-js ${CMAKE_CURRENT_SOURCE_DIR}/src/js/export_fs.js")

  # typical exports, so that closure compiler does not change their names
  LIST(APPEND emscripten_exe_linker_flags "SHELL:-s EXTRA_EXPORTED_RUNTIME_METHODS=[\"ENV\",\"MEMFS\",\"FS_readFile\",\"FS_mkdir\",\"FS_writeFile\",\"FS_unlink\",\"FS_mount\",\"FS_rmdir\",\"FS_createPath\",\"FS_syncfs\"]")

  # Main browser thread linker options
  # Environment is 'web', unless with Threads enabled for which 'worker' is additionally needed
  if (ENABLE_THREADS AND BROWSER_CONTEXT STREQUAL "MAIN_THREAD")
    LIST(APPEND emscripten_exe_linker_flags "SHELL:-s ENVIRONMENT=web,worker")
  else ()
    if (BROWSER_CONTEXT STREQUAL "MAIN_THREAD")
      LIST(APPEND emscripten_exe_linker_flags "SHELL:-s ENVIRONMENT=web")
    else () # WORKER
      LIST(APPEND emscripten_exe_linker_flags "SHELL:-s ENVIRONMENT=worker")
    endif ()
  endif ()

  if (JS_PACKAGING_MODE STREQUAL "ESM" AND BROWSER_CONTEXT STREQUAL "WORKER")
    set(JS_PACKAGING_MODE "BUNDLE")
  endif ()

  # Bundling mode
  if (JS_PACKAGING_MODE STREQUAL "ESM")
    if (NOT BROWSER_CONTEXT STREQUAL "WORKER") # ESM does not work for workers
      # Export as ES6 module
      list(APPEND emscripten_exe_linker_flags "SHELL:-s EXPORT_ES6=1")
      # But nevertheless disable usage of import.meta, as Samsung Internet and Edge browser are not supporting this feature
      list(APPEND emscripten_exe_linker_flags "SHELL:-s USE_ES6_IMPORT_META=0")
    endif ()
  endif ()

  # GL Tweaking to reduce JS support code
  #set(emscripten_main_ldflags "${emscripten_main_ldflags} -s GL_POOL_TEMP_BUFFERS=0")
  #set(emscripten_main_ldflags "${emscripten_main_ldflags} -s GL_TRACK_ERRORS=0")

  target_link_options(${target} PRIVATE
          ${emscripten_exe_linker_flags}
          $<$<CONFIG:DEBUG>:${emscripten_exe_linker_flags_DEBUG}>
          $<$<CONFIG:RELEASE>:${emscripten_exe_linker_flags_RELEASE}>
          $<$<CONFIG:MINSIZEREL>:${emscripten_exe_linker_flags_MINSIZEREL}>
          $<$<CONFIG:RELWITHDEBINFO>:${emscripten_exe_linker_flags_RELWITHDEBINFO}>
          )

endfunction(configure_emscripten_target)

