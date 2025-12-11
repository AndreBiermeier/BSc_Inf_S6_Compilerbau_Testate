# Makefile for PL0 Scanner - Wrapper for CMake build
# Located in project root directory

# Directories (match your CMake setup)
BUILD_DIR := cmake-build-debug
SCANNER_DIR := scanner

# Default target
.PHONY: all
all: build_scanner

# Build the scanner using CMake - detects whether to use make or ninja
.PHONY: build_scanner
build_scanner:
	@echo "Building scanner..."
	@mkdir -p $(BUILD_DIR)
	@echo "Running CMake configuration..."
	@cd $(BUILD_DIR) && cmake ..
	@if [ -f "$(BUILD_DIR)/build.ninja" ]; then \
		echo "Using Ninja build system..."; \
		cd $(BUILD_DIR) && ninja -j$(shell nproc); \
	elif [ -f "$(BUILD_DIR)/Makefile" ]; then \
		echo "Using Make build system..."; \
		cd $(BUILD_DIR) && make -j$(shell nproc); \
	else \
		echo "Error: No build files found after CMake configuration"; \
		exit 1; \
	fi
	@echo "Scanner built successfully in $(BUILD_DIR)/"

# Run the scanner on a specific test file OR default file
.PHONY: scan
scan: build_scanner
	@if [ -n "$(file)" ]; then \
		echo "Running scanner on $(file)..."; \
		cp "$(file)" "$(BUILD_DIR)/test1.pl0"; \
	else \
		echo "Running scanner on default test file..."; \
		cp "$(SCANNER_DIR)/test1.pl0" "$(BUILD_DIR)/test1.pl0"; \
	fi
	@cd $(BUILD_DIR) && ./pl0_scanner
	@echo "Output written to $(BUILD_DIR)/test1.txt"
	@echo "Copying output file to project root..."
	@cp "$(BUILD_DIR)/test1.txt" "./test1.txt"
	@echo "Output also available in project root as test1.txt"

# Run scanner tests using the test script
.PHONY: test_scanner
test_scanner: build_scanner
	@echo "Running scanner tests..."
	@cd $(SCANNER_DIR) && ./run_scanner_tests.sh
	@echo "Scanner tests completed"

# Run scanner on examples using the example script
.PHONY: test_examples
test_examples: build_scanner
	@echo "Running scanner on examples..."
	@cd $(SCANNER_DIR) && ./run_scanner_on_examples.sh
	@echo "Scanner examples completed"

# Clean build files (keeps CMake cache) and remove output from root
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@if [ -f "$(BUILD_DIR)/build.ninja" ]; then \
		cd $(BUILD_DIR) && ninja clean; \
	elif [ -f "$(BUILD_DIR)/Makefile" ]; then \
		cd $(BUILD_DIR) && make clean; \
	else \
		echo "No build files found to clean"; \
	fi
	@echo "Removing output files from project root..."
	@rm -f test1.txt
	@echo "Clean complete"

# Deep clean - remove entire build directory and root output files
.PHONY: distclean
distclean:
	@echo "Deep cleaning - removing entire build directory..."
	@rm -rf $(BUILD_DIR)
	@echo "Removing output files from project root..."
	@rm -f test1.txt
	@echo "Distclean complete"

# Just run CMake configuration without building
.PHONY: configure
configure:
	@echo "Running CMake configuration..."
	@mkdir -p $(BUILD_DIR)
	@cd $(BUILD_DIR) && cmake ..
	@echo "Configuration complete"

# Help target
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make build_scanner      - Build the scanner using CMake"
	@echo "  make scan               - Run scanner on default test file"
	@echo "  make scan file=path     - Run scanner on specific file"
	@echo "  make test_scanner       - Run scanner test suite"
	@echo "  make test_examples      - Run scanner on examples"
	@echo "  make clean              - Clean build artifacts"
	@echo "  make distclean          - Remove entire build directory"
	@echo "  make configure          - Just run CMake configuration"
	@echo "  make help               - Show this help"
	
# -----------------------
# Parser build (with given pl-0.cpp)
# -----------------------

PARSER_DIR := parser
PARSER_Y   := $(PARSER_DIR)/pl0.y
PARSER_CPP := $(PARSER_DIR)/pl-0.cpp
BUILD_PARSER := $(BUILD_DIR)/parser
PARSER_EXEC := $(BUILD_DIR)/pl0_parser

.PHONY: build_parser
build_parser:
	@mkdir -p $(BUILD_PARSER)
	@echo "Running Bison..."
	bison -d -o $(BUILD_PARSER)/y.tab.c $(PARSER_Y)
	@echo "Running Flex..."
	flex -o $(BUILD_PARSER)/lex.yy.c scanner/pl0-scanner.l
	@echo "Compiling parser + scanner + main..."
	g++ -std=c++17 -o $(PARSER_EXEC) \
		$(BUILD_PARSER)/y.tab.c \
		$(BUILD_PARSER)/lex.yy.c \
		$(PARSER_CPP)

.PHONY: run_parser_tests
run_parser_tests: build_parser
	@echo "Running parser tests..."
	cd $(BUILD_DIR) && ./pl0_parser parser