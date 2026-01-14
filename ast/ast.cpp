#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <stack>
#include "ast.h"
#include "ram.h"
using namespace std;


// AST
void ast::push_proc(ast_proc proc) {
	v.push_back(proc);
}
void ast::push_proc(string name, int n_var) {
	v.push_back(ast_proc(name, n_var));
}

ast_element * ast::append(ast_element * e) {
	v[v.size() - 1].append(e);
	return e;
}

int ast::interpret(c_RAM & ram, ast_optree * expr) {
	//cout << "interpret " << expr->type << endl;
	int res = 0;
	switch (expr->type) {
		case op_odd: res = interpret(ram, expr->l) % 2; break;
		case op_chs: res = -interpret(ram, expr->l); break;
		case op_plus: res = interpret(ram, expr->l) + interpret(ram, expr->r); break;
		case op_minus: res = interpret(ram, expr->l) - interpret(ram, expr->r); break;
		case op_mult: res = interpret(ram, expr->l) * interpret(ram, expr->r); break;
		case op_div: res = interpret(ram, expr->l) / interpret(ram, expr->r); break;
		case op_mod: res = interpret(ram, expr->l) % interpret(ram, expr->r); break;
		case op_eq: res = interpret(ram, expr->l) == interpret(ram, expr->r); break;
		case op_ne: res = interpret(ram, expr->l) != interpret(ram, expr->r); break;
		case op_gt: res = interpret(ram, expr->l) >  interpret(ram, expr->r); break;
		case op_ge: res = interpret(ram, expr->l) >= interpret(ram, expr->r); break;
		case op_lt: res = interpret(ram, expr->l) <  interpret(ram, expr->r); break;
		case op_le: res = interpret(ram, expr->l) <= interpret(ram, expr->r); break;
		case op_int: res = ((ast_optree_int *) expr)->val; break;
		case op_var: res = ram.read(((ast_optree_var *) expr)->stl, ((ast_optree_var *) expr)->sto); break;
		default: cout << "Unknown operator interpret" << endl;
	}
	return res;
}

void ast::interpret(int nr, c_RAM & ram, int stl) {
	cout << "AST Interpreter " << v[nr].name << " " << v[nr].n_var << endl;
	ram.level_up(v[nr].n_var, stl);
	ast_element * loop = v[nr].start;
	while (loop->get_type() != stmt_end) {
		switch (loop->get_type()) {
			case stmt_write:
			{
				ast_element_write * p = (ast_element_write *) loop;
				cout << "Write " << interpret(ram, p->get_expr()) << endl;;
				loop = loop->next;
			}
				break;
			case stmt_read:
			{
				int value;
				ast_element_read * p = (ast_element_read *) loop;
				printf("Gib %s (%d/%d) ein: ", p->name.c_str(), p->stl, p->sto);
				cin >> value;
				cout << endl;
				ram.write(p->stl, p->sto, value);
				loop = loop->next;
			}
				break;
			case stmt_assign:
			{
				ast_element_assign * p = (ast_element_assign *) loop;
				int value = interpret(ram, p->get_expr());
				ram.write(p->stl, p->sto, value);
				printf("%s (%d/%d) := %d\n", p->name.c_str(), p->stl, p->sto, value);
				loop = loop->next;
			}
				break;
			case stmt_jump:
				loop = loop->jump;
				break;
			case stmt_jmpz:
			{
				ast_element_jmpz * p = (ast_element_jmpz *) loop;
				int value = interpret(ram, p->get_expr());
				printf("jumpz %d\n", value);
				loop = (!value) ? loop->jump : loop->next;
			}
				break;
			case stmt_call:
			{
				ast_element_call * p = (ast_element_call *) loop;
				printf("call  %d\n", p->nr);
				interpret(p->nr, ram, p->stl);
				loop = loop->next;
			}
				break;
			case stmt_nop:
				printf("nop\n");
				loop = loop->next;
				break;
			case stmt_debug:
				//ram.print();
				ram.tikz();
				loop = loop->next;
				break;
			default:
				cout << "Error!" << endl;
				exit(-1);
		}
	}
	ram.level_down();
}


void ast::print() {
	cout << "AST Ausgabe\n";
	for (int i = 0; i < v.size(); i++) {
		printf("Prozedur %s (%d vars)\n", v[i].name.c_str(), v[i].n_var);
		ast_element * loop = v[i].start;
		do {
			cout << loop << ": " << loop->get_type()<< ": " << loop->get_text();
			switch (loop->get_type()) {
				case stmt_end:
					break;
				case stmt_assign: {
					ast_element_assign * p = (ast_element_assign *) loop;
					printf(" %s (%d/%d):", p->name.c_str(), p->stl, p->sto);
					p->get_expr()->print();
				}
					break;
				case stmt_call: {
					ast_element_call * p = (ast_element_call *) loop;
					printf(" %s (%d/%d)", p->name.c_str(), p->stl, p->nr);
				}
					break;
				case stmt_read: {
					ast_element_read * p = (ast_element_read *) loop;
					printf(" %s (%d/%d)", p->name.c_str(), p->stl, p->sto);
				}
					break;
				case stmt_write: {
					ast_element_write * p = (ast_element_write *) loop;
					p->get_expr()->print();
				}
					break;
				case stmt_nop:
					break;
				case stmt_jump: {
					ast_element_jump * p = (ast_element_jump *) loop;
					cout  << " " << p->jump;
				}
					break;
				case stmt_jmpz: {
					ast_element_jmpz * p = (ast_element_jmpz *) loop;
					cout  << " " << p->jump;
					p->get_expr()->print();
				}
					break;
				case stmt_debug:
					break;
			}
			cout << endl;
		} while (loop->get_type() != stmt_end && (loop = loop->next));
	}
}

