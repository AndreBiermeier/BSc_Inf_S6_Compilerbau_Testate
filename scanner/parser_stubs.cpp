#include <string>
#include "../tree/tree.hpp"
#include "../parser/y.tab.h"

// Bison semantic value
YYSTYPE yylval;

// Dummy error handler
void yyerror(std::string const&) {}
