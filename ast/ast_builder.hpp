#pragma once

#include <stdexcept>
#include <string>
#include <ostream>

#include "../ast/ast.h"
#include "../symboltable/symboltabelle.hpp"
#include "../tree/tree.hpp"

using syntaxTree = tree<std::string>;

// Keep the same bitmask style you use in the parser
enum { st_const = 1 << 0, st_var = 1 << 1, st_proc = 1 << 2 };

struct SymEntry {
    int kind = 0;         // st_const / st_var / st_proc (bitmask)
    int value = 0;        // only meaningful for st_const
    int offset = 0;       // only meaningful for st_var  (sto)
    int proc_nr = -1;     // only meaningful for st_proc (procedure id)
};

inline std::ostream& operator<<(std::ostream& os, const SymEntry& e) {
    os << "{";

    // print kind nicely
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

    // payload
    os << ", value=" << e.value
       << ", offset=" << e.offset
       << ", proc_nr=" << e.proc_nr
       << "}";

    return os;
}

using PL0Symtab = symtab<SymEntry>;

class PT2AST {
public:
    explicit PT2AST(int debug = 0) : st(debug), debug(debug) {}

    ast convert_syntax_tree(syntaxTree* root) {
        if (!root) throw std::runtime_error("convert_syntax_tree: root is null");
        if (L(root) != "program")
            throw std::runtime_error("convert_syntax_tree: expected root label 'program'");

        if (root->size() < 1 || !C(root, 0) || L(C(root, 0)) != "block")
            throw std::runtime_error("convert_syntax_tree: program has no block child");

        // First convert main block declarations to know n_var
        int main_n_var = convert_block_decls(C(root, 0));

        // Now create AST with main procedure
        ast A;
        A.push_proc("main", main_n_var);

        // Always terminate the procedure, otherwise ast::print() / interpret() can crash
        A.append(new ast_element_end());

        // Later: convert statements, procedures, etc.
        return A;
    }

private:
    PL0Symtab st;
    int debug;

    // ---------- helpers using your tree API ----------
    static inline std::string& L(syntaxTree* n) { return n->get(); }
    static inline syntaxTree*  C(syntaxTree* n, int i) { return n->childs(i); }

    syntaxTree* find_child(syntaxTree* n, const std::string& want) {
        if (!n) return nullptr;
        for (int i = 0; i < n->size(); ++i) {
            auto* ch = C(n, i);
            if (ch && L(ch) == want) return ch;
        }
        return nullptr;
    }

    static int to_int(syntaxTree* n) { return std::stoi(L(n)); }
    static std::string to_ident(syntaxTree* n) { return L(n); }

    // ---------- conversion of decls (no statements yet) ----------
    int convert_block_decls(syntaxTree* block) {
        if (!block || L(block) != "block")
            throw std::runtime_error("convert_block_decls: expected node 'block'");

        st.level_up();

        if (auto* cd = find_child(block, "constdecl"))
            convert_constdecl(cd);

        int n_var = 0;
        if (auto* vd = find_child(block, "vardecl"))
            n_var = convert_vardecl(vd);

        if (debug) {
            std::cerr << "[convert] block decls done, n_var=" << n_var
                      << ", level=" << st.actual_level() << "\n";
            st.print();
        }

        st.level_down();
        return n_var;
    }

    void insert_const(const std::string& name, int value) {
        SymEntry e;
        e.kind = st_const;
        e.value = value;
        st.insert(name, e); // ignoring redecl here as requested
    }

    void insert_var(const std::string& name, int offset) {
        SymEntry e;
        e.kind = st_var;
        e.offset = offset;
        st.insert(name, e);
    }

    // placeholder for later when you handle proclist:
    void insert_proc(const std::string& name, int proc_nr) {
        SymEntry e;
        e.kind = st_proc;
        e.proc_nr = proc_nr;
        st.insert(name, e);
    }

    void convert_constdecl(syntaxTree* cd) {
        if (!cd || L(cd) != "constdecl") return;

        auto handle_const = [&](syntaxTree* cnode) {
            // "const" -> [ident, number]
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
                    handle_const(C(ch, j)); // each is "const"
                }
            }
        }
    }

    int convert_vardecl(syntaxTree* vd) {
        if (!vd || L(vd) != "vardecl") return 0;

        int next_offset = 0;

        auto handle_var = [&](syntaxTree* vnode) {
            // "var" -> [ident]
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
                    handle_var(C(ch, j)); // each is "var"
                }
            }
        }

        return next_offset; // n_var
    }
};
