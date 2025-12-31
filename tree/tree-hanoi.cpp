
#include "tree.hpp"
#include <string>
using namespace std;
typedef tree<std::string> myTree;

myTree * hanoi(int turm_von, int turm_nach, int turm_via, int hoehe){
	return (!hoehe) ? nullptr : new myTree(
		string (to_string(turm_von) + "$\\rightarrow$" +  to_string(turm_nach)),
		hanoi(turm_von, turm_via, turm_nach, hoehe-1),
		hanoi(turm_via, turm_nach, turm_von, hoehe-1)
	);
}

int main(){
	hanoi(1,2,3,3)->tikz(cout, 1);
	return 0;
}

