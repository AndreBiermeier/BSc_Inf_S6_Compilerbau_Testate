
#include "tree.hpp"
#include <string>
using namespace std;
typedef tree<std::string> myTree;
int main() {
	myTree * t = new myTree ("root");
	for (int i = 0; i < 10; i++)
		t->append(new myTree(to_string(i)));
	t->tikz(cout);
	return 0;
}
