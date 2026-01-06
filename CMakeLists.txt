cmake_minimum_required(VERSION 3.20)
project(pl0-clion LANGUAGES CXX)

# --- Grab all your cpp and hpp files recursively ---
file(GLOB_RECURSE ALL_SOURCES
        CONFIGURE_DEPENDS
        ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/*.hpp
)

# --- Dummy executable just to give CLion context ---
add_executable(dummy_target ${ALL_SOURCES})

# --- Do not actually care about compilation ---
set_target_properties(dummy_target PROPERTIES
        EXCLUDE_FROM_ALL TRUE
        EXCLUDE_FROM_DEFAULT_BUILD TRUE
)
