%{
#include <string>
#include <iostream>

using namespace std;

int yylex();
int yyerror(string);
extern int yacc_error;
%}
%defines "y.tab.h"

/* ---------------- TOKEN DECLARATIONS ---------------- */
%token t_punkt
%token t_const
%token t_eq
%token t_komma
%token t_semik
%token t_var
%token t_proc
%token t_assign
%token t_call
%token t_begin
%token t_end
%token t_read
%token t_write
%token t_if
%token t_then
%token t_while
%token t_do
%token t_odd
%token t_ne
%token t_lt
%token t_le
%token t_gt
%token t_ge
%token t_plus
%token t_minus
%token t_mult
%token t_div
%token t_bra_o
%token t_bra_c
%token t_ident
%token t_number
%token t_error

/* ----------------------------------------------------- */

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
expression      :       term termlist
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
                    |   t_minus factor
                    |   t_plus factor
;


%%

/* Nothing more needed — parsing logic is in pl-0.cpp */
