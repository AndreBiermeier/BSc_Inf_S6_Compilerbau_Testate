# Generate parser
bison -d -o y.tab.c pl0.y

# Generate scanner
flex -o lex.yy.c pl0-scanner.l

# Generate main
g++ -std=c++17 pl-0.cpp -o pl0_parser