#include "ast-2-aassembler.hpp"
#include "ast.h"

#include <fstream>
#include <iostream>
#include <string>
#include <unordered_set>

using namespace std;

static ofstream myfile;                                                                                                 // Where .asm is written to
static string label = "";

// ============================================================================
// Emitters
// ============================================================================

static void emit(const string& lab, const string& cmd,
                 const string& arg, const string& comment)
{
    myfile << lab << "\t" << cmd;
    if (!arg.empty()) myfile << "\t" << arg;
    if (!comment.empty()) myfile << "\t# " << comment;
    myfile << "\n";
}

static void emit(const string& lab, const string& cmd,
                 long long arg, const string& comment)
{
    emit(lab, cmd, to_string(arg), comment);
}

static void emit(const string& cmd, long long arg, const string& comment)
{
    emit(label, cmd, to_string(arg), comment);
    label.clear();
}

static void emit(const string& cmd, const string& arg, const string& comment)
{
    emit(label, cmd, arg, comment);
    label.clear();
}

static void emit(const string& cmd) {
    emit(label, cmd, "", "");
    label.clear();
}

static void set_label(const string& lab) { label = lab; }

static string L(ast_element* p) {
    return "L_" + to_string((unsigned long long)p);
}

static string FKT(int nr) {
    return "FKT_" + to_string(nr);
}

// Helper to push variable address onto the stack
static void adr_var(int stl, int sto, const string& name) {
    emit("loadr", 0, "adr " + name + " (" + to_string(stl) + "/" + to_string(sto) + ")");
    for (int i = 0; i < stl; i++)
        emit("loads", "", "follow SL");
    emit("dec", (long long)(sto + 2), "p - 2 - offset");
}

// ============================================================================
// Expression code generation
// ============================================================================
static void gen_expr(ast_optree* e);

static void gen_expr(ast_optree* e)
{
    switch (e->type) {
        case op_int: {
            auto* k = (ast_optree_int*)e;
            emit("loadc", (long long)k->val, "const");
        } break;

        case op_var: {
            auto* v = (ast_optree_var*)e;
            adr_var(v->stl, v->sto, v->name);
            emit("loads");                                                                                      // load value at address
        } break;

        case op_chs:
            gen_expr(e->l);
            emit("chs");
            break;

        case op_plus:
            gen_expr(e->l); gen_expr(e->r); emit("add"); break;
        case op_minus:
            gen_expr(e->l); gen_expr(e->r); emit("sub"); break;
        case op_mult:
            gen_expr(e->l); gen_expr(e->r); emit("mult"); break;
        case op_div:
            gen_expr(e->l); gen_expr(e->r); emit("div"); break;
        case op_mod:
            gen_expr(e->l); gen_expr(e->r); emit("mod"); break;
        case op_eq:
            gen_expr(e->l); gen_expr(e->r); emit("cmpeq"); break;
        case op_ne:
            gen_expr(e->l); gen_expr(e->r); emit("cmpne"); break;
        case op_lt:
            gen_expr(e->l); gen_expr(e->r); emit("cmplt"); break;
        case op_le:
            gen_expr(e->l); gen_expr(e->r); emit("cmple"); break;
        case op_gt:
            gen_expr(e->l); gen_expr(e->r); emit("cmpgt"); break;
        case op_ge:
            gen_expr(e->l); gen_expr(e->r); emit("cmpge"); break;
        case op_odd:
            gen_expr(e->l);
            emit("loadc", 2, "odd: mod 2");
            emit("mod");
            emit("loadc", 0, "!= 0");
            emit("cmpne");
            break;
        default:
            cerr << "gen_expr: unknown optree type " << e->type << "\n";
            break;
    }
}

// ============================================================================
// Collects the jump targets of a procedure
// ============================================================================
static unordered_set<ast_element*> collect_targets(ast_proc& p)
{
    unordered_set<ast_element*> t;
    for (ast_element* it = p.get_start(); it; it = it->get_next()) {
        if (it->get_type() == stmt_jump || it->get_type() == stmt_jmpz) {
            if (it->get_jump()) t.insert(it->get_jump());
        }
        if (it->get_type() == stmt_end) break;
    }
    return t;
}

