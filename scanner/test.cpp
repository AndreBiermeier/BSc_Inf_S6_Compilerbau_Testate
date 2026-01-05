#include <stdio.h>
#include "pl0tokens.h"
#include "../tree/tree.hpp"


extern int yylex();
extern char *yytext;
extern FILE *yyin;

FILE *out;

void test(const char *pl0) {
	char fntmp[256];
	sprintf(fntmp, "%s.pl0", pl0);
	yyin = fopen(fntmp, "r");
	if (!yyin) { printf("Cannot open %s\n", fntmp); return; }

	sprintf(fntmp, "%s.txt", pl0);
	out = fopen(fntmp, "w");
	if (!out) { printf("Cannot write to %s\n", fntmp); fclose(yyin); return; }

	int token;
	while ((token = yylex()) > 0) {
		fprintf(out, "%d %s\n", token, yytext);
	}

	fclose(yyin);
	fclose(out);
}

int main(int argc, char **argv) {
	if (argc > 1) test(argv[1]);
	else test("test1");
	return 0;
}
