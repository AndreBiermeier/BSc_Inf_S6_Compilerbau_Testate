%{
#define DEBUG false

#include "../tree/tree.hpp"
#include "../symboltable/symboltabelle.hpp"
#include <string>
#include <iostream>

typedef tree<string> syntaxTree;
typedef symtab<int> pl0_symtab;
using namespace std;


int yylex();
void yyerror(const std::string &s);
enum{st_const = 1 << 0, st_var = 1 << 1, st_proc = 1 << 2};

// Globals
syntaxTree * root;
pl0_symtab st (DEBUG);
bool semantic_error = false;

// Helper functions
void insert_sym(string s, int type){
    if (st.insert(s, type)){
        yyerror(string("invalid redeclaration of symbol " + s));
        semantic_error = true;
    }
    st.print();
}

string get_type_str(int type){
    switch(type) {
        case st_const: return "constant"; break;
        case st_var:   return "variable"; break;
        case st_proc:  return "procedure"; break;
        default:       return "constant or variable"; break;
    }
}

void check_sym(string s, int type){
    int typ = 0;
    int delta = 0;
    string type_str = get_type_str(type);
    if (st.lookup(s, typ, delta)){
        yyerror(type_str + " '" + s + "' is undefined!");
        semantic_error = true;
    }
    else if (!(typ & type)){
        string typ_str = get_type_str(typ);
        yyerror("expected a " + type_str + " but '" + s + "' is a " + typ_str);
        semantic_error = true;
    }
    if (DEBUG)
        cout << "Checked Symbol: " << s << " ! Expected type: " << type << " ST type: " << typ << endl;
}

void reset_parser_state() {
    semantic_error = false;
    st = pl0_symtab(DEBUG);
}
%}

%defines "y.tab.h" // Tells Bison to generate the header file with the tokens for the scanner.

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

%type <tree_node> program block constdecl constlist vardecl varlist proclist statement
%type <tree_node> statementlist condition compare expression term termlist factor factorlist

%left t_plus t_minus
%left t_mult t_div

%%

program         : {reset_parser_state();} block t_punkt						{$$ = new syntaxTree("program"); $$->append($2); root = $$; if(semantic_error) YYERROR; if(DEBUG) root->ascii();}
;
block           : {st.level_up();} constdecl vardecl proclist statement		{$$ = new syntaxTree("block"); $$->append($2); $$->append($3); $$->append($4); $$->append($5);st.level_down();}
;
constdecl       :       /* epsilon */						                {$$ = nullptr;}
                    |   t_const t_ident t_eq t_number constlist t_semik		{$$ = new syntaxTree("constdecl"); auto first = new syntaxTree("const"); first->append(new syntaxTree($2)); first->append(new syntaxTree($4)); insert_sym($2, st_const); $$->append(first); if ($5) $$->append($5);}
;
constlist       :       /* epsilon */                                       {$$ = nullptr;}
                    |   constlist t_komma t_ident t_eq t_number             {auto c = new syntaxTree("const"); c->append(new syntaxTree($3)); c->append(new syntaxTree($5)); insert_sym($3, st_const); if ($1) {$1->append(c); $$ = $1;} else {$$ = new syntaxTree("constlist"); $$->append(c);}}
;
vardecl         :       /* epsilon */                                       {$$ = nullptr;}
                    |   t_var t_ident varlist t_semik                       {$$ = new syntaxTree("vardecl"); auto first = new syntaxTree("var"); first->append(new syntaxTree($2)); insert_sym($2, st_var); $$->append(first); if ($3) $$->append($3);}
;
varlist         :       /* epsilon */                                       {$$ = nullptr;}
                    |   varlist t_komma t_ident                             {auto v = new syntaxTree("var"); v->append(new syntaxTree($3)); insert_sym($3, st_var); if ($1) {$1->append(v); $$ = $1;} else {$$ = new syntaxTree("varlist"); $$->append(v);}}
;
proclist        :       /* epsilon */                                       {$$ = nullptr;}
                    |   proclist t_proc t_ident t_semik
                        {insert_sym($3, st_proc);} block t_semik            {auto p = new syntaxTree("proc"); p->append(new syntaxTree($3)); p->append($6); if ($1) {$1->append(p); $$ = $1;} else {$$ = new syntaxTree("proclist"); $$->append(p);}}
;
statement       :       /* epsilon */                                       {$$ = nullptr;}
                    |   t_ident t_assign expression                         {$$ = new syntaxTree("statement"); auto a = new syntaxTree("assign"); a->append(new syntaxTree($1)); check_sym($1, st_var); a->append($3); $$->append(a);}
                    |   t_call t_ident                                      {$$ = new syntaxTree("statement"); auto c = new syntaxTree("call"); c->append(new syntaxTree($2)); check_sym($2, st_proc); $$->append(c);}
                    |   t_read t_ident                                      {$$ = new syntaxTree("statement"); auto r = new syntaxTree("read"); r->append(new syntaxTree($2)); check_sym($2, st_var); $$->append(r);}
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
factor          :       t_ident                                             {$$ = new syntaxTree("factor"); auto i = new syntaxTree("ident"); i->append(new syntaxTree($1)); check_sym($1, st_var | st_const); $$->append(i);}
                    |   t_number                                            {$$ = new syntaxTree("factor"); auto n = new syntaxTree("number"); n->append(new syntaxTree($1)); $$->append(n);}
                    |   t_bra_o expression t_bra_c                          {$$ = new syntaxTree("factor"); $$->append($2);}
                    |   t_minus factor                                      {$$ = new syntaxTree("factor"); auto m = new syntaxTree("-"); m->append($2); $$->append(m);}
                    |   t_plus factor                                       {$$ = new syntaxTree("factor"); auto p = new syntaxTree("+"); p->append($2); $$->append(p);}
;

%%
