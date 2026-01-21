#include <iostream>
#include <string>
#include <dirent.h>
#include <cstdio>  // for FILE, fopen, fclose
#include "../tree/tree.hpp"
#include "y.tab.h"  // token definitions from Bison
using namespace std;

// -----------------------
// Parser / scanner functions
// -----------------------
int yylex();
int yyparse();
int yyerror(const string &t);

int yacc_error = 0;

int yyerror(const char* t) { return yyerror(string(t)); }
int yyerror(const string &t) {
    yacc_error = 1;
    //cout << t << endl;
    return 0;
}

// -----------------------
// Use Bison/Flex headers
// -----------------------
extern FILE* yyin;  // input file for scanner
extern void yyrestart(FILE*);  // reset scanner buffer

// -----------------------
// Main function: run tests
// -----------------------
int main(int argc, char * argv[]) {
    FILE *out = fopen("cmake-build-debug/results.txt", "a");
    if (!out) { cerr << "Cannot open results.txt\n"; return 1; }

    int rc = 0, n = 0, ok = 0;

    // Get directories and expected return codes from argv

    string dir[2] = {"parser/tests/normal/", "parser/tests/syntaxfehler/"};
    dir[0] = argv[1];
    dir[1] = argv[2];
    int soll[2] = {0,1};

    for (size_t i = 0; i < sizeof(soll)/sizeof(soll[0]); i++) {
        string path = dir[i];
        DIR *dirp = opendir(path.c_str());
        if (!dirp) { cerr << "Cannot open directory: " << path << endl; continue; }

        cout << i << " " << path << endl;

        struct dirent *dp;
        while ((dp = readdir(dirp)) != nullptr) {
            string f(dp->d_name);
            if (f[0] == '.') continue;  // skip . and ..

            yyin = fopen((path + "/" + dp->d_name).c_str(), "r");
            if (!yyin) { cerr << "Cannot open file: " << f << endl; continue; }

            yyrestart(yyin);  // reset scanner buffer

            yacc_error = 0;
            rc = yyparse();

            ok += (rc == soll[i]);
            n++;

            printf("%20s %d\n", dp->d_name, (rc == soll[i]));

            fclose(yyin);
        }

        closedir(dirp);
    }

    fprintf(out, "%s %d\n", (argc > 1 ? argv[1] : "tests"), ok);
    fclose(out);

    cout << "✅ Tests completed. Passed " << ok << " out of " << n << " files.\n";
    return 0;
}
