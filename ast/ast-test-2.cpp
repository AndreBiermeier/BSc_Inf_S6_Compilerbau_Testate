#include "ast.h"
// blubber eingeb und blubber * 2 ausgeben
int main() {
	ast a;
	a.push_proc("main", 1);
	a.append(new ast_element_read("blubber", 0, 0));
	a.append(new ast_element_write(
		new ast_optree_mult(
			new ast_optree_var("blubber", 0, 0),
			new ast_optree_int(2)
		)
	));
	a.append(new ast_element_end());
	a.tikz();
	a.interpret();
}
