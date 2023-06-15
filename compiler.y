%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "compiler.h"

/* prototypes */
node *operation(int oper, int nops, ...);
node *id(int i);
node *con(int value);
void nodeFree(node *p);
int ex(node *p);
int yylex(void);

void yyerror(char *s);
int sym[26];                    /* symbol table */
%}

%union {
    int value;                 /* integer value */
    char index;                /* symbol table index */
    node *ptr;             /* node pointer */
};

%token <value> INTEGER
%token <index> VARIABLE
%token WHILE IF PRINT
%nonassoc IFX
%nonassoc ELSE

%left GRE LTE EQL NEQL '>' '<'
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS

%type <ptr> stmt expr stmt_list

%%

program:
        function                { exit(0); }
        ;

function:
          function stmt         { ex($2); nodeFree($2); }
        | /* NULL */
        ;

stmt:
          ';'                            { $$ = operation(';', 2, NULL, NULL); }
        | expr ';'                       { $$ = $1; }
        | PRINT expr ';'                 { $$ = operation(PRINT, 1, $2); }
        | VARIABLE '=' expr ';'          { $$ = operation('=', 2, id($1), $3); }
        | WHILE '(' expr ')' stmt        { $$ = operation(WHILE, 2, $3, $5); }
        | IF '(' expr ')' stmt %prec IFX { $$ = operation(IF, 2, $3, $5); }
        | IF '(' expr ')' stmt ELSE stmt { $$ = operation(IF, 3, $3, $5, $7); }
        | '{' stmt_list '}'              { $$ = $2; }
        ;

stmt_list:
          stmt                  { $$ = $1; }
        | stmt_list stmt        { $$ = operation(';', 2, $1, $2); }
        ;

expr:
          INTEGER               { $$ = con($1); }
        | VARIABLE              { $$ = id($1); }
        | '-' expr %prec UMINUS { $$ = operation(UMINUS, 1, $2); }
        | expr '+' expr         { $$ = operation('+', 2, $1, $3); }
        | expr '-' expr         { $$ = operation('-', 2, $1, $3); }
        | expr '*' expr         { $$ = operation('*', 2, $1, $3); }
        | expr '/' expr         { $$ = operation('/', 2, $1, $3); }
        | expr '<' expr         { $$ = operation('<', 2, $1, $3); }
        | expr '>' expr         { $$ = operation('>', 2, $1, $3); }
        | expr GRE expr          { $$ = operation(GRE, 2, $1, $3); }
        | expr LTE expr          { $$ = operation(LTE, 2, $1, $3); }
        | expr NEQL expr          { $$ = operation(NEQL, 2, $1, $3); }
        | expr EQL expr          { $$ = operation(EQL, 2, $1, $3); }
        | '(' expr ')'          { $$ = $2; }
        ;

%%

node *con(int value) {
    node *p;

    /* allocate node */
    if ((p = malloc(sizeof(node))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeCon;
    p->con.value = value;

    return p;
}

node *id(int i) {
    node *p;

    /* allocate node */
    if ((p = malloc(sizeof(node))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeId;
    p->id.i = i;

    return p;
}

node *operation(int oper, int nops, ...) {
    va_list ap;
    node *p;
    int i;

    /* allocate node, extending op array */
    if ((p = malloc(sizeof(node) + (nops-1) * sizeof(node *))) == NULL)
        yyerror("out of memory");

    /* copy information */
    p->type = typeOpr;
    p->operation.oper = oper;
    p->operation.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->operation.op[i] = va_arg(ap, node*);
    va_end(ap);
    return p;
}

void nodeFree(node *p) {
    int i;

    if (!p) return;
    if (p->type == typeOpr) {
        for (i = 0; i < p->operation.nops; i++)
            nodeFree(p->operation.op[i]);
    }
    free (p);
}

void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
