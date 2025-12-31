%{
#include "tree.hpp"
#include <string>
#include <iostream>
using namespace std;
typedef tree<string> syntaxTree;

int yylex();
int yyerror(string);
extern int yacc_error;

bool first_factor_of_expression = true;
%}
%defines "y.tab.h"

%union {syntaxTree * treel;}
%token<tree> t_punkt t_const t_eq t_komma t_semik t_var t_proc t_assign t_call t_begin t_end t_read t_write t_if t_then t_while t_do t_odd t_ne t_lt t_le t_gt t_ge t_plus t_minus t_mult t_div t_bra_o t_bra_c t_ident t_number t_error
%type<tree> program block constdecl constlist vardecl varlist proclist statement statementlist condition compare expression termlist term factorlist factor
%{
	syntaxTree * root;
%}

%left t_plus t_minus
%left t_mult t_div

%%

program         :       block t_punkt						{root = $1}
;
block           :       constdecl vardecl proclist statement			{$$ = new syntaxTree("block")}
;
constdecl       :       /* epsilon */						{$$ = new syntaxTree("epsilon")}
                    |   t_const t_ident t_eq t_number constlist t_semik		{$$ = new syntaxTree("constdecl", node($2, $4)}
;
constlist       :       /* epsilon */
                    |   constlist t_komma t_ident t_eq t_number
;
vardecl         :       /* epsilon */
                    |   t_var t_ident varlist t_semik
;
varlist         :       /* epsilon */
                    |   varlist t_komma t_ident
;
proclist        :       /* epsilon */
                    |   proclist t_proc t_ident t_semik block t_semik
;
statement       :       /* epsilon */
                    |   t_ident t_assign expression
                    |   t_call t_ident
                    |   t_read t_ident
                    |   t_write expression
                    |   t_begin statement statementlist t_end
                    |   t_if condition t_then statement
                    |   t_while condition t_do statement
;
statementlist   :       /* epsilon */
                    |   statementlist t_semik statement
;
condition       :       t_odd expression
                    |   expression compare expression
;
compare         :       t_eq
                    |   t_ne
                    |   t_lt
                    |   t_le
                    |   t_gt
                    |   t_ge
;
expression      :       /* new expression */            {first_factor_of_expression = true;}
                        term termlist
;
termlist        :       /* epsilon */
                    |   termlist t_plus term
                    |   termlist t_minus term
;
term            :       factor factorlist
;
factorlist      :       /* epsilon */
                    |   factorlist t_mult factor
                    |   factorlist t_div factor
;
factor          :       t_ident                         {first_factor_of_expression = false;}
                    |   t_number                        {first_factor_of_expression = false;}
                    |   t_bra_o expression t_bra_c      {first_factor_of_expression = false;}
                    |   t_minus                         {if (!first_factor_of_expression) {yyerror("-- or +- not allowed. Use brackets!"); YYABORT;} first_factor_of_expression = false;}
                        factor
                    |   t_plus                          {if (!first_factor_of_expression) {yyerror("-+ or ++ not allowed. Use brackets!"); YYABORT;} first_factor_of_expression = false;}
                        factor
;

%%
