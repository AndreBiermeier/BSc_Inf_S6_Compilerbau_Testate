BISON = bison
FLEX  = flex
CXX   = g++
CXXFLAGS = -std=c++17 -O2

PARSER_Y   = pl0.y
SCANNER_L  = pl0-scanner.l
MAIN_CPP   = pl0-studi.cpp
AST_BUILDER_CPP = ast_builder.cpp

PARSER_C = y.tab.c
PARSER_H = y.tab.h
SCANNER_C = lex.yy.c

BIN = pl0_parser

all: $(BIN)

# Generate parser
$(PARSER_C) $(PARSER_H): $(PARSER_Y)
	$(BISON) -d -o $(PARSER_C) $(PARSER_Y)

# Generate scanner
$(SCANNER_C): $(SCANNER_L) $(PARSER_H)
	$(FLEX) -o $(SCANNER_C) $(SCANNER_L)

# Build executable
$(BIN): $(PARSER_C) $(SCANNER_C) $(MAIN_CPP) $(AST_BUILDER_CPP)
	$(CXX) $(CXXFLAGS) $(MAIN_CPP) $(AST_BUILDER_CPP) -o $(BIN)

# Clean
clean:
	rm -f $(BIN) $(PARSER_C) $(PARSER_H) $(SCANNER_C)

.PHONY: all clean
