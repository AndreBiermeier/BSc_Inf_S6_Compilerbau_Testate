%{
#include "../tree/tree.hpp"
#include <string>
#include <iostream>
using namespace std;
typedef tree<string> syntaxTree;

int yylex();
void yyerror(const std::string &s);

syntaxTree * root;
%}
%defines "y.tab.h"

%union {
    tree<string> * tree_node;
    char* txt;
}

%token t_punkt t_const t_eq t_komma t_semik t_var t_proc t_assign t_call t_begin t_end
%token t_read t_write t_if t_then t_while t_do t_odd
%token t_ne t_lt t_le t_gt t_ge
%token t_plus t_minus t_mult t_div
%token t_bra_o t_bra_c
%token <txt> t_ident
%token <txt> t_number
%token t_error

%type <tree_node> program block constdecl constlist vardecl varlist proclist statement statementlist condition compare expression term termlist factor factorlist

%left t_plus t_minus
%left t_mult t_div

%%

program         :       block t_punkt						                {$$ = new syntaxTree("program"); $$->append($1); root = $$; root->ascii();}
;
block           :       constdecl vardecl proclist statement			    {$$ = new syntaxTree("block"); $$->append($1); $$->append($2); $$->append($3); $$->append($4);}
;
constdecl       :       /* epsilon */						                {$$ = nullptr;}
                    |   t_const t_ident t_eq t_number constlist t_semik		{$$ = new syntaxTree("constdecl"); auto first = new syntaxTree("const"); first->append(new syntaxTree($2)); first->append(new syntaxTree($4)); $$->append(first); if ($5) $$->append($5);}
;
constlist       :       /* epsilon */                                       {$$ = nullptr;}
                    |   constlist t_komma t_ident t_eq t_number             {auto c = new syntaxTree("const"); c->append(new syntaxTree($3)); c->append(new syntaxTree($5)); if ($1) {$1->append(c); $$ = $1;} else {$$ = new syntaxTree("constlist"); $$->append(c);}}
;
vardecl         :       /* epsilon */                                       {$$ = nullptr;}
                    |   t_var t_ident varlist t_semik                       {$$ = new syntaxTree("vardecl"); auto first = new syntaxTree("var"); first->append(new syntaxTree($2)); $$->append(first); if ($3) $$->append($3);}
;
varlist         :       /* epsilon */                                       {$$ = nullptr;}
                    |   varlist t_komma t_ident                             {auto v = new syntaxTree("var"); v->append(new syntaxTree($3)); if ($1) {$1->append(v); $$ = $1;} else {$$ = new syntaxTree("varlist"); $$->append(v);}}
;
proclist        :       /* epsilon */                                       {$$ = nullptr;}
                    |   proclist t_proc t_ident t_semik block t_semik       {auto p = new syntaxTree("proc"); p->append(new syntaxTree("ident")); p->append(new syntaxTree("block")); if ($1) {$1->append(p); $$ = $1;} else {$$ = new syntaxTree("proclist"); $$->append(p);}}
;
statement       :       /* epsilon */                                       {$$ = nullptr;}
                    |   t_ident t_assign expression                         {$$ = new syntaxTree("statement"); auto a = new syntaxTree("assign"); a->append(new syntaxTree("ident")); a->append($3); $$->append(a);}
                    |   t_call t_ident                                      {$$ = new syntaxTree("statement"); auto c = new syntaxTree("call"); c->append(new syntaxTree("ident")); $$->append(c);}
                    |   t_read t_ident                                      {$$ = new syntaxTree("statement"); auto r = new syntaxTree("read"); r->append(new syntaxTree("ident")); $$->append(r);}
                    |   t_write expression                                  {$$ = new syntaxTree("statement"); auto w = new syntaxTree("write"); w->append($2); $$->append(w);}
                    |   t_begin statement statementlist t_end               {$$ = new syntaxTree("statement"); auto s = new syntaxTree("begin_end"); if ($2) s->append($2); if ($3) s->append($3); $$->append(s);}
                    |   t_if condition t_then statement                     {$$ = new syntaxTree("statement"); auto i = new syntaxTree("if"); i->append($2); i->append($4); $$->append(i);}
                    |   t_while condition t_do statement                    {$$ = new syntaxTree("statement"); auto l = new syntaxTree("while"); l->append($2); l->append($4); $$->append(l);}
