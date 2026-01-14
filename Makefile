# -----------------------
# Directories
# -----------------------
BUILD_DIR := cmake-build-debug
PARSER_DIR := parser
SCANNER_DIR := scanner
SEMANTIC_DIR := semantic
TREE_DIR := tree
AST_DIR := ast
RAM_DIR := ast

# -----------------------
# Compiler / Tools
# -----------------------
CXX := g++
LEX := flex
YACC := bison
CXXFLAGS := -std=c++17 -Wall -O2 \
	-I$(PARSER_DIR) -I$(SCANNER_DIR) -I$(SEMANTIC_DIR) -I$(TREE_DIR) -I$(AST_DIR)

# -----------------------
# Files
# -----------------------
MAIN_CPP ?= $(PARSER_DIR)/my_pl-0.cpp
TEST_MAIN_CPP := $(PARSER_DIR)/pl-0.cpp

YACC_SRC := $(PARSER_DIR)/pl0.y
YACC_C := $(BUILD_DIR)/pl0.tab.c
YACC_H := $(BUILD_DIR)/pl0.tab.h

# Parser for tests (without semantic checks)
TEST_YACC_SRC := $(PARSER_DIR)/pl0_without_semantics.y
TEST_YACC_C   := $(BUILD_DIR)/pl0_no_sem.tab.c
TEST_YACC_H   := $(BUILD_DIR)/pl0_no_sem.tab.h

LEX_SRC := $(SCANNER_DIR)/pl0-scanner.l
LEX_C := $(BUILD_DIR)/pl0.yy.c

# AST / RAM sources
AST_CPP := $(AST_DIR)/ast.cpp
RAM_CPP := $(RAM_DIR)/ram.cpp

# AST builder source
AST_BUILDER_CPP := $(AST_DIR)/ast_builder.cpp

# -----------------------
# Special: generate y.tab.h where scanner expects it
# (scanner/pl0-scanner.l includes "../parser/y.tab.h")
# -----------------------
PARSER_YTAB_C := $(PARSER_DIR)/y.tab.c
PARSER_YTAB_H := $(PARSER_DIR)/y.tab.h

# -----------------------
# Objects
# -----------------------
PARSER_OBJ := $(BUILD_DIR)/main.o $(BUILD_DIR)/pl0.tab.o $(BUILD_DIR)/pl0.yy.o
PARSER_EXEC := $(BUILD_DIR)/pl0_parser

TEST_PARSER_OBJ := $(BUILD_DIR)/main_test.o $(BUILD_DIR)/pl0_no_sem.tab.o $(BUILD_DIR)/pl0.yy.o
TEST_PARSER_EXEC := $(BUILD_DIR)/pl0_test_parser

SCANNER_OBJ := $(BUILD_DIR)/scanner.o
SCANNER_STUB_OBJ := $(BUILD_DIR)/parser_stubs.o
SCANNER_EXEC := $(BUILD_DIR)/pl0_scanner

SEMANTIC_TEST_MAIN := $(PARSER_DIR)/pl-0.cpp
SEMANTIC_TEST_OBJ  := $(BUILD_DIR)/main_sem.o $(BUILD_DIR)/pl0.tab.o $(BUILD_DIR)/pl0.yy.o
SEMANTIC_TEST_EXEC := $(BUILD_DIR)/pl0_semantic_test

AST_OBJ := $(BUILD_DIR)/ast.o
RAM_OBJ := $(BUILD_DIR)/ram.o
AST_BUILDER_OBJ := $(BUILD_DIR)/ast_builder.o

# -----------------------
# Create build directory
# -----------------------
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# -----------------------
# Compile main files
# -----------------------
$(BUILD_DIR)/main.o: $(MAIN_CPP) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(MAIN_CPP) -o $(BUILD_DIR)/main.o

