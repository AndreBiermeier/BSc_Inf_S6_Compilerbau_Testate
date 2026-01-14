#include "ast.h"
// 1 + 2 * 3
int main() {
	ast a;
	a.push_proc("main", 0);
	a.append(
		new ast_element_write(
			new ast_optree_plus(
				new ast_optree_int(1),
				new ast_optree_mult(
					new ast_optree_int(2),
					new ast_optree_int(3)
				)
			)
		)
	);
	a.append(new ast_element_end());
	a.tikz();
	a.interpret();
}
