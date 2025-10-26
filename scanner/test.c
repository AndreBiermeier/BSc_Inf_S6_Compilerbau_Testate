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
	printf("%s\n", fntmp);
	yyin = fopen(fntmp, "r");
	YY_FLUSH_BUFFER;
	sprintf(fntmp, "%s.txt", pl0);
	printf("%s\n", fntmp);
	out = fopen(fntmp, "w");
	while ((token = yylex()) > 0) {
		printf("%d %s\n", token, yytext);
		fprintf(out, "%d %s\n", token, yytext);
	}
	fclose(yyin), fclose(out);
}

int main(int argc, char * argv[]) {
	fn = argv[1];
	printf("Argument: %s", fn);
	int n = 0;
	test("test1");
	/*test("test2");
	test("test3");
	test("test4");
	test("test5");
	test("test6");
	test("test7");
	test("test8");*/
	return 0;
	
}