# If pl-0.cpp includes y.tab.h, ensure header exists first (safe even if it doesn't)
$(BUILD_DIR)/main_test.o: $(TEST_MAIN_CPP) $(PARSER_YTAB_H) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(TEST_MAIN_CPP) -o $(BUILD_DIR)/main_test.o

# Semantic test main also includes y.tab.h => must depend on it
$(BUILD_DIR)/main_sem.o: $(SEMANTIC_TEST_MAIN) $(PARSER_YTAB_H) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(SEMANTIC_TEST_MAIN) -o $(BUILD_DIR)/main_sem.o

# -----------------------
# Compile AST / RAM / AST builder
# -----------------------
$(AST_OBJ): $(AST_CPP) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(AST_CPP) -o $(AST_OBJ)

$(RAM_OBJ): $(RAM_CPP) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(RAM_CPP) -o $(RAM_OBJ)

$(AST_BUILDER_OBJ): $(AST_BUILDER_CPP) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(AST_BUILDER_CPP) -o $(AST_BUILDER_OBJ)

# -----------------------
# Generate parser header where scanner expects it (parser/y.tab.h)
# -----------------------
$(PARSER_YTAB_C) $(PARSER_YTAB_H): $(YACC_SRC)
	cd $(PARSER_DIR) && $(YACC) -d pl0.y

# -----------------------
# Generate and compile Bison parser into build dir (cmake-build-debug/pl0.tab.*)
# -----------------------
$(YACC_C) $(YACC_H): $(YACC_SRC) | $(BUILD_DIR)
	cd $(PARSER_DIR) && $(YACC) -d -o ../$(YACC_C) pl0.y

$(BUILD_DIR)/pl0.tab.o: $(YACC_C) $(YACC_H) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(YACC_C) -o $(BUILD_DIR)/pl0.tab.o

# Generate and compile test parser (no semantics)
$(TEST_YACC_C) $(TEST_YACC_H): $(TEST_YACC_SRC) | $(BUILD_DIR)
	cd $(PARSER_DIR) && $(YACC) -d -o ../$(TEST_YACC_C) pl0_without_semantics.y

$(BUILD_DIR)/pl0_no_sem.tab.o: $(TEST_YACC_C) $(TEST_YACC_H) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(TEST_YACC_C) -o $(BUILD_DIR)/pl0_no_sem.tab.o

# -----------------------
# Generate and compile Flex scanner
# NOTE: depend on parser/y.tab.h because lexer includes "../parser/y.tab.h"
# -----------------------
$(LEX_C): $(LEX_SRC) $(PARSER_YTAB_H) | $(BUILD_DIR)
	$(LEX) -o $(LEX_C) $(LEX_SRC)

$(BUILD_DIR)/pl0.yy.o: $(LEX_C) $(PARSER_YTAB_H) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(LEX_C) -o $(BUILD_DIR)/pl0.yy.o

# -----------------------
# Build scanner executable (scanner tests)
# -----------------------
$(SCANNER_OBJ): $(SCANNER_DIR)/test.cpp $(PARSER_YTAB_H) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(SCANNER_DIR)/test.cpp -o $(SCANNER_OBJ)

$(SCANNER_STUB_OBJ): $(SCANNER_DIR)/parser_stubs.cpp | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(SCANNER_DIR)/parser_stubs.cpp -o $(SCANNER_STUB_OBJ)

$(SCANNER_EXEC): $(SCANNER_OBJ) $(BUILD_DIR)/pl0.yy.o $(SCANNER_STUB_OBJ) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(SCANNER_OBJ) $(BUILD_DIR)/pl0.yy.o $(SCANNER_STUB_OBJ) -o $(SCANNER_EXEC)

# -----------------------
# Link parser executables
# -----------------------
$(PARSER_EXEC): $(PARSER_OBJ) $(AST_OBJ) $(RAM_OBJ) $(AST_BUILDER_OBJ) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(PARSER_OBJ) $(AST_OBJ) $(RAM_OBJ) $(AST_BUILDER_OBJ) -o $(PARSER_EXEC)