void ast::tikz(string filename) {
	ofstream texfile;
	streambuf *cout_buf, *file_buf;
	if (filename != "") {
		texfile.open ("texput.tex");
		cout_buf = cout.rdbuf();
		file_buf = texfile.rdbuf();
		cout.rdbuf(file_buf);
	}
	
	cout << "\\documentclass{standalone}\n\\usepackage{tikz}\n\\begin{document}\n";
	cout << "\\begin{tikzpicture}[node/.style={align=center,draw,top color=white, bottom color=blue!20,minimum width=1.2cm,,minimum height=1cm}]\n";
	for (int i = 0; i < v.size(); i++) {
		v[i].tikz(2*i);
	}
	cout << "\\end{tikzpicture}\n\\end{document}" << endl;
	
	cout.flush();
	if (filename != "")
		cout.rdbuf(cout_buf), texfile.close();
}

void ast::interpret() {
	c_RAM ram;
	interpret(0, ram, 0); // proc-nr, ram, stl
}


// AST-Element
ast_element::ast_element(int _type) : type(_type), jump(nullptr), next(nullptr) {}

void ast_element::tikz(int x, int y,string txt) {
	char line[256];
	sprintf(line, "\\node[node] (%llu) at (%d,%d) {\\small %s};\n", (unsigned long long) this, 1*x+1, y, txt.c_str());
	cout << line;
	// ToDo: Zeiger setzen;
}

int ast_element::get_type() {
	return type;
}

string ast_element::get_text() {
	static const string s [] = {"", "end", "assign","call", "read", "write",
		"nop", "jump", "jmpz", "debug"};
	return s[type];
}

void ast_element::set_jump(ast_element * _jump) {
	jump = _jump;
}

ast_element *  ast_element::get_jump() {
	return jump;
}

ast_element *  ast_element::get_next() {
	return next;
}


// AST Element
// write
ast_element_write::ast_element_write(ast_optree * _expr) : ast_element(stmt_write) {
	expr = _expr;
}

void ast_element_write::tikz(int x, int y) {
	ast_element::tikz(x, y, "!");
}

// read
ast_element_read::ast_element_read(string _name, int _stl, int _sto)
: ast_element(stmt_read), name(_name), stl(_stl), sto(_sto) {}

void ast_element_read::tikz(int x, int y) {
	ast_element::tikz(x, y, string("? ") + name + "\\\\" + to_string( stl) + "/" + to_string( sto));
}

// assign
ast_element_assign::ast_element_assign(string _name, int _stl, int _sto, ast_optree * _expr)
: ast_element(stmt_assign), name(_name), stl(_stl), sto(_sto) {
	expr = _expr;
}

void ast_element_assign::tikz(int x, int y) {
	ast_element::tikz(x, y, name + ":=\\\\" + to_string( stl) + "/" + to_string( sto));
}


// call
ast_element_call::ast_element_call(string _name, int _stl, int _nr)
: ast_element(stmt_call), name(_name), stl(_stl), nr(_nr) {}

void ast_element_call::tikz(int x, int y) {
	ast_element::tikz(x, y, name + "()\\\\" + to_string( stl) + "/" + to_string(nr));
}

// debug
ast_element_debug::ast_element_debug() : ast_element(stmt_debug) {}

void ast_element_debug::tikz(int x, int y) {
	ast_element::tikz(x, y, "debug");
}

// jump
ast_element_jump::ast_element_jump(ast_element * _to) : ast_element(stmt_jump) {
	jump = _to;
}

void ast_element_jump::tikz(int x, int y) {
	ast_element::tikz(x, y, "jump");
}

// jumpz
ast_element_jmpz::ast_element_jmpz(ast_optree * _expr, ast_element * to) : ast_element(stmt_jmpz) {
	expr = _expr;
	jump = to;
}

void ast_element_jmpz::tikz(int x, int y) {
	ast_element::tikz(x, y, "jmpz");
}

// nop
ast_element_nop::ast_element_nop() : ast_element(stmt_nop) {}

void ast_element_nop::tikz(int x, int y) {
	ast_element::tikz(x, y, "nop");
}

// end
ast_element_end::ast_element_end() : ast_element(stmt_end) {}

void ast_element_end::tikz(int x, int y) {
	ast_element::tikz(x, y, "end");
}


