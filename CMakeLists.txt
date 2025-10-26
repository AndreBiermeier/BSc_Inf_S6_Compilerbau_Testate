cmake_minimum_required(VERSION 3.16)
project(pl0_scanner LANGUAGES C)

# Use C17
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Find Flex
find_package(FLEX REQUIRED)

# Your scanner source
set(SCANNER_FILE "${CMAKE_SOURCE_DIR}/scanner/pl0-scanner.l")

# Generate lex.yy.c from your .l file
FLEX_TARGET(Scanner ${SCANNER_FILE} ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.c)

# Add custom target to ensure lex.yy.c is generated
add_custom_target(generate_scanner ALL
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.c
)

# Add executable (ONLY test.c - since it includes lex.yy.c)
add_executable(pl0_scanner "scanner/test.c")

# Add include path so that test.c can include "lex.yy.c"
target_include_directories(pl0_scanner PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

# Add dependency to generate lex.yy.c before building
add_dependencies(pl0_scanner generate_scanner)

# Copy test1.pl0 to build directory automatically
configure_file(${CMAKE_SOURCE_DIR}/scanner/test1.pl0 ${CMAKE_CURRENT_BINARY_DIR}/test1.pl0 COPYONLY)

# Set the working directory for CLion's run configuration
set_target_properties(pl0_scanner PROPERTIES
        VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        XCODE_ATTRIBUTE_CONFIGURATION_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}"
)

# Post-build event to ensure test1.pl0 exists (fallback)
add_custom_command(TARGET pl0_scanner POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_SOURCE_DIR}/scanner/test1.pl0
        ${CMAKE_CURRENT_BINARY_DIR}/test1.pl0
        COMMENT "Ensuring test1.pl0 is available in build directory"
)