# -----------------------
# Compiler / Tools
# -----------------------
CXX = g++
LEX = flex
YACC = bison
CXXFLAGS = -std=c++17 -Wall -O2

# -----------------------
# Files
# -----------------------
PROJECT = project
MAIN = project.cpp
YACC_SRC = project.y
LEX_SRC = project.l
YACC_C = project.tab.c
YACC_H = project.tab.h
LEX_C = project.yy.c
OBJ = project.o project.tab.o project.yy.o

# -----------------------
# Default build
# -----------------------
.PHONY: build
build: $(PROJECT)
	@echo "Build complete! You can now run './$(PROJECT) test.pl0'"

# -----------------------
# Linking project
# -----------------------
$(PROJECT): $(OBJ)
	$(CXX) $(CXXFLAGS) -o $(PROJECT) $(OBJ)

# -----------------------
# Compile main
# -----------------------
project.o: $(MAIN)
	$(CXX) $(CXXFLAGS) -c $(MAIN)

# -----------------------
# Generate and compile Bison parser
# -----------------------
$(YACC_C) $(YACC_H): $(YACC_SRC)
	$(YACC) -d -o $(YACC_C) $(YACC_SRC)

project.tab.o: $(YACC_C)
	$(CXX) $(CXXFLAGS) -c $(YACC_C)

# -----------------------
# Generate and compile Flex scanner
# -----------------------
$(LEX_C): $(LEX_SRC) $(YACC_H)
	$(LEX) -o $(LEX_C) $(LEX_SRC)

project.yy.o: $(LEX_C)
	$(CXX) $(CXXFLAGS) -c $(LEX_C)

# -----------------------
# Run parser on a file
# -----------------------
.PHONY: run
run: build
	@if [ -n "$(file)" ]; then \
		./$(PROJECT) $(file); \
	else \
		echo "Error: please provide a file with 'file=filename'"; \
	fi

# -----------------------
# Clean build artifacts
# -----------------------
.PHONY: clean
clean:
	rm -f $(OBJ) $(PROJECT) $(YACC_C) $(YACC_H) $(LEX_C)
	@echo "Clean complete."

# -----------------------
# Help
# -----------------------
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make build          - Build the project"
	@echo "  make run file=FILE  - Run parser on FILE"
	@echo "  make clean          - Remove all build artifacts"
	@echo "  make help           - Show this help"
