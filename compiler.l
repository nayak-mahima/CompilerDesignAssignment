%{
#include <stdlib.h>
#include "compiler.h"
#include "y.tab.h"
void yyerror(char *);


%}

%%

[a-z]       { 
                yylval.index = *yytext - 'a';
                return VARIABLE;
            }

0           {
                yylval.value = atoi(yytext);
                return INTEGER;
            }

[1-9][0-9]* {
                yylval.value = atoi(yytext);
                return INTEGER;
            }

[-()<>=+*/;{}.] {
                return *yytext;
             }

">="            return GRE;
"<="            return LTE;
"=="            return EQL;
"!="            return NEQL;
"while"         return WHILE;
"if"            return IF;
"else"          return ELSE;
"print"         return PRINT;

[ \t\n]+        ;       /* ignore whitespace */

.               yyerror("Unknown character");
%%
int yywrap(void) {
    return 1;
}
