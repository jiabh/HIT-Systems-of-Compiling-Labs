%{
    #include <stdio.h>

    extern int yylex();
    extern int yyparse();
    extern FILE* yyin;

    void yyerror(char *msg);
%}

%union {
	int ival;
}

%token<ival> INT
%token ADD SUB MUL DIV

%start Calc

%%
Calc:
    | Exp { printf("= %d\n", $1); }
;
Exp: Factor
    | Exp ADD Factor { $$ = $1 + $3; }
    | Exp SUB Factor { $$ = $1 - $3; }
;
Factor: Term
    | Factor MUL Term { $$ = $1 * $3; }
    | Factor DIV Term { $$ = $1 / $3; }
;
Term: INT
;
%%

int main()
{
    yyin = stdin;

    yyparse();
}

void yyerror(char *msg) {
    fprintf(stderr, "Error: %s\n", msg);
}
