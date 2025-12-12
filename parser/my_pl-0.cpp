#include <iostream>
#include <string>
#include <cstdio>

using namespace std;

int yylex();
int yyerror(string);
int yacc_error = 0;

// Flex expects this global
extern FILE* yyin;

int yyerror(const char* t) {
    return yyerror(string(t));
}

int yyerror(const string t) {
    cerr << "Parse error: " << t << endl;
    yacc_error = 1;
    return 0;
}

#include "y.tab.c"
#include "lex.yy.c"

int main(int argc, char* argv[]) {
    if (argc < 2) {
        cerr << "Usage: " << argv[0] << " <pl0_file>" << endl;
        return 1;
    }

    const char* filename = argv[1];
    yyin = fopen(filename, "r");   // <- assign to extern yyin
    if (!yyin) {
        cerr << "Error: cannot open file " << filename << endl;
        return 1;
    }

    yacc_error = 0;
    int rc = yyparse();

    fclose(yyin);

    if (rc == 0 && yacc_error == 0) {
        cout << "Parse successful: " << filename << endl;
        return 0;
    } else {
        cout << "Parse failed: " << filename << endl;
        return 0;
    }
}
