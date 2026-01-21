#pragma once

#include <string>
#include "../ast/ast.h"

// Generates <filename>.asm from the given AST.
// Returns 0 on success, -1 on error.
int ast_2_aassembler(ast& A, std::string filename);
