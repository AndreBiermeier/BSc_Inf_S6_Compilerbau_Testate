#pragma once

#include <string>
#include "../ast/ast.h"

// Returns 0 on success, -1 on error.
int ast_2_aassembler(ast& AST, std::string filename);
