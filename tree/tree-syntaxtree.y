%{
#include "tree.hpp"
#include <iostream>
#include <string>
using namespace std;
typedef tree<string> syntaxTree;

int yylex();
void yyerror(const char * const );
%}
%union {syntaxTree * tree;}
%token<tree> t_plus t_minus t_mal t_div t_kla_auf t_kla_zu t_fehler t_zahl
%type<tree> expr term factor
%{
	syntaxTree * root;
%}
%%
start: expr {root = $1;}
	;
expr: term	{$$ = new syntaxTree("expr", $1);}
	| expr t_plus term
		{$$ = new syntaxTree("expr", $1, $2, $3);}
	| expr t_minus term
		{$$ = new syntaxTree("expr", $1,  $2, $3);}
	;
term: factor{$$ = new syntaxTree("term", $1);}
	| term t_mal factor
		{$$ = new syntaxTree("term", $1, $2, $3);}
	| term t_div factor
		{$$ = new syntaxTree("term", $1,  $2, $3);}
	;
factor: t_zahl {$$ = new syntaxTree("factor", $1);}
	| t_kla_auf expr t_kla_zu
		{$$ = new syntaxTree("factor", $1, $2, $3);}
	| t_minus factor
		{$$ = new syntaxTree("factor", $1, $2);}
	;
%%
	
#include "lex.yy.c"

int main() {
	if (!yyparse())
		root->tikz();
	return 0;
}

void yyerror(const char * const t) {
	cout << t << endl;
}
