# Copyright (c) 2019 Gabriel Cuvillier, Continuation Labs (www.continuation-labs.com)
# Licensed under CC0 1.0 Universal

##############################################
# Template CMake file for emscripten projects
##############################################
project(your_emscripten_project)

# Minimum version supported to be able to do "set(CMAKE_CXX_STANDARD 17)"
cmake_minimum_required(VERSION 3.13.5)

include(emscripten.cmake)

# Use C++ 17 standard for the whole project
set(CMAKE_CXX_STANDARD 17)
# Enable all warnings
add_compile_options(-Wall)

add_executable(test src/main.cpp)

set(ENABLE_EXCEPTIONS OFF)
set(ENABLE_RTTI ON)
set(ALLOW_MEMORY_GROWTH ON)
set(ENABLE_THREADS OFF)
set(ENABLE_MODULARIZE ON)
set(BROWSER_CONTEXT "MAIN_THREAD")
set(JS_PACKAGING_MODE "BUNDLE")
configure_emscripten_target(test)