// ============================================================================
// Statement code generation
// ============================================================================
static void gen_stmt(ast_element* it, const unordered_set<ast_element*>& targets)
{
    if (targets.find(it) != targets.end())                                                                              // Give it a label if theres a jump to the AST node
        set_label(L(it));

    switch (it->get_type()) {
        case stmt_nop:
            emit("nop");
            break;

        case stmt_read: {
            auto* r = (ast_element_read*)it;
            emit("read");
            adr_var(r->stl, r->sto, r->name);
            emit("stores", "", "store input");
        } break;

        case stmt_write: {
            auto* w = (ast_element_write*)it;
            gen_expr(w->get_expr());
            emit("write");
        } break;

        case stmt_assign: {
            auto* a = (ast_element_assign*)it;
            gen_expr(a->get_expr());                                                                                 // push RHS value
            adr_var(a->stl, a->sto, a->name);                                                                           // push LHS address
            emit("stores", "", "assign");
        } break;

        case stmt_jump:
            emit("jump", L(it->get_jump()), "goto");
            break;

        case stmt_jmpz: {
            auto* jz = (ast_element_jmpz*)it;
            gen_expr(jz->get_expr());          // push condition
            emit("jumpz", L(it->get_jump()), "if 0 -> jump");
        } break;

        case stmt_call: {
            auto* c = (ast_element_call*)it;

            // push new SL for callee: start at current frame, walk SL c->stl times
            emit("loadr", 0, "new SL for " + c->name);
            for (int i = 0; i < c->stl; i++)
                emit("loads");

            emit("call", FKT(c->nr), "call " + c->name);
        } break;

        case stmt_debug:
            emit("nop", "", "debug ignored");
            break;

        default:
            cerr << "gen_stmt: unknown stmt type " << it->get_type() << "\n";
            break;
    }
}

// ============================================================================
// RAM Helpers
// ============================================================================
static void emit_ram_helpers()
{
    emit("RAM_UP", "loadr", 0, "");
    emit("add", "", "");
    emit("inc", 2, "Neuer TOS");
    emit("dup", "", "");
    emit("dec", 1, "");
    emit("loadr", 0, "");
    emit("swap", "", "");
    emit("stores", "", "DL");
    emit("dup", "", "");
    emit("storer", 0, "Neuer TOS gesetzt");
    emit("stores", "", "SL gesetzt");
    emit("return", "", "");

    emit("RAM_DOWN", "loadr", 0, "RAM-Abbau");
    emit("dec", 1, "");
    emit("loads", "", "");
    emit("storer", 0, "");
    emit("return", "", "");
}

// ============================================================================
// Main
// ============================================================================
int ast_2_aassembler(ast& AST, string filename)
{
    filename += ".asm";
    cerr << "Created " << filename << "\n";
    myfile.open(filename);
    if (!myfile.is_open()) {
        cerr << "error opening " << filename << " for writing\n";
        return -1;
    }

    // Initialization
    emit("loadc", 0, "RAM-INIT");
    emit("storer", 0, "TOS setzen");
    emit("loadc", 0, "Pseudo-SL fuer main");
    emit("jump", FKT(0), "==> Startfunktion");

    // RAM Helpers
    emit_ram_helpers();

    // Emit for all procedures
    for (int nr = 0; nr < (int)AST.v.size(); nr++) {
        ast_proc& p = AST.v[nr];

        set_label(FKT(nr));
        emit("loadc", (long long)p.get_n_var(), "nvar");                                             // Number of local variables
        emit("call", "RAM_UP", "stackframe anlegen");                                         // Procedure's stackframe

        auto targets = collect_targets(p);                                                   // Get all jump targets of the procedure's statements

        for (ast_element* it = p.get_start(); it; it = it->get_next()) {
            if (it->get_type() == stmt_end) break;
            gen_stmt(it, targets);
        }

        emit("call", "RAM_DOWN", "stackframe loeschen");
        emit("return", "", "");
    }

    myfile.close();
    return 0;
}
