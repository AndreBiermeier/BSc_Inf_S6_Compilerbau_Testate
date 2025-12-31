#include "tree.hpp"
#include <string>
using namespace std;
typedef tree<string> myTree;

int main() {
	myTree * t = new myTree ("E",
		new myTree ("T",
			new myTree ("F", new myTree ("1"))
		),
		new myTree ("+"),
		new myTree ("T",
			new myTree ("F",new myTree ("1"))
		)
	);
	cout << "ASCII-Ausgabe:\n";
	t->ascii();

	return 0;
}