;
statementlist   :       /* epsilon */                                       {$$ = nullptr;}
                    |   statementlist t_semik statement                     {auto s = new syntaxTree("statement"); s->append($3); if ($1) {$1->append(s); $$ = $1;} else {$$ = new syntaxTree("statementlist"); $$->append(s);}}
;
condition       :       t_odd expression                                    {$$ = new syntaxTree("condition"); auto c = new syntaxTree("odd"); c->append($2); $$->append(c);}
                    |   expression compare expression                       {$$ = new syntaxTree("condition"); auto c = new syntaxTree("compare"); c->append($1); c->append($2); c->append($3); $$->append(c);}
;
compare         :       t_eq                                                {$$ = new syntaxTree("compare"); $$->append(new syntaxTree("eq"));}
                    |   t_ne                                                {$$ = new syntaxTree("compare"); $$->append(new syntaxTree("ne"));}
                    |   t_lt                                                {$$ = new syntaxTree("compare"); $$->append(new syntaxTree("lt"));}
                    |   t_le                                                {$$ = new syntaxTree("compare"); $$->append(new syntaxTree("le"));}
                    |   t_gt                                                {$$ = new syntaxTree("compare"); $$->append(new syntaxTree("gt"));}
                    |   t_ge                                                {$$ = new syntaxTree("compare"); $$->append(new syntaxTree("ge"));}
;
expression      :       term termlist                                       {$$ = new syntaxTree("expression"); $$->append($1); if ($2) $$->append($2);}
;
termlist        :       /* epsilon */                                       {$$ = nullptr;}
                    |   termlist t_plus term                                {auto pt = new syntaxTree("+"); pt->append($3); if ($1) {$1->append(pt); $$ = $1;} else {$$ = new syntaxTree("termlist"); $$->append(pt);}}
                    |   termlist t_minus term                               {auto mt = new syntaxTree("-"); mt->append($3); if ($1) {$1->append(mt); $$ = $1;} else {$$ = new syntaxTree("termlist"); $$->append(mt);}}
;
term            :       factor factorlist                                   {$$ = new syntaxTree("term"); $$->append($1); if ($2) $$->append($2);}
;
factorlist      :       /* epsilon */                                       {$$ = nullptr;}
                    |   factorlist t_mult factor                            {auto mf = new syntaxTree("*"); mf->append($3); if ($1) {$1->append(mf); $$ = $1;} else {$$ = new syntaxTree("factorlist"); $$->append(mf);}}
                    |   factorlist t_div factor                             {auto df = new syntaxTree("/"); df->append($3); if ($1) {$1->append(df); $$ = $1;} else {$$ = new syntaxTree("factorlist"); $$->append(df);}}
;
factor          :       t_ident                                             {$$ = new syntaxTree("factor"); auto i = new syntaxTree("ident"); i->append(new syntaxTree($1)); $$->append(i);}
                    |   t_number                                            {$$ = new syntaxTree("factor"); auto n = new syntaxTree("number"); n->append(new syntaxTree($1)); $$->append(n);}
                    |   t_bra_o expression t_bra_c                          {$$ = new syntaxTree("factor"); $$->append($2);}
                    |   t_minus factor                                      {$$ = new syntaxTree("factor"); auto m = new syntaxTree("-"); m->append($2); $$->append(m);}
                    |   t_plus factor                                       {$$ = new syntaxTree("factor"); auto p = new syntaxTree("+"); p->append($2); $$->append(p);}
;

%%
