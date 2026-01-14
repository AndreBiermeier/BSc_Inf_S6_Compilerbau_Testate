#!/bin/bash

cd ast || exit 1

if grep -q "EXPRESSION_AST" ast.h 2>/dev/null; then
    CURRENT="expression"
else
    CURRENT="normal"
fi

if [ "$CURRENT" = "normal" ]; then
    echo "Switching AST: normal -> expression"

    cp ast_expression.cpp ast.cpp
    cp ast_expression.h ast.h
else
    echo "Switching AST: expression -> normal"

    cp ast_normal.cpp ast.cpp
    cp ast_normal.h ast.h
fi

echo "AST switched successfully."
