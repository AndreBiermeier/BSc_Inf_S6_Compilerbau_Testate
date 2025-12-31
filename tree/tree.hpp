/*
 
Template-Klasse tree
 
*/

#pragma once
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
using namespace std;
template <class T> class tree {
public:
	tree();
	~tree();
	tree(T);
	tree(T, tree<T> *);
	tree(T, tree<T> *, tree<T> *);
	tree(T, tree<T> *, tree<T> *, tree<T> *);
	tree(T, vector<tree<T> *>);
	void set(const T & p);
	T & get();
	void ascii(ostream & o = cout, int level = 0);
	void tikz(ostream & o = cout, int path = 0);
	void tikz(string filename, int path = 0);
	void postorder(ostream & o = cout, int level = 0);
	void append(tree *);
	vector<tree<T> *> & childs(); // tbd: Besser iterator ???
	int size();
	tree * parent;
	tree<T> * childs(int);
	tree<T> * operator [] (int);
protected:
	vector<tree *> child;
	string to_latex();
	T v;
	void tikz_path(ostream & o = cout, int level = 0);
};


template <class T> tree<T> * tree<T>::operator [] (int index) {
	return childs(index);
}

template <class T> int tree<T>::size() {
	return child.size();
}

template <class T> tree<T>::tree(T _v) :v(_v) {}

template <class T> tree<T>::tree(T _v ,tree<T> * p) : v(_v) {
	append(p);
}

template <class T> tree<T>::tree(T _v ,tree<T> * p1, tree<T> * p2) : v(_v) {
	append(p1), append(p2);
}

template <class T> tree<T>::tree(T _v ,tree<T> * p1, tree<T> * p2, tree<T> * p3) : v(_v) {
	append(p1), append(p2), append(p3);
}

template <class T> tree<T>::tree(T _v, vector<tree<T> *> childs) : v(_v) {
	for (int i = 0; i < childs.size(); i++)
		append(childs[i]);
}

template <class T>  tree<T>::tree() {
}

template <class T>  tree<T>::~tree() {
	//for (auto i: child) delete i; // C++ 11 !!!!
		
	for (int i = 0; i < child.size(); i++)
		delete child[i];
}

template <class T> void tree<T>::set(const T & _v) {
	v = _v;
}

template <class T> T & tree<T>::get() {
	return v;
}


template <class T> void tree<T>::append(tree * t) {
	if (t != nullptr) {
		child.push_back(t);
		t->parent = this;
	}
}

template <class T> vector<tree<T> *> & tree<T>::childs() {
	return child;
}

template <class T> tree<T> * tree<T>::childs(int n) {
	return (n < 0 || n >= child.size()) ? nullptr : child[n];
}

template <class T> void tree<T>::ascii(ostream & o, int level) {
	for (unsigned i=0; i < level; i++)
		o << "\t";
	o << v << " " << child.size() << endl;
	for (unsigned i=0; i < child.size(); i++) {
		child[i]->ascii(o, level + 1);
	}
}

template <class T> void tree<T>::postorder(ostream & o, int level) {
	for (unsigned i=0; i < child.size(); i++) {
		child[i]->postorder(o, level + 1);
	}
	o << v << " ";
	if (!level)
		o << endl;
}

template <class T> void tree<T>::tikz(string filename, int path) {
	fstream f;
	f.open (filename, fstream::out);
	tikz(f, path);
	f.close();
}

template <class T> void tree<T>::tikz(ostream & o, int path) {
	// Baum-Traversierung First-Order
	static int n = -1;
	int i;
	if (!++n) {
		o << "\\documentclass{standalone}\n";
		o << "\\usepackage{tikz,tikz-qtree}\n\\usepackage[T1]{fontenc}\n";
		o << "\\begin{document}\n";
		// "Normale" Baumansicht
		o << "\\begin{tikzpicture}\n[level distance=1.25cm,sibling distance=.25cm,every tree node/.style={anchor=north,align=center,draw,top color=white, bottom color=blue!20,minimum width=1.5em,minimum height=1.5em},every leaf node/.style={anchor=north,align=center,draw,rounded corners,top color=white, bottom color=red!20,minimum width=1.5em,minimum height=1.5em},blank/.style={draw=none,color=white!0, top color=white!0, bottom color=white!0},"
		// Horizontal wachsend, ggf. optisch geeigneter für Hohe Bäume und Hochformatansicht
		//o << [grow'=right,level distance=4cm,sibling distance=.25cm,every tree node/.style={anchor= west,align=center,draw,top color=white, bottom color=blue!20,minimum width=1.5em,,minimum height=1.5em},every leaf node/.style={anchor=north,align=center,draw,rounded corners,top color=white, bottom color=red!20,minimum width=1.5em,minimum height=1.5em},blank/.style={draw=none,color=white!0, top color=white!0, bottom color=white!0},]
		"]";
		o << "\n\\Tree\n";
	}
	for (i = 0; i < n; i++)
		o << "\t";
	if (child.size()) {
		o << "[." << "\\node(" << this << "){" << to_latex() << "};" << endl;
		for (unsigned i=0; i < child.size(); i++)
			child[i]->tikz(o, n + 1);
		for (i = 0; i < n; i++)
		o << "\t";
		o << "]\n";
	}
	else
		o << "" << "\\node(" << this << "){" << to_latex() << "};" << endl;
	if (!n--) {
		if (path)
			tikz_path(o, 0);
		o << "\\end{tikzpicture}\n";
		o << "\\end{document}\n";
	}
	
}

template <class T> void tree<T>::tikz_path(ostream & o, int level) {
	if (!level)
		o << "\\draw [red, >->] plot [smooth, tension=.75] coordinates {\n";
	if (child.size() == 0) {
		o << "([xshift=-4mm]" << this << ")\n";
		o << "([yshift=-4mm]" << this << ")\n";
		o << "([xshift=+4mm]" << this << ")\n";
	}
/*	else if (child.size() == 1) {
		o << "([xshift=-4mm]" << this << ")\n";
		child[0]->tikz_path(o, level + 1);
		o << "([xshift=+4mm]" << this << ")\n";
	}*/
	else if (child.size() == 2) {
		o << "([xshift=-4mm]" << this << ")\n";
		child[0]->tikz_path(o, level + 1);
		o << "([yshift=-4mm]" << this << ")\n";
		child[1]->tikz_path(o, level + 1);
		o << "([xshift=+4mm]" << this << ")\n";
	}
	else  {
		o << "([xshift=-4mm]" << this << ")\n";
		for (int i = 0; i < child.size(); i++)
			child[i]->tikz_path(o, level + 1);
		o << "([xshift=+4mm]" << this << ")\n";
	}
	if (!level)
		o << "};\n";
}

template <class T> string tree<T>::to_latex() {
	stringstream ss;
	string s, r = "";
	ss << v, getline(ss, s);
	for (int i = 0; i < s.length(); i++)
		switch (s[i]) {
			case '_': r += "\\_"; break;
			case '\'': ;break;
			default: r += s[i];
		}
	return r;
}
