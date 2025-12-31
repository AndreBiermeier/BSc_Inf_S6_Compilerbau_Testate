#include <stdio.h>
#include "tree.hpp"
#include "string"

typedef tree<string> syntaxTree;
syntaxTree * f_factor(void);
syntaxTree * f_expression(void);
syntaxTree * f_term(void);

struct {syntaxTree * tree ;} yylval;
enum {t_end = 0, t_plus, t_minus, t_mal, t_div,
	t_kla_auf, t_kla_zu, t_zahl, t_fehler};
#include "lex.yy.c"

int token, error;

int main(void) {
	syntaxTree * root;
	error = 0, token = yylex();
	root = f_expression();
	error = (!error) ? 0 : (token != t_end ? 3 : 0);
	if (!error)
		root->tikz();
	return 0;
}

syntaxTree * f_expression(void) {
	syntaxTree * tree = new syntaxTree("E", f_term());
	while(token == t_plus) {
		tree->append(yylval.tree);
		token = yylex();
		tree->append(f_term());
	}
	return tree;
}

syntaxTree * f_term(void) {
	syntaxTree * tree = new syntaxTree("T", f_factor());
	while(token == t_mal) {
		tree->append(yylval.tree);
		token = yylex();
		tree->append(f_factor());
	}
	return tree;
}

syntaxTree * f_factor (void) {
	syntaxTree * tree = new syntaxTree("F");
	if (token == t_minus)
		tree->append(yylval.tree),
		token = yylex(),
		tree->append(f_factor());
	else if (token == t_zahl)
		tree->append(yylval.tree), token = yylex();
	else if (token == t_kla_auf) {
		tree->append(yylval.tree), token = yylex();
		tree->append(f_expression());
		if (token != t_kla_zu)
			error = 1;
		else
			tree->append(yylval.tree), token = yylex();
	}
	else error=2;
	return tree;
}





