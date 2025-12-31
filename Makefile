# -----------------------
# Directories
# -----------------------
BUILD_DIR := cmake-build-debug
SCANNER_DIR := scanner
PARSER_DIR := parser
SEMANTIC_DIR := semantic
TREE_DIR := tree

PARSER_EXEC := $(BUILD_DIR)/pl0_parser
SCANNER_EXEC := $(BUILD_DIR)/pl0_scanner

# -----------------------
# Build scanner
# -----------------------
.PHONY: build_scanner
build_scanner:
	@mkdir -p $(BUILD_DIR)
	@echo "Running Flex for scanner..."
	flex -o $(SCANNER_DIR)/lex.yy.c $(SCANNER_DIR)/pl0-scanner.l
	@echo "Compiling scanner..."
	g++ -std=c++17 -I$(SCANNER_DIR) -I$(PARSER_DIR) \
	    -o $(SCANNER_EXEC) \
	    $(SCANNER_DIR)/test.c $(SCANNER_DIR)/lex.yy.c
	@echo "Scanner built successfully: $(SCANNER_EXEC)"

# -----------------------
# Build parser + semantic analysis
# -----------------------
.PHONY: build_parser
build_parser:
	@mkdir -p $(BUILD_DIR)
	@echo "Generating parser headers (Bison)..."
	cd $(PARSER_DIR) && bison -d -o y.tab.c pl0.y
	@echo "y.tab.h ready in parser directory"
	@echo "Running Flex for parser..."
	flex -o $(PARSER_DIR)/lex.yy.c $(SCANNER_DIR)/pl0-scanner.l
	@echo "Compiling parser + semantic analysis..."
	cd $(PARSER_DIR) && g++ -std=c++17 -DPARSER_BUILD \
	    -I. -I../$(SCANNER_DIR) -I../$(SEMANTIC_DIR) -I../$(TREE_DIR) \
	    -o ../$(PARSER_EXEC) pl-0.cpp ../$(SEMANTIC_DIR)/symbol_table.cpp
	@echo "Parser built successfully: $(PARSER_EXEC)"

# -----------------------
# Run parser tests
# -----------------------
.PHONY: run_parser_tests
run_parser_tests: build_parser
	@echo "Running parser tests..."
	cd $(PARSER_DIR) && ../$(PARSER_EXEC) tests

# -----------------------
# Run semantic tests
# -----------------------
.PHONY: run_semantic_tests
run_semantic_tests: build_parser
	@echo "Running semantic analysis tests..."
	cd $(SEMANTIC_DIR) && ../$(PARSER_EXEC) tests

# -----------------------
# Run scanner tests
# -----------------------
.PHONY: run_scanner_tests
run_scanner_tests: build_scanner
	@echo "Running scanner tests..."
	cd $(SCANNER_DIR) && ./run_scanner_tests.sh

# -----------------------
# Run scanner on examples
# -----------------------
.PHONY: run_scanner_examples
run_scanner_examples: build_scanner
	@echo "Running scanner on example files..."
	cd $(SCANNER_DIR) && ./run_scanner_on_examples.sh
	@echo "Scanner examples completed"

# -----------------------
# Run parser on a single file (syntax only)
# -----------------------
.PHONY: parse
parse: build_parser
	@if [ -n "$(file)" ]; then \
		echo "Running parser on $(file)..."; \
		./$(PARSER_EXEC) $(file); \
	else \
		echo "Error: please provide a file with file=filename"; \
	fi

# -----------------------
# Run semantic analysis on a single file
# -----------------------
.PHONY: semantic
semantic: build_parser
	@if [ -n "$(file)" ]; then \
		echo "Running semantic analysis on $(file)..."; \
		./$(PARSER_EXEC) $(file); \
	else \
		echo "Error: please provide a file with file=filename"; \
	fi

# -----------------------
# Clean
# -----------------------
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)/pl0_parser $(BUILD_DIR)/pl0_scanner
	@rm -f $(PARSER_DIR)/y.tab.c $(PARSER_DIR)/y.tab.h $(PARSER_DIR)/lex.yy.c
	@rm -f $(SCANNER_DIR)/lex.yy.c
	@echo "Clean complete"

# -----------------------
# Help
# -----------------------
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make build_scanner        - Build scanner executable"
	@echo "  make build_parser         - Build parser + semantic executable"
	@echo "  make run_parser_tests     - Run parser (syntax) tests"
	@echo "  make run_semantic_tests   - Run semantic analysis tests"
	@echo "  make run_scanner_tests    - Run scanner test suite"
	@echo "  make run_scanner_examples - Run scanner on example files"
	@echo "  make parse file=FILE      - Run syntax parser on a single file"
	@echo "  make semantic file=FILE   - Run semantic analysis on a single file"
	@echo "  make clean                - Remove build artifacts"
	@echo "  make help                 - Show this help"
