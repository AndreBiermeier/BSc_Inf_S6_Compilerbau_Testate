# -----------------------
# Directories
# -----------------------
BUILD_DIR := cmake-build-debug
PARSER_DIR := parser
SCANNER_DIR := scanner
SEMANTIC_DIR := semantic
TREE_DIR := tree

# -----------------------
# Compiler / Tools
# -----------------------
CXX := g++
LEX := flex
YACC := bison
CXXFLAGS := -std=c++17 -Wall -O2 -I$(PARSER_DIR) -I$(SCANNER_DIR) -I$(SEMANTIC_DIR) -I$(TREE_DIR)

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

# Objects
PARSER_OBJ := $(BUILD_DIR)/main.o $(BUILD_DIR)/pl0.tab.o $(BUILD_DIR)/pl0.yy.o
PARSER_EXEC := $(BUILD_DIR)/pl0_parser

TEST_PARSER_OBJ := $(BUILD_DIR)/main_test.o $(BUILD_DIR)/pl0_no_sem.tab.o $(BUILD_DIR)/pl0.yy.o
TEST_PARSER_EXEC := $(BUILD_DIR)/pl0_test_parser

SCANNER_OBJ := $(BUILD_DIR)/scanner.o
SCANNER_EXEC := $(BUILD_DIR)/pl0_scanner

SEMANTIC_TEST_MAIN := $(PARSER_DIR)/pl-0.cpp
SEMANTIC_TEST_OBJ  := $(BUILD_DIR)/main_sem.o $(BUILD_DIR)/pl0.tab.o $(BUILD_DIR)/pl0.yy.o
SEMANTIC_TEST_EXEC := $(BUILD_DIR)/pl0_semantic_test

# -----------------------
# Create build directory
# -----------------------
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# -----------------------
# Compile main parser file
# -----------------------
$(BUILD_DIR)/main.o: $(MAIN_CPP) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(MAIN_CPP) -o $(BUILD_DIR)/main.o

# Compile test main parser file (pl-0.cpp)
$(BUILD_DIR)/main_test.o: $(TEST_MAIN_CPP) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(TEST_MAIN_CPP) -o $(BUILD_DIR)/main_test.o

# Compile semantic test main
$(BUILD_DIR)/main_sem.o: $(SEMANTIC_TEST_MAIN) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(SEMANTIC_TEST_MAIN) -o $(BUILD_DIR)/main_sem.o

# -----------------------
# Generate and compile Bison parser
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
# -----------------------
$(LEX_C): $(LEX_SRC) $(YACC_H) | $(BUILD_DIR)
	$(LEX) -o $(LEX_C) $(LEX_SRC)

$(BUILD_DIR)/pl0.yy.o: $(LEX_C) $(YACC_H) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(LEX_C) -o $(BUILD_DIR)/pl0.yy.o

# -----------------------
# Build scanner executable
# -----------------------
$(SCANNER_OBJ): $(SCANNER_DIR)/test.cpp | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $(SCANNER_DIR)/test.cpp -o $(SCANNER_OBJ)

$(SCANNER_EXEC): $(SCANNER_OBJ) $(BUILD_DIR)/pl0.yy.o | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(SCANNER_OBJ) $(BUILD_DIR)/pl0.yy.o -o $(SCANNER_EXEC)

# -----------------------
# Link parser executable
# -----------------------
$(PARSER_EXEC): $(PARSER_OBJ) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(PARSER_OBJ) -o $(PARSER_EXEC)

# Link test parser executable (wo semantic checks)
$(TEST_PARSER_EXEC): $(TEST_PARSER_OBJ) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(TEST_PARSER_OBJ) -o $(TEST_PARSER_EXEC)

# Link semantic test executable
$(SEMANTIC_TEST_EXEC): $(SEMANTIC_TEST_OBJ) | $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) $(SEMANTIC_TEST_OBJ) -o $(SEMANTIC_TEST_EXEC)

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
	@./$(SEMANTIC_TEST_EXEC) semantic/tests/normal semantic/tests/syntaxfehler

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
	@echo "  make run_parser_tests 			   - Run parser tests with semantic checks"
	@echo "  make run_scanner_tests            - Run scanner test suite"
	@echo "  make run_scanner_examples         - Run scanner on all examples and count errors"
	@echo "  make clean                        - Remove all build artifacts"
	@echo "  make help                         - Show this help"
	@echo ""
	@echo "To use a different main file for testing, call:"
	@echo "  make MAIN_CPP=parser/my_pl-0.cpp build run file=FILE"
