#include "tree.hpp"
#include <string>
using namespace std;
typedef tree<string> myTree;

int main() {
	myTree * t = new myTree ("+",
		new myTree ("1"),
		new myTree ("*",
			new myTree ("2"),
			new myTree ("3")
		)
	);
	t->childs(1)->ascii();
	(*t)[1]->ascii();
	return 0;
}
