%option yylineno
%option noyywrap
%{
    #include <stdio.h>
    #include <stdarg.h>
    #include <stdlib.h>
    #include <string.h>
    #include "syntax_tree.h"
    // C--syntax.tab.h在bison build过程中生成
    #include "C--syntax.tab.h"


    /* 维护语法单元的位置信息，来自书P31 */
    int yycolumn = 1;
    #define YY_USER_ACTION \
        yylloc.first_line = yylloc.last_line = yylineno; \
        yylloc.first_column = yycolumn; \
        yylloc.last_column = yycolumn + yyleng - 1; \
        yycolumn += yyleng;


    /* 输出debug信息 */
    #define ESC_START     "\033["
    #define ESC_END       "\033[0m"
    #define COLOR_DEBUG    "36;40;1m"
    
    /**
     * 向stdout打印调试信息
     * 
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


    /**
     * 创建叶节点，并将其写入yylval
     * 
     * @param name 节点名
     * @param lineno 节点所在行号
     * @param node_type 节点类型。若不是叶子节点，则应设为ENUM_ERROR
     */
    #define CREATE_TOKEN_NODE(name, lineno, node_type) \
        yylval.node = create_syn_node(name, lineno, node_type, 0);
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
"}" {
    DEBUG(yytext);
    CREATE_TOKEN_NODE(yytext, yylloc.first_line, ENUM_OTHER)
    return yytext[0];
}

"&&" {
    DEBUG(yytext);
    CREATE_TOKEN_NODE(yytext, yylloc.first_line, ENUM_OTHER)
    return AND;
}

"||" {
    DEBUG(yytext);
    CREATE_TOKEN_NODE(yytext, yylloc.first_line, ENUM_OTHER)
    return OR;
}

{RELOP} {
    DEBUG("RELOP");
    CREATE_TOKEN_NODE("RELOP", yylloc.first_line, ENUM_OTHER)
    return RELOP;
}

{TYPE} {
    DEBUG("TYPE");
    CREATE_TOKEN_NODE("TYPE", yylloc.first_line, ENUM_TYPE)
    return TYPE;
}

{STRUCT} {
    DEBUG("STRUCT");
    CREATE_TOKEN_NODE("STRUCT", yylloc.first_line, ENUM_OTHER)
    return STRUCT;
}

{RETURN} {
    DEBUG("RETURN");
    CREATE_TOKEN_NODE("RETURN", yylloc.first_line, ENUM_OTHER)
    return RETURN;
}

{IF} {
    DEBUG("IF");
    CREATE_TOKEN_NODE("IF", yylloc.first_line, ENUM_OTHER)
    return IF;
}

{ELSE} {
    DEBUG("ELSE");
    CREATE_TOKEN_NODE("ELSE", yylloc.first_line, ENUM_OTHER)
    return ELSE;
}

{WHILE} {
    DEBUG("WHILE");
    CREATE_TOKEN_NODE("WHILE", yylloc.first_line, ENUM_OTHER)
    return WHILE;
}

{INT} {
    DEBUG("INT");
    CREATE_TOKEN_NODE("INT", yylloc.first_line, ENUM_INT)
    yylval.node->intval = atoi(yytext);
    return INT;
}

{FLOAT} {
    DEBUG("FLOAT");
    CREATE_TOKEN_NODE("FLOAT", yylloc.first_line, ENUM_FLOAT)
    yylval.node->floatval = (float) atof(yytext);
    return FLOAT;
}

{ID} {
    DEBUG("ID");
    CREATE_TOKEN_NODE("ID", yylloc.first_line, ENUM_ID)
    strcpy(yylval.node->strval, yytext);
    return ID;
}

\n {
    DEBUG("\\n");
    yycolumn = 1;
}

. { fprintf(stderr, "Error type A at Line %d: Mysterious character \'%s\'\n", yylineno, yytext); }

%%