// AST Procedure

ast_proc::ast_proc(string _n, int _nv) : name(_n), n_var(_nv), start(nullptr), end(nullptr) {}


string ast_proc:: get_name() {
	return name;
}
int ast_proc::get_n_var() {
	return n_var;
}

ast_element * ast_proc::get_start() {
	return start;
}

ast_element * ast_proc::get_end() {
	return end;
}

ast_element * ast_proc::append(ast_element * p) {
	if (start == nullptr)
		start = end = p;
	else
		end->next = p, end = p;
	return p;
}

void ast_proc::tikz(int y) {
	char txt[256];
	sprintf(txt, "\\node(t%d) at (0,%d) {\\begin{minipage}{1cm}%s\\\\(n$_v$=%d)\\end{minipage}};\n", y, y, name.c_str(), n_var);
	cout << txt;
	//printf("\\node at (0.9,%d) {};\n", y);
	int x = 0;
	for (ast_element * p = start; p != nullptr; p = p->next) {
		p->tikz(2 * x++ + 1, y);
	}
	for (ast_element * p = start; p != nullptr; p = p->next) {
		if (p->next != nullptr)
			sprintf(txt, "\\draw[->](%llu) --(%llu);\n",
				   (unsigned long long) p,(unsigned long long) p->next), cout << txt;
		if (p->jump != nullptr)
			sprintf(txt, "\\draw[red,->] ([yshift=3mm]%llu.east) to [out=20,in=160] ([yshift=.3cm]%llu.west);\n",
				   (unsigned long long) p, (unsigned long long) p->jump), cout << txt;
	}
	if (start != nullptr)
		sprintf(txt, "\\draw[->] (t%d) --(%llu);\n", y, (unsigned long long) start), cout << txt;
}

// OPtree
ast_optree::ast_optree(int _type, ast_optree * _l, ast_optree * _r)
: type(_type), l(_l), r(_r) {
}

ast_optree_eq::ast_optree_eq(ast_optree * l, ast_optree * r)
: ast_optree(op_eq, l, r) {}

void ast_optree_eq::print() {
	l->print(), r->print();
	cout << " =";
}

ast_optree_ne::ast_optree_ne(ast_optree * l, ast_optree * r)
: ast_optree(op_ne, l, r) {}

void ast_optree_ne::print() {
	l->print(), r->print();
	cout << " #";
}

ast_optree_gt::ast_optree_gt(ast_optree * l, ast_optree * r)
: ast_optree(op_gt, l, r) {}

void ast_optree_gt::print() {
	l->print(), r->print();
	cout << " >";
}

ast_optree_ge::ast_optree_ge(ast_optree * l, ast_optree * r)
: ast_optree(op_ge, l, r) {}

void ast_optree_ge::print() {
	l->print(), r->print();
	cout << " >=";
}

ast_optree_lt::ast_optree_lt(ast_optree * l, ast_optree * r)
: ast_optree(op_lt, l, r) {}

void ast_optree_lt::print() {
	l->print(), r->print();
	cout << " <";
}

ast_optree_le::ast_optree_le(ast_optree * l, ast_optree * r)
: ast_optree(op_le, l, r) {}

void ast_optree_le::print() {
	l->print(), r->print();
	cout << " <=";
}

ast_optree_plus::ast_optree_plus(ast_optree * l, ast_optree * r)
: ast_optree(op_plus, l, r) {}

void ast_optree_plus::print() {
	l->print(), r->print();
	cout << " +";
}

ast_optree_minus::ast_optree_minus(ast_optree * l, ast_optree * r)
: ast_optree(op_minus, l, r) {}

void ast_optree_minus::print() {
	l->print(), r->print();
	cout << " -";
}

ast_optree_mult::ast_optree_mult(ast_optree * l, ast_optree * r)
: ast_optree(op_mult, l, r) {}

void ast_optree_mult::print() {
	l->print(), r->print();
	cout << " *";
}

ast_optree_div::ast_optree_div(ast_optree * l, ast_optree * r)
: ast_optree(op_div, l, r) {}

void ast_optree_div::print() {
	l->print(), r->print();
	cout << " div";
}

ast_optree_mod::ast_optree_mod(ast_optree * l, ast_optree * r)
: ast_optree(op_mod, l, r) {}


void ast_optree_mod::print() {
	l->print(), r->print();
	cout << " mod";
}

ast_optree_chs::ast_optree_chs(ast_optree * l)
: ast_optree(op_chs, l) {}

void ast_optree_chs::print() {
	l->print();
	cout << " CHS";
}

ast_optree_int::ast_optree_int(int _val)
: ast_optree(op_int), val(_val) {}

void ast_optree_int::print() {
	cout << " " << val;
}

ast_optree_var::ast_optree_var(string _name, int _stl, int _sto)
: ast_optree(op_var), name(_name),	stl(_stl), sto(_sto) {}

void ast_optree_var::print() {
	printf(" %s_(%d/%d)", name.c_str(), stl, sto);
}

