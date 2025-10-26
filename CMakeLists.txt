cmake_minimum_required(VERSION 3.16)
project(Conpilerbau-Testate LANGUAGES C)

# Use C17
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Find Flex
find_package(FLEX REQUIRED)

# Your scanner source
set(SCANNER_FILE "${CMAKE_SOURCE_DIR}/scanner/pl0-scanner.l")

# Generate lex.yy.c from your .l file
FLEX_TARGET(Scanner ${SCANNER_FILE} ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.c)

# Add executable (test.c + generated scanner)
add_executable(pl0_scanner
    "scanner/test.c"
    ${FLEX_Scanner_OUTPUTS}
)

# Add include path so that test.c can include "lex.yy.c"
target_include_directories(pl0_scanner PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
