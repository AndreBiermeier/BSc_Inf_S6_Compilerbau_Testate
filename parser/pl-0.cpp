#include <iostream>
#include <string>
#include <dirent.h>
using namespace std;
int yylex();
int yyerror(string);
int yyparse();
int yacc_error = 0;
int yyerror(const char* t) {
    return yyerror(string(t));
}
int yyerror(const string t) {
    //cout << t;
    yacc_error = 1;
    return 0;
}
#include "y.tab.c"
#include "lex.yy.c"
int main(int argc, char * argv[]) {
    string filename;
    //extern FILE * yyin;
    FILE *out = fopen("results.txt", "a");
    int rc = 0, n = 0, ok = 0;
    string path;
    string dir[] = {"tests/normal/", "tests/syntaxfehler/"};
    int soll[] = {0,1};
    for (int i = 0; i < sizeof(soll) / sizeof(soll[1]); i++) {
        string path = dir[i];
        DIR *dirp = opendir(path.c_str());
        cout << i << " " << path << endl;
        struct dirent *dp;
        while ((dp = readdir(dirp)) != NULL) {
            string f(dp->d_name);
            if (f[0] == '.')
                continue;
            yyin = fopen((path + dp->d_name).c_str(), "r");
            YY_FLUSH_BUFFER;
            yacc_error = 0, rc = yyparse();
            ok += (rc == soll[i]), n++;
            printf("%20s %d\n", dp->d_name, (rc == soll[i]));
            fclose(yyin);
        }
    }
    fprintf(out, "%s %d\n", argv[1], ok);
    fclose(out);
    return 0;
}