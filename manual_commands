# These are the commands to compile the parser manually
### Generate parser -> pl0.tab.c + y.tab.h
bison -d -o pl0.tab.c parser/pl0.y

### Generate scanner -> pl0.yy.c
flex -o pl0.yy.c scanner/pl0-scanner.l

### Compile generated files -> pl0.tab.o and pl0.yy.o
g++ -std=c++17 -Wall -Iscanner -c pl0.tab.c -o pl0.tab.o
g++ -std=c++17 -Wall -Iscanner -c pl0.yy.c -o pl0.yy.o

### Compile main stub -> main.o
g++ -std=c++17 -Wall -c parser/pl-0.cpp -o main.o

### Link the compiled files -> pl0_parser
g++ -Wall main.o pl0.tab.o pl0.yy.o -o pl0_parser