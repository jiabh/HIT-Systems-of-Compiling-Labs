%option yylineno
%option noyywrap
%{
    #include <stdio.h>
    #include <stdarg.h>

    /* 输出debug信息 */
    #define ESC_START     "\033["
    #define ESC_END       "\033[0m"
    #define COLOR_DEBUG    "36;40;1m"
    
    /**
     * 向stdout打印调试信息
     * @param format 格式化字符串 
     * @param ... 填充值
     */
    void DEBUG(const char *format, ...) {
        va_list args;
        va_start(args, format);

        printf(ESC_START COLOR_DEBUG "DEBUG [Line %d]:" ESC_END " ", yylineno);
        printf(format, args);
        printf("\n");

        va_end(args);
    }


%}

ws [ \t]
dight [0-9]
letter [_a-zA-Z]

/**
 * 以下终结符的定义均来自于书中给出的文法
 * 
 * 部分简单符号不需要定义终结符
 * 详情见：https://blog.csdn.net/u014038143/article/details/78202271
 */
RELOP >|<|>=|<=|==|!=

/* 注意是字符串，而不是终结符INT、FLOAT */
TYPE int|float

STRUCT struct
RETURN return
IF if
ELSE else
WHILE while

/* 以下终结符的定义需要自己编写 */
INT 0|[1-9]{dight}*
FLOAT {dight}+"."{dight}+|{dight}*"."{dight}+[Ee][+-]?{dight}+|{dight}+"."{dight}*[Ee][+-]?{dight}+
ID {letter}({dight}|{letter})*

%%

{ws} { /* 空白符忽略 */ }

";" |
"," |
"=" |
"+" |
"-" |
"*" |
"/" |
"." |
"!" |
"(" |
")" |
"[" |
"]" |
"{" |
"}" { DEBUG(yytext); }

"&&" |
"||" { DEBUG(yytext); }

{RELOP} { DEBUG("RELOP"); }
{TYPE} { DEBUG("TYPE"); }
{STRUCT} { DEBUG("STRUCT"); }
{RETURN} { DEBUG("RETURN"); }
{IF} { DEBUG("IF"); }
{ELSE} { DEBUG("ELSE"); }
{WHILE} { DEBUG("WHILE"); }
{INT} { DEBUG("INT"); }
{FLOAT} { DEBUG("FLOAT"); }
{ID} { DEBUG("ID"); }

\n { DEBUG("\\n"); }

. { fprintf(stderr, "Error type A at Line %d: Mysterious characters \'%s\'\n", yylineno, yytext); }

%%

int main(int argc, char **argv)
{
    if (argc > 1) {
        if (!(yyin = fopen(argv[1], "r"))) {
            perror(argv[1]);
            return 1;
        }
    }
    yylex();

    return 0;
}
