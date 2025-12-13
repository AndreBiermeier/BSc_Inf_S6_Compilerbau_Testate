%{
#include <string>
#include <iostream>

using namespace std;

int yylex();
int yyerror(string);
extern int yacc_error;
bool enable_trace = 0;
#define TRACE(x) do { if (enable_trace) std::cout << "Using production: " << x << std::endl; } while(0)
%}
%defines "y.tab.h"

/* ---------------- TOKEN DECLARATIONS ---------------- */
%token t_punkt t_const t_eq t_komma t_semik t_var t_proc t_assign t_call t_begin t_end t_read t_write t_if t_then t_while t_do t_odd t_ne t_lt t_le t_gt t_ge t_plus t_minus t_mult t_div t_bra_o t_bra_c t_ident t_number t_error

/* ----------------------------------------------------- */

%%

program         :       block t_punkt {TRACE("program -> block '.'");}
;
block           :       constdecl vardecl proclist statement {TRACE("block -> constdecl proclist statement");}
;
constdecl       :       /* epsilon */ {TRACE("constdecl -> eps");}
                    |   t_const t_ident t_eq t_number constlist t_semik {TRACE("constdecl -> const ident eq number constlist semik");}
;
constlist       :       /* epsilon */ {TRACE("constlist -> eps");}
                    |   constlist t_komma t_ident t_eq t_number {TRACE("constlist -> constlist komma ident eq number");}
;
vardecl         :       /* epsilon */ {TRACE("vardecl -> eps");}
                    |   t_var t_ident varlist t_semik {TRACE("vardecl -> var ident varlist semik");}
;
varlist         :       /* epsilon */ {TRACE("varlist -> eps");}
                    |   varlist t_komma t_ident {TRACE("varlist -> varlist komma ident");}
;
proclist        :       /* epsilon */ {TRACE("proclist -> eps");}
                    |   proclist t_proc t_ident t_semik block t_semik {TRACE("proclist -> proclist proc ident semik block semik");}
;
statement       :       /* epsilon */ {TRACE("statement -> eps");}
                    |   t_ident t_assign expression {TRACE("statement -> ident assign expression");}
                    |   t_call t_ident {TRACE("statement -> call ident");}
                    |   t_read t_ident {TRACE("statement -> read ident");}
                    |   t_write expression {TRACE("statement -> write expression");}
                    |   t_begin statement statementlist t_end {TRACE("statement -> begin statement statementlist end");}
                    |   t_if condition t_then statement {TRACE("statement -> if condition then statement");}
                    |   t_while condition t_do statement {TRACE("statement -> while condition do statement");}
;
statementlist   :       /* epsilon */ {TRACE("statementlist -> eps");}
                    |   statementlist t_semik statement {TRACE("statementlist -> statementlist semik statement");}
;
condition       :       t_odd expression {TRACE("condition -> odd");}
                    |   expression compare expression {TRACE("condition -> expression compare expression");}
;
compare         :       t_eq {TRACE("compare -> eq");}
                    |   t_ne {TRACE("compare -> ne");}
                    |   t_lt {TRACE("compare -> lt");}
                    |   t_le {TRACE("compare -> le");}
                    |   t_gt {TRACE("compare -> gt");}
                    |   t_ge {TRACE("compare -> ge");}
;
expression      :       term termlist {TRACE("expression -> term termlist");}
;
termlist        :       /* epsilon */ {TRACE("termlist -> eps");}
                    |   termlist t_plus term {TRACE("termlist -> termlist plus term");}
                    |   termlist t_minus term {TRACE("termlist -> termlist minus term");}
;
term            :       factor factorlist {TRACE("term -> factor factorlist");}
;
factorlist      :       /* epsilon */ {TRACE("factorlist -> eps");}
                    |   factorlist t_mult factor {TRACE("factorlist -> factorlist mult factor");}
                    |   factorlist t_div factor {TRACE("factorlist -> factorlist div factor");}
;
factor          :       t_ident {TRACE("factor -> ident");}
                    |   t_number {TRACE("factor -> number");}
                    |   t_bra_o expression t_bra_c {TRACE("factor -> bra expression ket");}
                    |   t_minus factor {TRACE("factor -> minus factor");}
                    |   t_plus factor {TRACE("factor -> plus factor");}
;


%%

/* Nothing more needed — parsing logic is in pl-0.cpp */
