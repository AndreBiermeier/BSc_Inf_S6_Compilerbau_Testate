# Directories
BUILD_DIR := cmake-build-debug
SCANNER_DIR := scanner
PARSER_DIR := parser
PARSER_EXEC := $(BUILD_DIR)/pl0_parser

# -----------------------
# Scanner (optional standalone)
# -----------------------
.PHONY: build_scanner
build_scanner:
	@mkdir -p $(BUILD_DIR)
	@echo "Building scanner..."
	@cd $(BUILD_DIR) && cmake ..
	@if [ -f "$(BUILD_DIR)/build.ninja" ]; then \
		cd $(BUILD_DIR) && ninja -j$(shell nproc); \
	elif [ -f "$(BUILD_DIR)/Makefile" ]; then \
		cd $(BUILD_DIR) && make -j$(shell nproc); \
	else \
		echo "Error: No build files found after CMake configuration"; \
		exit 1; \
	fi
	@echo "Scanner build complete"

# -----------------------
# Parser + scanner build
# -----------------------
.PHONY: build_parser
build_parser:
	@mkdir -p $(BUILD_DIR)
	@echo "Running Bison..."
	bison -d -o $(PARSER_DIR)/y.tab.c $(PARSER_DIR)/pl0.y
	@echo "Running Flex..."
	flex -o $(PARSER_DIR)/lex.yy.c $(SCANNER_DIR)/pl0-scanner.l
	@echo "Compiling parser + scanner + main..."
	# compile from parser/ so includes work
	cd $(PARSER_DIR) && g++ -std=c++17 -o ../$(PARSER_EXEC) pl-0.cpp
	@echo "Parser built successfully: $(PARSER_EXEC)"

# -----------------------
# Run parser tests
# -----------------------
.PHONY: run_parser_tests
run_parser_tests: build_parser
	@echo "Running parser tests..."
	cd parser && ../cmake-build-debug/pl0_parser tests

# -----------------------
# Clean
# -----------------------
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR)/pl0_parser
	@rm -f $(BUILD_DIR)/*.txt
	@rm -f $(PARSER_DIR)/y.tab.c $(PARSER_DIR)/y.tab.h $(PARSER_DIR)/lex.yy.c
	@echo "Clean complete"

# -----------------------
# Help
# -----------------------
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make build_scanner      - Build the scanner using CMake"
	@echo "  make build_parser       - Build parser + scanner using pl-0.cpp"
	@echo "  make run_parser_tests   - Run parser tests"
	@echo "  make clean              - Remove build artifacts"
	@echo "  make help               - Show this help"
