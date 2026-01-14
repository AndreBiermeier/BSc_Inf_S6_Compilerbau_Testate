#include "ast.h"

int main() {
	ast a;
	a.push_proc("main", 1);
	a.append(new ast_element_read("a", 0, 0));
	ast_element * jump = a.append(new ast_element_jmpz(
		new ast_optree_lt(
			new ast_optree_var("a", 0, 0),
			new ast_optree_int(0)
	)));
	a.append(new ast_element_assign("a", 0, 0,
		new ast_optree_chs(
			new ast_optree_var("a", 0, 0)
	)));
	jump->set_jump(a.append(new ast_element_nop()));
	a.append(new ast_element_write(
		new ast_optree_var("a", 0, 0)
	));
	a.append(new ast_element_end());
	a.tikz(), a.interpret();
}
