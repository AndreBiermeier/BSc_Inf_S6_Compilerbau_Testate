#pragma once
#include <map>
#include <iostream>
#include <vector>
#include <string>
using namespace std;

template <class ENTRY>
class symtab {
	public:
		symtab(int debug = 0);
		void level_up();
		void level_down();
		int insert(const string & name, const ENTRY &);
		int lookup(const string & name, ENTRY &, int & delta);
		int lookup(const string & name);
		void print();
		int actual_level();
	private:
		vector< map<string, ENTRY> > content;
		int debug;
};

template <class ENTRY> symtab<ENTRY>::symtab (int _debug) : debug(_debug) {
	if (debug)
		cerr << "Symtab constructor" << endl;
}

template <class ENTRY> void symtab<ENTRY>::level_up() {
	content.push_back(map<string,ENTRY>());
	if (debug)
		cerr << "Symtab-level-up to " << content.size() - 1 <<endl;
}

template <class ENTRY> void symtab<ENTRY>::level_down() {
	content.pop_back();
	if (debug)
		cerr << "Symtab-level-down from " << content.size() << endl;
}







template <class ENTRY> int symtab<ENTRY>::insert(const string & name, const ENTRY & e){
	int r = -1;
	if (content[content.size()-1].find(name) == content[content.size()-1].end())
		content[content.size()-1][name] = e; r = 0;
	if (debug)
		cerr << "Symtab-insert " << name << ": " << e << " Return Value: " << r << endl;
	return r;
}






template <class ENTRY> int symtab<ENTRY>::lookup(const string & name, ENTRY & e, int & delta) {
	int i = content.size(), rc = -1;
	while (--i >= 0 && content[i].find(name) == content[i].end());
	if (i >= 0)
		rc = 0, delta = content.size() - i - 1, e = content[i][name];
	if (debug)
		cerr << "Symtab-lookup " << name << ": " << e << " delta=" << delta << " Return:" << rc << endl;
	return rc;
}


template <class ENTRY> int symtab<ENTRY>::lookup(const string & name) {
	ENTRY e;
	int delta;
	return lookup(name, e, delta);
}

template <class ENTRY> int symtab<ENTRY>::actual_level() {
	return content.size() - 1;
}

template <class ENTRY> void symtab<ENTRY>::print(){
	if (debug == 1) {
		cerr << "Symboltabelle Anzahl Level: " << content.size() << endl;
		for (int i = 0; i < content.size(); i++) {
			cerr << "\tLevel " << i << ": n=" << content[i].size()  << endl;
			for(typename map<string, ENTRY>::iterator pos = content[i].begin();
				pos != content[i].end(); ++pos)
				cerr << "\t\tName: " << pos->first << " " << pos->second << endl;
		}
	}
	else if (debug == 2) {
		
	}
}
