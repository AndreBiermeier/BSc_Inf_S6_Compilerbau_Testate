#include <stdio.h>
enum yytokentype {
	t_punkt = 1,
	t_const,
	t_eq,
	t_komma,
	t_semik,
	t_var,
	t_proc,
	t_assign,
	t_call,
	t_begin,
	t_end,
	t_read,
	t_write,
	t_if,
	t_then,
	t_while,
	t_do,
	t_odd,
	t_ne,
	t_lt,
	t_le,
	t_gt,
	t_ge,
	t_plus,
	t_minus,
	t_mult,
	t_div,
	t_bra_o,
	t_bra_c,
	t_ident,
	t_number,
	t_error
};

#include "lex.yy.c"
//#include "musterloesung.yy.c"
extern char * yytext;

int yylex();

FILE * out;
char * fn;
void test(char * pl0) {
	int token, nr = 0, n = 0;
	char fntmp[256];
	extern FILE * yyin;

	sprintf(fntmp, "%s.pl0", pl0);
	printf("Input file: %s\n", fntmp);
	yyin = fopen(fntmp, "r");
	if (!yyin) {
		printf("ERROR: Cannot open input file\n");
		return;
	}

	// Output to current directory instead of source directory
	char *base = strrchr(pl0, '/');
	if (base) base++; else base = pl0;

	sprintf(fntmp, "%s.txt", base);  // Just filename, no path
	printf("Output file: %s\n", fntmp);
	out = fopen(fntmp, "w");
	if (!out) {
		printf("ERROR: Cannot open output file\n");
		fclose(yyin);
		return;
	}

	int token_count = 0;
	while ((token = yylex()) > 0) {
		token_count++;
		if (token_count > 1) fprintf(out, "\n");
		fprintf(out, "%d %s", token, yytext);
	}

	printf("Scan complete. Wrote %d tokens to %s\n", token_count, fntmp);
	fclose(yyin);
	fclose(out);
}

int main(int argc, char * argv[]) {
	if (argc > 1) {
		printf("Processing file: %s\n", argv[1]);
		test(argv[1]);
	} else {
		printf("Using default file: test1\n");
		test("test1");
	}
	return 0;
}
