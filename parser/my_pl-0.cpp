#include <iostream>
#include <string>
#include <cstdio>

extern int yyparse();
extern FILE* yyin;
void yyerror(const std::string &s) {
    std::cerr << "Error: " << s << std::endl;
}

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            std::cerr << "Cannot open file: " << argv[1] << std::endl;
            return 1;
        }
    }

    int result = yyparse();
    std::cout << "Ergebnis: " << result << std::endl;

    if (yyin) fclose(yyin);
    return 0;
}
