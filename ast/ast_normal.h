#pragma once

#include <string>
#include <vector>
#include <iostream>
#include "ram.h"

using namespace std;

// Statement kinds
const int
    stmt_end   = 1,
    stmt_assign= 2,
    stmt_call  = 3,
    stmt_read  = 4,
    stmt_write = 5,
    stmt_nop   = 6,
    stmt_jump  = 7,
    stmt_jmpz  = 8,
    stmt_debug = 9;

// Operator kinds
enum {
    op_eq = 1,
    op_ne,
    op_gt,
    op_ge,
    op_lt,
    op_le,
    op_plus,
    op_minus,
    op_mult,
    op_div,
    op_mod,
    op_chs,
    op_int,
    op_var,
    op_odd
};

class ast_optree;
class ast_element;
class ast_proc;
class ast;

// ---------------- AST ----------------
class ast {
public:
    void push_proc(ast_proc);
    void push_proc(string, int);     // (name, n_var)
    ast_element* append(ast_element*);
    void tikz(string = "");
    void print();
    void interpret();

    vector<ast_proc> v;

protected:
    void interpret(int, c_RAM&, int);
    int  interpret(c_RAM&, ast_optree*);
};

// ---------------- Procedure ----------------
class ast_proc {
public:
    ast_proc(string, int);           // (name, n_var)
    ast_element* append(ast_element*);

    friend class ast;

    string get_name();
    int get_n_var();
    ast_element* get_start();
    ast_element* get_end();

    void tikz(int);

    // properties
    string name;
    int n_var;
    ast_element* start;
    ast_element* end;
};

// ---------------- Statement element ----------------
class ast_element {
public:
    ast_element(int);

    friend class ast;
    friend class ast_proc;

    void tikz(int, int, string);
    virtual void tikz(int, int) = 0;

    int get_type();
    string get_text();

    void set_jump(ast_element*);
    ast_element* get_jump();
    ast_element* get_next();

protected:
    ast_element* next;
    ast_element* jump;
    int type;
};

// ---------------- Expression tree ----------------
class ast_optree {
public:
    virtual void print() = 0;
    ast_optree(int type, ast_optree* = nullptr, ast_optree* = nullptr);

    int type;
    ast_optree* l;
    ast_optree* r;
};

// ----- statement nodes -----
class ast_element_write : public ast_element {
public:
    ast_element_write(ast_optree*);
    virtual ast_optree* get_expr() { return expr; }

protected:
    virtual void tikz(int, int);
    ast_optree* expr;
};

class ast_element_assign : public ast_element {
public:
    ast_element_assign(string, int, int, ast_optree*);
    virtual ast_optree* get_expr() { return expr; }

    int stl;
    int sto;
    ast_optree* expr;
    string name;

protected:
    virtual void tikz(int, int);
};

class ast_element_read : public ast_element {
public:
    ast_element_read(string, int, int); // (name, stl, sto)
    virtual void tikz(int, int);

    string name;
    int stl;
    int sto;
};

class ast_element_call : public ast_element {
public:
    ast_element_call(string, int, int); // (name, stl, nr)
    virtual void tikz(int, int);

    string name;
    int stl;
    int nr;
};

class ast_element_debug : public ast_element {
public:
    ast_element_debug();
    virtual void tikz(int, int);
};

class ast_element_nop : public ast_element {
public:
    ast_element_nop();
    virtual void tikz(int, int);
};

class ast_element_end : public ast_element {
public:
    ast_element_end();
    virtual void tikz(int, int);
};

class ast_element_jmpz : public ast_element {
public:
    ast_element_jmpz(ast_optree*, ast_element* = nullptr);
    virtual void tikz(int, int);
    virtual ast_optree* get_expr() { return expr; }

protected:
    ast_optree* expr;
};

class ast_element_jump : public ast_element {
public:
    ast_element_jump(ast_element*);
    virtual void tikz(int, int);
};

// ----- optree nodes -----
class ast_optree_eq : public ast_optree {
public:
    virtual void print();
    ast_optree_eq(ast_optree*, ast_optree*);
};

class ast_optree_ne : public ast_optree {
public:
    virtual void print();
    ast_optree_ne(ast_optree*, ast_optree*);
};

class ast_optree_gt : public ast_optree {
public:
    virtual void print();
    ast_optree_gt(ast_optree*, ast_optree*);
};

class ast_optree_ge : public ast_optree {
public:
    virtual void print();
    ast_optree_ge(ast_optree*, ast_optree*);
};

class ast_optree_lt : public ast_optree {
public:
    virtual void print();
    ast_optree_lt(ast_optree*, ast_optree*);
};

class ast_optree_le : public ast_optree {
public:
    virtual void print();
    ast_optree_le(ast_optree*, ast_optree*);
};

class ast_optree_plus : public ast_optree {
public:
    virtual void print();
    ast_optree_plus(ast_optree*, ast_optree*);
};

class ast_optree_minus : public ast_optree {
public:
    virtual void print();
    ast_optree_minus(ast_optree*, ast_optree*);
};

class ast_optree_mult : public ast_optree {
public:
    virtual void print();
    ast_optree_mult(ast_optree*, ast_optree*);
};

class ast_optree_div : public ast_optree {
public:
    virtual void print();
    ast_optree_div(ast_optree*, ast_optree*);
};

class ast_optree_mod : public ast_optree {
public:
    virtual void print();
    ast_optree_mod(ast_optree*, ast_optree*);
};

class ast_optree_chs : public ast_optree {
public:
    virtual void print();
    ast_optree_chs(ast_optree*);
};

class ast_optree_int : public ast_optree {
public:
    virtual void print();
    ast_optree_int(int);

    int val;
};

class ast_optree_var : public ast_optree {
public:
    virtual void print();
    ast_optree_var(string, int, int);

    int stl, sto;
    string name;
};

class ast_optree_odd : public ast_optree {
public:
    explicit ast_optree_odd(ast_optree* l) : ast_optree(op_odd, l) {}
    void print() override {
        l->print();
        std::cout << " odd";
    }
};
