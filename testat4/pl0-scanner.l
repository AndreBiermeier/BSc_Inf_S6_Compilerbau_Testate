%{
#include "./tree.hpp"
#include "./y.tab.h"
#include <string>
#include <cstdlib>
#include <cstring>

int comment_nesting = 0;

#define PROCESS(id) {\
    yylval.txt = strdup(yytext);\
    return id;\
}
%}

%x COMMENT

%%
"(*"                    {comment_nesting = 1; BEGIN COMMENT;}
<COMMENT>"(*"           {comment_nesting++;}
<COMMENT>"*)"           {if (--comment_nesting == 0) BEGIN 0;}
<COMMENT>.|\n           ;
"."                     return t_punkt;
const|CONST	            return t_const;
"="	                    return t_eq;
","	                    return t_komma;
";"         	        return t_semik;
var|VAR                 return t_var;
procedure|PROCEDURE	    return t_proc;
":="	                return t_assign;
call|CALL	            return t_call;
begin|BEGIN	            return t_begin;
end|END	                return t_end;
"?"         	        return t_read;
"!"         	        return t_write;
if|IF                   return t_if;
then|THEN   	        return t_then;
while|WHILE	            return t_while;
do|DO                   return t_do;
odd|ODD	                return t_odd;
"#"                     return t_ne;
"<"                     return t_lt;
"<="                    return t_le;
">"                     return t_gt;
">="                    return t_ge;
"+"                     return t_plus;
"-"                     return t_minus;
"*"                     return t_mult;
"/"                     return t_div;
"("                     return t_bra_o;
")"                     return t_bra_c;
[a-zA-Z_][a-zA-Z0-9_]*  PROCESS(t_ident);
[0-9]+                  PROCESS(t_number);
[ \t\r\n\f]             ;
.                       return t_error;
%%

int yywrap(void){
    return 1;
}