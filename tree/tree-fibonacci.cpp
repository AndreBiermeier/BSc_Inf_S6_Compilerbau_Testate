
#include "tree.hpp"
#include <string>
using namespace std;
typedef tree<std::string> myTree;

myTree *  fibonacci(int n){
	return new myTree(
		string ("f(" + to_string(n) + ")"),
		(n <= 1) ? nullptr : fibonacci(n - 2),
		(n <= 1) ? nullptr : fibonacci(n - 1)
	);
}

int main(){
	fibonacci(5)->tikz();
	return 0;
}
