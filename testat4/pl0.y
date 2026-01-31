%{
#define DEBUG_GRAMMAR false
#define DEBUG_SYMTAB false
#define DEBUG_AST false
#define PRINT_TIKZ false
#define PRINT_AST false

#define MAKE_AST true

#include "./tree.hpp"
#include "./symboltabelle.hpp"
#include <string>
#include <iostream>
#include "./ast.h"

typedef tree<string> syntaxTree;
typedef symtab<int> pl0_symtab;
using namespace std;





// ============================================================================
// ============================================================================
// ============================================================================
// ast_builder.hpp copied to this file
// ============================================================================
#include <vector>

using syntaxTree = tree<std::string>;

// Same as in the parser (from lecture)
enum { st_const = 1 << 0, st_var = 1 << 1, st_proc = 1 << 2 };

struct SymEntry {
    int kind = 0;         // st_const / st_var / st_proc
    int value = 0;        // for st_const
    int offset = 0;       // for st_var  (sto)
    int proc_nr = -1;     // for st_proc (procedure id)
};

std::ostream& operator<<(std::ostream& os, const SymEntry& e);

using PL0Symtab = symtab<SymEntry>;

class PT2AST {
public:
    explicit PT2AST(int debug = 0);
    ast convert_syntax_tree(syntaxTree* root);

private:
    PL0Symtab st;
    int debug;
    int next_proc_nr = 0;                                                                                               // procedure numbering for the entire program

    // ---------- Helpers ----------
    static inline const std::string& L(syntaxTree* n) { return n->get(); }
    static inline syntaxTree* C(syntaxTree* n, int i) { return n->childs(i); }

    syntaxTree* find_child(syntaxTree* n, const std::string& want);

    static int to_int(syntaxTree* n);
    static std::string to_ident(syntaxTree* n);

    // ---------- Pre-Pass to determine number of variables ----------
    int peek_block_n_var(syntaxTree* block);

    // ---------- Declaration Conversions ----------
    void insert_const(const std::string& name, int value);
    void insert_var(const std::string& name, int offset);
    void insert_proc(const std::string& name, int proc_nr);

    void convert_constdecl(syntaxTree* cd);
    int  convert_vardecl(syntaxTree* vd);

    // ---------- Statements / Expressions ----------
    void convert_stmt_node(syntaxTree* node, ast& A);
    void convert_statement(syntaxTree* stmt, ast& A);

    ast_optree* convert_expression(syntaxTree* expr);
    ast_optree* convert_term(syntaxTree* term);
    ast_optree* convert_factor(syntaxTree* factor);

    ast_optree* convert_condition(syntaxTree* cond);
    ast_optree* convert_compare_op(syntaxTree* compareNode, ast_optree* lhs, ast_optree* rhs);

    // ---------- Procedures ----------
    struct ProcInfo {
        std::string name;
        syntaxTree* block = nullptr;
        int proc_nr = -1;
    };

    void convert_block(syntaxTree* block, ast& A);
    std::vector<ProcInfo> predeclare_procs(syntaxTree* proclist);
    void convert_proc_bodies(const std::vector<ProcInfo>& procs, ast& A);
};



// ============================================================================
// ast_builder.cpp copied to this file
// ============================================================================
#include <stdexcept>

std::ostream& operator<<(std::ostream& os, const SymEntry& e) {
    os << "{";

    bool first = true;
    auto add = [&](const char* s) {
        if (!first) os << "|";
        os << s;
        first = false;
    };

    if (e.kind & st_const) add("const");
    if (e.kind & st_var)   add("var");
    if (e.kind & st_proc)  add("proc");
    if (first) os << "<?>";

    os << ", value=" << e.value
       << ", offset=" << e.offset
       << ", proc_nr=" << e.proc_nr
       << "}";

    return os;
}

PT2AST::PT2AST(int debug_) : st(debug_), debug(debug_) {}

// ============================================================================
// Main
// ============================================================================

ast PT2AST::convert_syntax_tree(syntaxTree* root) {
    if (!root) throw std::runtime_error("convert_syntax_tree: root is null");
    if (L(root) != "program")
        throw std::runtime_error("convert_syntax_tree: expected root label 'program'");

    syntaxTree* block = C(root, 0);
    if (!block || L(block) != "block")
        throw std::runtime_error("convert_syntax_tree: program has no block child");

    // main is always proc 0
    ast A;
    int main_n_var = peek_block_n_var(block);
    A.push_proc("main", main_n_var);

    next_proc_nr = 1;          // 0 reserved for main
    convert_block(block, A);   // appends main body + end + nested procs

    return A;
}

// ============================================================================
// Helpers
// ============================================================================

syntaxTree* PT2AST::find_child(syntaxTree* n, const std::string& want) {
    if (!n) return nullptr;
    for (int i = 0; i < n->size(); ++i) {
        auto* ch = C(n, i);
        if (ch && L(ch) == want) return ch;
    }
    return nullptr;
}

int PT2AST::to_int(syntaxTree* n) {
    return std::stoi(L(n));
}

std::string PT2AST::to_ident(syntaxTree* n) {
    return L(n);
}

// ============================================================================
// Pre-Pass: count variables for procedure
// ============================================================================

int PT2AST::peek_block_n_var(syntaxTree* block) {
    if (!block || L(block) != "block")
        throw std::runtime_error("peek_block_n_var: expected 'block'");

    syntaxTree* vd = find_child(block, "vardecl");
    if (!vd || L(vd) != "vardecl") return 0;

    int count = 0;
    for (int i = 0; i < vd->size(); ++i) {
        syntaxTree* ch = C(vd, i);
        if (!ch) continue;

        if (L(ch) == "var") {
            count += 1;
        } else if (L(ch) == "varlist") {
            count += ch->size();
        }
    }
    return count;
}

// ============================================================================
// Symbol table inserts (no checks as this is done during parsing)
// ============================================================================

void PT2AST::insert_const(const std::string& name, int value) {
    SymEntry e;
    e.kind = st_const;
    e.value = value;
    st.insert(name, e);
}

void PT2AST::insert_var(const std::string& name, int offset) {
    SymEntry e;
    e.kind = st_var;
    e.offset = offset;
    st.insert(name, e);
}

void PT2AST::insert_proc(const std::string& name, int proc_nr) {
    SymEntry e;
    e.kind = st_proc;
    e.proc_nr = proc_nr;
    st.insert(name, e);
}

// ============================================================================
// Declaration conversion
// ============================================================================

void PT2AST::convert_constdecl(syntaxTree* cd) {
    if (!cd || L(cd) != "constdecl") return;

    auto handle_const = [&](syntaxTree* cnode) {
        std::string name = to_ident(C(cnode, 0));
        int value        = to_int(C(cnode, 1));
        insert_const(name, value);
    };

    for (int i = 0; i < cd->size(); ++i) {
        auto* ch = C(cd, i);
        if (!ch) continue;

        if (L(ch) == "const") {
            handle_const(ch);
        } else if (L(ch) == "constlist") {
            for (int j = 0; j < ch->size(); ++j) {
                handle_const(C(ch, j));
            }
        }
    }
}

int PT2AST::convert_vardecl(syntaxTree* vd) {
    if (!vd || L(vd) != "vardecl") return 0;

    int next_offset = 0;

    auto handle_var = [&](syntaxTree* vnode) {
        std::string name = to_ident(C(vnode, 0));
        insert_var(name, next_offset++);
    };

    for (int i = 0; i < vd->size(); ++i) {
        auto* ch = C(vd, i);
        if (!ch) continue;

        if (L(ch) == "var") {
            handle_var(ch);
        } else if (L(ch) == "varlist") {
            for (int j = 0; j < ch->size(); ++j) {
                handle_var(C(ch, j));
            }
        }
    }

    return next_offset;
}

// ============================================================================
// Statemnt conversion
// ============================================================================

void PT2AST::convert_stmt_node(syntaxTree* node, ast& A) {
    if (!node) return;

    const std::string& tag = L(node);

    if (tag == "statement") {
        if (node->size() == 0) return;     // epsilon
        convert_stmt_node(C(node, 0), A);  // unwrap
        return;
    }

    if (tag == "statementlist") {
        for (int i = 0; i < node->size(); ++i) {
            convert_stmt_node(C(node, i), A);
        }
        return;
    }

    convert_statement(node, A);
}

void PT2AST::convert_statement(syntaxTree* stmt, ast& A) {
    if (!stmt) return;

    if (L(stmt) == "assign") {
        std::string name = to_ident(C(stmt, 0));

        SymEntry e;
        int delta = 0;
        if (st.lookup(name, e, delta) != 0)
            throw std::runtime_error("undefined identifier in assign: " + name);
        if (!(e.kind & st_var))
            throw std::runtime_error("assign target is not a var: " + name);

        ast_optree* rhs = convert_expression(C(stmt, 1));
        A.append(new ast_element_assign(name, delta, e.offset, rhs));
        return;
    }

    if (L(stmt) == "read") {
        std::string name = to_ident(C(stmt, 0));

        SymEntry e;
        int delta = 0;
        if (st.lookup(name, e, delta) != 0)
            throw std::runtime_error("undefined identifier in read: " + name);
        if (!(e.kind & st_var))
            throw std::runtime_error("read target is not a var: " + name);

        A.append(new ast_element_read(name, delta, e.offset));
        return;
    }

    if (L(stmt) == "write") {
        ast_optree* e = convert_expression(C(stmt, 0));
        A.append(new ast_element_write(e));
        return;
    }

    if (L(stmt) == "begin_end") {
        for (int i = 0; i < stmt->size(); ++i) {
            convert_stmt_node(C(stmt, i), A);
        }
        return;
    }

    if (L(stmt) == "if") {
        ast_optree* cond = convert_condition(C(stmt, 0));

        auto* jz = new ast_element_jmpz(cond, nullptr);
        A.append(jz);

        convert_stmt_node(C(stmt, 1), A);

        auto* end = new ast_element_nop();
        A.append(end);

        jz->set_jump(end);
        return;
    }

    if (L(stmt) == "while") {
        auto* start = new ast_element_nop();
        A.append(start);

        ast_optree* cond = convert_condition(C(stmt, 0));

        auto* jz = new ast_element_jmpz(cond, nullptr);
        A.append(jz);

        convert_stmt_node(C(stmt, 1), A);

        A.append(new ast_element_jump(start));

        auto* end = new ast_element_nop();
        A.append(end);

        jz->set_jump(end);
        return;
    }

    if (L(stmt) == "call") {
        std::string name = to_ident(C(stmt, 0));

        SymEntry e;
        int delta = 0;
        if (st.lookup(name, e, delta) != 0)
            throw std::runtime_error("undefined procedure in call: " + name);
        if (!(e.kind & st_proc))
            throw std::runtime_error("call target is not a procedure: " + name);

        A.append(new ast_element_call(name, delta, e.proc_nr));
        return;
    }

    throw std::runtime_error("statement not implemented yet: " + L(stmt));
}

// ============================================================================
// Expression conversion
// ============================================================================

ast_optree* PT2AST::convert_expression(syntaxTree* expr) {
    if (!expr) throw std::runtime_error("null expression");
    if (L(expr) != "expression")
        throw std::runtime_error("expected 'expression', got: " + L(expr));

    ast_optree* acc = convert_term(C(expr, 0));
    if (expr->size() < 2) return acc;

    syntaxTree* termlist = C(expr, 1);
    for (int i = 0; i < termlist->size(); ++i) {
        syntaxTree* op = C(termlist, i);      // "+" or "-"
        ast_optree* rhs = convert_term(C(op, 0));

        if (L(op) == "+") acc = new ast_optree_plus(acc, rhs);
        else if (L(op) == "-") acc = new ast_optree_minus(acc, rhs);
        else throw std::runtime_error("unknown termlist op: " + L(op));
    }
    return acc;
}

ast_optree* PT2AST::convert_term(syntaxTree* term) {
    if (!term) throw std::runtime_error("null term");
    if (L(term) != "term")
        throw std::runtime_error("expected 'term', got: " + L(term));

    ast_optree* acc = convert_factor(C(term, 0));
    if (term->size() < 2) return acc;

    syntaxTree* factorlist = C(term, 1);
    for (int i = 0; i < factorlist->size(); ++i) {
        syntaxTree* op = C(factorlist, i);    // "*" or "/"
        ast_optree* rhs = convert_factor(C(op, 0));

        if (L(op) == "*") acc = new ast_optree_mult(acc, rhs);
        else if (L(op) == "/") acc = new ast_optree_div(acc, rhs);
        else throw std::runtime_error("unknown factorlist op: " + L(op));
    }
    return acc;
}

ast_optree* PT2AST::convert_factor(syntaxTree* factor) {
    if (!factor) throw std::runtime_error("null factor");
    if (L(factor) != "factor")
        throw std::runtime_error("expected 'factor', got: " + L(factor));
    if (factor->size() == 0)
        throw std::runtime_error("factor has no child");

    syntaxTree* x = C(factor, 0);

    if (L(x) == "ident") {
        std::string name = to_ident(C(x, 0));

        SymEntry e;
        int delta = 0;
        if (st.lookup(name, e, delta) != 0)
            throw std::runtime_error("undefined identifier in expression: " + name);

        if (e.kind & st_const) return new ast_optree_int(e.value);
        if (e.kind & st_var)   return new ast_optree_var(name, delta, e.offset);

        throw std::runtime_error("identifier not const/var: " + name);
    }

    if (L(x) == "number") {
        int v = to_int(C(x, 0));
        return new ast_optree_int(v);
    }

    if (L(x) == "-") {
        return new ast_optree_chs(convert_factor(C(x, 0)));
    }

    if (L(x) == "+") {
        return convert_factor(C(x, 0));
    }

    if (L(x) == "expression") {
        return convert_expression(x);
    }

    throw std::runtime_error("unknown factor child: " + L(x));
}

// ============================================================================
// Condition conversion
// ============================================================================

ast_optree* PT2AST::convert_condition(syntaxTree* cond) {
    if (!cond) throw std::runtime_error("null condition");
    if (L(cond) != "condition")
        throw std::runtime_error("expected 'condition', got: " + L(cond));
    if (cond->size() == 0)
        throw std::runtime_error("condition has no child");

    syntaxTree* c = C(cond, 0);

    if (L(c) == "odd") {
        if (c->size() < 1) throw std::runtime_error("odd has no expression");
        ast_optree* e = convert_expression(C(c, 0));

        // odd e <=> (e % 2) != 0
        ast_optree* mod2 = new ast_optree_mod(e, new ast_optree_int(2));
        return new ast_optree_ne(mod2, new ast_optree_int(0));
    }

    if (L(c) == "compare") {
        if (c->size() != 3)
            throw std::runtime_error("compare node expected 3 children, got " + std::to_string(c->size()));

        ast_optree* lhs = convert_expression(C(c, 0));
        syntaxTree* cmp = C(c, 1); // compare -> [eq|ne|...]
        ast_optree* rhs = convert_expression(C(c, 2));

        return convert_compare_op(cmp, lhs, rhs);
    }

    throw std::runtime_error("unknown condition child: " + L(c));
}

ast_optree* PT2AST::convert_compare_op(syntaxTree* compareNode, ast_optree* lhs, ast_optree* rhs) {
    if (!compareNode) throw std::runtime_error("null compareNode");
    if (L(compareNode) != "compare")
        throw std::runtime_error("expected compare node 'compare', got: " + L(compareNode));
    if (compareNode->size() == 0)
        throw std::runtime_error("compare node has no operator child");

    std::string op = L(C(compareNode, 0));

    if (op == "eq") return new ast_optree_eq(lhs, rhs);
    if (op == "ne") return new ast_optree_ne(lhs, rhs);
    if (op == "lt") return new ast_optree_lt(lhs, rhs);
    if (op == "le") return new ast_optree_le(lhs, rhs);
    if (op == "gt") return new ast_optree_gt(lhs, rhs);
    if (op == "ge") return new ast_optree_ge(lhs, rhs);

    throw std::runtime_error("unknown compare operator: " + op);
}

// ============================================================================
// Procedures
// ============================================================================

std::vector<PT2AST::ProcInfo> PT2AST::predeclare_procs(syntaxTree* proclist) {
    std::vector<ProcInfo> out;
    if (!proclist) return out;
    if (L(proclist) != "proclist")
        throw std::runtime_error("predeclare_procs: expected 'proclist', got: " + L(proclist));

    for (int i = 0; i < proclist->size(); ++i) {
        syntaxTree* p = C(proclist, i);
        if (!p) continue;
        if (L(p) != "proc")
            throw std::runtime_error("predeclare_procs: expected child 'proc', got: " + L(p));

        std::string name = to_ident(C(p, 0));
        syntaxTree* blk  = C(p, 1);

        int nr = next_proc_nr++;
        insert_proc(name, nr);

        ProcInfo info;
        info.name = name;
        info.block = blk;
        info.proc_nr = nr;
        out.push_back(info);
    }
    return out;
}

void PT2AST::convert_proc_bodies(const std::vector<ProcInfo>& procs, ast& A) {
    for (const auto& p : procs) {
        if (!p.block || L(p.block) != "block")
            throw std::runtime_error("convert_proc_bodies: proc has no valid block: " + p.name);

        int n_var = peek_block_n_var(p.block);
        A.push_proc(p.name, n_var);

        convert_block(p.block, A);
    }
}

void PT2AST::convert_block(syntaxTree* block, ast& A) {
    if (!block || L(block) != "block")
        throw std::runtime_error("convert_block: expected 'block'");

    st.level_up();

    if (auto* cd = find_child(block, "constdecl")) convert_constdecl(cd);
    if (auto* vd = find_child(block, "vardecl"))  (void)convert_vardecl(vd);

    std::vector<ProcInfo> procs;
    if (auto* pl = find_child(block, "proclist")) {
        procs = predeclare_procs(pl);
    }

    if (auto* s = find_child(block, "statement")) {
        convert_stmt_node(s, A);
    }

    A.append(new ast_element_end());

    convert_proc_bodies(procs, A);

    if (debug) {
        std::cerr << "[convert] block done, level=" << st.actual_level() << "\n";
        st.print();
    }

    st.level_down();
}

// ============================================================================
// ============================================================================
// ============================================================================





int yylex();
void yyerror(const std::string &s) {
    std::cerr << "Error: " << s << std::endl;
}

// Globals
string g_out_base = "program";
syntaxTree * root;
pl0_symtab st (DEBUG_SYMTAB);
bool semantic_error = false;
PT2AST pt2ast (DEBUG_AST);
ast ast_root;
extern ast AST;

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
    if (DEBUG_SYMTAB)
        cout << "Checked Symbol: " << s << " ! Expected type: " << type << " ST type: " << typ << endl;
}

void reset_parser_state() {
    semantic_error = false;
    st = pl0_symtab(DEBUG_SYMTAB);
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

program         : {reset_parser_state();} block t_punkt						{$$ = new syntaxTree("program"); $$->append($2); root = $$; if(semantic_error) YYERROR; if(DEBUG_GRAMMAR) root->ascii(); if (MAKE_AST ) {ast_root = pt2ast.convert_syntax_tree(root); if (PRINT_AST) ast_root.print(); if (PRINT_TIKZ) ast_root.tikz(); AST = ast_root;}}
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