$(TEST_PARSER_EXEC): $(TEST_PARSER_OBJ) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(TEST_PARSER_OBJ) -o $(TEST_PARSER_EXEC)

$(SEMANTIC_TEST_EXEC): $(SEMANTIC_TEST_OBJ) $(AST_OBJ) $(RAM_OBJ) $(AST_BUILDER_OBJ) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(SEMANTIC_TEST_OBJ) $(AST_OBJ) $(RAM_OBJ) $(AST_BUILDER_OBJ) -o $(SEMANTIC_TEST_EXEC)

# -----------------------
# Phony targets
# -----------------------
.PHONY: build build_parser build_scanner run run_scanner_tests run_scanner_examples run_parser_wo_semantic_tests run_parser_tests clean help

# -----------------------
# Build everything
# -----------------------
build: $(PARSER_EXEC) $(SCANNER_EXEC)
	@echo "Build complete!"
	@echo "Run parser with: 'make run file=FILE'"
	@echo "Run scanner tests with: 'make run_scanner_tests'"
	@echo "Run scanner examples with: 'make run_scanner_examples'"

build_parser: $(PARSER_EXEC)
	@echo "Parser built: $(PARSER_EXEC)"

build_scanner: $(SCANNER_EXEC)
	@echo "Scanner built: $(SCANNER_EXEC)"

# -----------------------
# Run parser on a file
# -----------------------
run: $(PARSER_EXEC)
	@if [ -n "$(file)" ]; then \
		./$(PARSER_EXEC) $(file); \
	else \
		echo "Error: please provide a file with 'file=filename'"; \
	fi

# -----------------------
# Run parser without semantic checks
# -----------------------
run_parser_wo_semantic_tests: clean $(TEST_PARSER_EXEC)
	@echo "Running parser without semantic checks using parser tests..."
	@./$(TEST_PARSER_EXEC) parser/tests/normal parser/tests/syntaxfehler

# -----------------------
# Run parser with semantic checks
# -----------------------
run_parser_tests: clean $(SEMANTIC_TEST_EXEC)
	@echo "Running parser with semantic checks using semantic tests..."
	@./$(SEMANTIC_TEST_EXEC) semantic/tests/normal semantic/tests/semanticfehler

# -----------------------
# Run scanner test suite
# -----------------------
run_scanner_tests: $(SCANNER_EXEC)
	@echo "Running PL/0 scanner test suite..."
	@cd $(SCANNER_DIR) && ./run_scanner_tests.sh

# -----------------------
# Run scanner examples
# -----------------------
run_scanner_examples: $(SCANNER_EXEC)
	@echo "Running PL/0 scanner on all examples..."
	@cd $(SCANNER_DIR) && ./run_scanner_examples.sh

# -----------------------
# Clean build artifacts
# -----------------------
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)/*
	@rm -f $(PARSER_YTAB_C) $(PARSER_YTAB_H)
	@echo "Clean complete."

# -----------------------
# Help
# -----------------------
help:
	@echo "Available commands:"
	@echo "  make build                        - Build parser + scanner"
	@echo "  make build_parser                 - Build parser only"
	@echo "  make build_scanner                - Build scanner only"
	@echo "  make run file=FILE                - Run parser on FILE"
	@echo "  make run_parser_wo_semantic_tests - Run parser tests without semantic checks"
	@echo "  make run_parser_tests             - Run parser tests with semantic checks"
	@echo "  make run_scanner_tests            - Run scanner test suite"
	@echo "  make run_scanner_examples         - Run scanner on all examples and count errors"
	@echo "  make clean                        - Remove all build artifacts"
	@echo "  make help                         - Show this help"
	@echo ""
	@echo "To use a different main file for testing, call:"
	@echo "  make MAIN_CPP=parser/my_pl-0.cpp build run file=FILE"
