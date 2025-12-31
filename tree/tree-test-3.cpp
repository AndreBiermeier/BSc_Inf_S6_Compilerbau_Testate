/*
 C++ 17 Standard!
 
 */
#include "tree.hpp"
#include <string>

typedef tree<std::string> myTree;
int main() {
	myTree * t = new myTree ("5 Kinder", {
		new myTree ("Gerda"),
		new myTree ("Hans"),
		new myTree ("Anna"),
		new myTree ("Anne"),
		new myTree ("Georg")
	});
	t->tikz(cout);
	return 0;
}
