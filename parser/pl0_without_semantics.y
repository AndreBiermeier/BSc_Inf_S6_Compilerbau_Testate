%{
#include <string>
#include <iostream>

int yylex();
int yyerror(const std::string &s);
extern int yacc_error;

%}
%defines "y.tab.h"

%token t_punkt t_const t_eq t_komma t_semik t_var t_proc t_assign t_call t_begin t_end t_read t_write t_if t_then t_while t_do t_odd t_ne t_lt t_le t_gt t_ge t_plus t_minus t_mult t_div t_bra_o t_bra_c t_ident t_number t_error

%left t_plus t_minus
%left t_mult t_div

%%

program         :       block t_punkt
;
block           :       constdecl vardecl proclist statement
;
constdecl       :       /* epsilon */
                    |   t_const t_ident t_eq t_number constlist t_semik
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
expression      :       /* new expression */
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
factor          :       t_ident
                    |   t_number
                    |   t_bra_o expression t_bra_c
                    |   t_minus
                        factor
                    |   t_plus
                        factor
;

%%
