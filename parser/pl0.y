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

/* If you want location:
%locations
*/

/* ----------------------------------------------------- */

%%

/* The smallest possible grammar */

program:
      t_punkt                 { /* OK: empty program "." */ }
    | block t_punkt           { /* block followed by "." */ }
    ;

block:
      t_begin t_end
    ;

%%

/* Nothing more needed — parsing logic is in pl-0.cpp */
