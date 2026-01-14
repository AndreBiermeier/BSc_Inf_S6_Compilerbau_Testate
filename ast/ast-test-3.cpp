#include "ast.h"

int main() {
	ast a;
	a.push_proc("main", 1);
	a.append(new ast_element_call("f", 0, 1));
	a.append(new ast_element_write(
		new ast_optree_plus(
			new ast_optree_var("a", 0, 0),
			new ast_optree_int(1)
	)));
	a.append(new ast_element_end());

	a.push_proc("f", 0);
	a.append(new ast_element_read("a", 1, 0));
	a.append(new ast_element_end());
	
	a.print();
	a.tikz();
	a.interpret();
}
