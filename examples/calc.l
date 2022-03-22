%option noyywrap

%{
    #include <stdio.h>
    #include "calc.tab.h"
%}

digit [0-9]

%%

{digit}* { yylval.ival = atoi(yytext); return INT; }
"+"	{ return ADD; }
"-"	{ return SUB; }
"*"	{ return MUL; }
"/"	{ return DIV; }

%%
