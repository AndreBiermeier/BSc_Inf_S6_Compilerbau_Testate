#include "tree.hpp"
#include <string>

class node {
public:
	node(int t, string v = ""): type(t), value(v) {};
	string value;
	int type;
};
ostream & operator << (ostream & o, const node & n) {
	return o << n.type << "(" << n.value << ")";
	return o;
}
typedef tree<node> myTree;

int main() {
	myTree * t = new myTree (node(1, "+"),
		new myTree (node(5, "a")),
		new myTree (node(3, "*"),
			new myTree(node(5, "b")),
			new myTree (node(5, "c"))
		)
	);
	t->tikz();
	return 0;
}
