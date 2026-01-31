#include <stdio.h>
#include <string>
using namespace std;

#include "ast.cpp"
#include "ram.cpp"
ast AST; // You may set reference variable in Your parser!

int yylex();
#include "y.tab.c"
#include "lex.yy.c"

/*
 * The program feeds stdin to yyparse().
 * Usage: "./pl0_scanner < program.pl0"
 */

int main(int argc, char * argv[]) {
	int n = yyparse();
	if (n == 0) {
		AST.print();
		AST.interpret();
	}
	return n;
}
