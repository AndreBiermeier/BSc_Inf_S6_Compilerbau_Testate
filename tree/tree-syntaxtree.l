%{
#define f(t) yylval.tree = new syntaxTree(yytext); return t;
%}
%%
"+"         f(t_plus)
"-"         f(t_minus)
"*"         f(t_mal)
"/"         f(t_div)
"("         f(t_kla_auf)
")"         f(t_kla_zu)
[0-9]+      f(t_zahl)
[ \t\n\f\r]+     /* do nothing */;
.           f(t_fehler)
%%
int yywrap() {
	return 1;
}

