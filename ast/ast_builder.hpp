#pragma once

#include <string>
#include <ostream>
#include <vector>

#include "../ast/ast.h"
#include "../symboltable/symboltabelle.hpp"
#include "../tree/tree.hpp"

using syntaxTree = tree<std::string>;

// Same bitmask style as in your parser
enum { st_const = 1 << 0, st_var = 1 << 1, st_proc = 1 << 2 };

struct SymEntry {
    int kind = 0;         // st_const / st_var / st_proc (bitmask)
    int value = 0;        // only meaningful for st_const
    int offset = 0;       // only meaningful for st_var  (sto)
    int proc_nr = -1;     // only meaningful for st_proc (procedure id)
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
    int next_proc_nr = 0; // global numbering across whole program

    // ---------- helpers using your tree API ----------
    static inline const std::string& L(syntaxTree* n) { return n->get(); }
    static inline syntaxTree* C(syntaxTree* n, int i) { return n->childs(i); }

    syntaxTree* find_child(syntaxTree* n, const std::string& want);

    static int to_int(syntaxTree* n);
    static std::string to_ident(syntaxTree* n);

    // ---------- pre-pass ----------
    int peek_block_n_var(syntaxTree* block);

    // ---------- decl conversion ----------
    void insert_const(const std::string& name, int value);
    void insert_var(const std::string& name, int offset);
    void insert_proc(const std::string& name, int proc_nr);

    void convert_constdecl(syntaxTree* cd);
    int  convert_vardecl(syntaxTree* vd);

    // ---------- statements / expressions ----------
    void convert_stmt_node(syntaxTree* node, ast& A);
    void convert_statement(syntaxTree* stmt, ast& A);

    ast_optree* convert_expression(syntaxTree* expr);
    ast_optree* convert_term(syntaxTree* term);
    ast_optree* convert_factor(syntaxTree* factor);

    ast_optree* convert_condition(syntaxTree* cond);
    ast_optree* convert_compare_op(syntaxTree* compareNode, ast_optree* lhs, ast_optree* rhs);

    // ---------- procedures ----------
    struct ProcInfo {
        std::string name;
        syntaxTree* block = nullptr;
        int proc_nr = -1;
    };

    void convert_block(syntaxTree* block, ast& A);
    std::vector<ProcInfo> predeclare_procs(syntaxTree* proclist);
    void convert_proc_bodies(const std::vector<ProcInfo>& procs, ast& A);
};
