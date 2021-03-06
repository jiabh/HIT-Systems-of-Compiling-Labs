%{
    #include <stdio.h>
    #include"C--lexical.yy.c"
    #include "syntax_tree.h"


    extern int syn_error_cnt; // 语法错误个数


    int yylex(void);
    int yyerror(char* msg);

    SyntaxNode *root;
%}

/* 定义节点的数据类型 */
%union {
    SyntaxNode *node; 
}

/* 定义终结符 */
%token <node> INT
%token <node> FLOAT
%token <node> ID
%token <node> ';'
%token <node> ','
%token <node> '='
%token <node> RELOP
%token <node> '+'
%token <node> '-'
%token <node> '*'
%token <node> '/'
%token <node> AND "&&"
%token <node> OR "||"
%token <node> '.'
%token <node> '!'
%token <node> TYPE
%token <node> '('
%token <node> ')'
%token <node> '['
%token <node> ']'
%token <node> '{'
%token <node> '}'
%token <node> STRUCT
%token <node> RETURN
%token <node> IF
%token <node> ELSE
%token <node> WHILE

/* 定义非终结符的类型 */
%type <node> Program ExtDefList ExtDef ExtDecList
%type <node> Specifier StructSpecifier OptTag Tag
%type <node> VarDec FunDec VarList ParamDec
%type <node> CompSt StmtList Stmt
%type <node> DefList Def Dec DecList
%type <node> Exp Args

/* 定义运算符优先级 */
%right '='
%left "||"
%left "&&"
%left RELOP
%left '-'
%left '+'
%left '*' '/'
%left '!'
%left '(' ')' '[' ']' '.'

// 通过定义优先级更低的LOWER_THAN_ELSE运算符，使ELSE优先级：移入 > 归约
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

/* High-level Definitions */
Program: ExtDefList {
    $$ = create_syn_node("Program", @$.first_line, ENUM_ERROR, 1, $1);
    root = $$;
};

ExtDefList: ExtDef ExtDefList { $$ = create_syn_node("ExtDefList", @$.first_line, ENUM_ERROR, 2, $1, $2); }
    | { $$ = create_syn_node("ExtDefList", @$.first_line, ENUM_ERROR, 0); }
;

ExtDef: Specifier ExtDecList ';' { $$ = create_syn_node("ExtDef", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | Specifier ';' { $$ = create_syn_node("ExtDef", @$.first_line, ENUM_ERROR, 2, $1, $2); }
    | Specifier FunDec CompSt { $$ = create_syn_node("ExtDef", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
;

ExtDecList: VarDec { $$ = create_syn_node("ExtDecList", @$.first_line, ENUM_ERROR, 1, $1); }
    | VarDec ',' ExtDecList { $$ = create_syn_node("ExtDecList", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
;


/* Specifiers */
Specifier: TYPE { $$ = create_syn_node("Specifier", @$.first_line, ENUM_ERROR, 1, $1); }
    | StructSpecifier { $$ = create_syn_node("Specifier", @$.first_line, ENUM_ERROR, 1, $1); }
;

StructSpecifier: STRUCT OptTag '{' DefList '}' { $$ = create_syn_node("StructSpecifier", @$.first_line, ENUM_ERROR, 5, $1, $2, $3, $4, $5); }
    | STRUCT Tag { $$ = create_syn_node("StructSpecifier", @$.first_line, ENUM_ERROR, 2, $1, $2); }
;

OptTag: ID { $$ = create_syn_node("OptTag", @$.first_line, ENUM_ERROR, 1, $1); }
    | { $$ = create_syn_node("OptTag", @$.first_line, ENUM_ERROR, 0); }
;

Tag: ID { $$ = create_syn_node("Tag", @$.first_line, ENUM_ERROR, 1, $1); }
;


/* Declarators */
VarDec: ID { $$ = create_syn_node("VarDec", @$.first_line, ENUM_ERROR, 1, $1); }
    | VarDec '[' INT ']' { $$ = create_syn_node("VarDec", @$.first_line, ENUM_ERROR, 4, $1, $2, $3, $4); }
    | error ']' { syn_error_cnt++; }
;

FunDec: ID '(' VarList ')' { $$ = create_syn_node("FunDec", @$.first_line, ENUM_ERROR, 4, $1, $2, $3, $4); }
    | ID '(' ')' { $$ = create_syn_node("FunDec", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | ID error ';' { syn_error_cnt++; }
;

VarList: ParamDec ',' VarList { $$ = create_syn_node("VarList", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | ParamDec { $$ = create_syn_node("VarList", @$.first_line, ENUM_ERROR, 1, $1); }
;

ParamDec: Specifier VarDec { $$ = create_syn_node("ParamDec", @$.first_line, ENUM_ERROR, 2, $1, $2); }
;


/* Statements */
CompSt: '{' DefList StmtList '}' { $$ = create_syn_node("CompSt", @$.first_line, ENUM_ERROR, 4, $1, $2, $3, $4); }
    | error ';' { syn_error_cnt++; }
;

StmtList: Stmt StmtList { $$ = create_syn_node("StmtList", @$.first_line, ENUM_ERROR, 2, $1, $2); }
    | { $$ = create_syn_node("StmtList", @$.first_line, ENUM_ERROR, 0); }
;

Stmt: Exp ';' { $$ = create_syn_node("Stmt", @$.first_line, ENUM_ERROR, 2, $1, $2); }
    | CompSt { $$ = create_syn_node("Stmt", @$.first_line, ENUM_ERROR, 1, $1); }
    | RETURN Exp ';' { $$ = create_syn_node("Stmt", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | IF '(' Exp ')' Stmt  %prec LOWER_THAN_ELSE { $$ = create_syn_node("Stmt", @$.first_line, ENUM_ERROR, 5, $1, $2, $3, $4, $5); }
    | IF '(' Exp ')' Stmt ELSE Stmt { $$ = create_syn_node("Stmt", @$.first_line, ENUM_ERROR, 7, $1, $2, $3, $4, $5, $6, $7); }
    | WHILE '(' Exp ')' Stmt { $$ = create_syn_node("Stmt", @$.first_line, ENUM_ERROR, 5, $1, $2, $3, $4, $5); }
    | Exp error ';' { syn_error_cnt++; }
;


/* Local Definitions */
DefList: Def DefList { $$ = create_syn_node("DefList", @$.first_line, ENUM_ERROR, 2, $1, $2); }
    | { $$ = create_syn_node("DefList", @$.first_line, ENUM_ERROR, 0); }
;

Def: Specifier DecList ';' { $$ = create_syn_node("Def", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | Specifier error ';' { syn_error_cnt++; }
;

DecList: Dec { $$ = create_syn_node("DecList", @$.first_line, ENUM_ERROR, 1, $1); }
    | Dec ',' DecList { $$ = create_syn_node("DecList", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
;

Dec: VarDec { $$ = create_syn_node("Dec", @$.first_line, ENUM_ERROR, 1, $1); }
    | VarDec '=' Exp { $$ = create_syn_node("Dec", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
;


/* Expressions */
Exp: Exp '=' Exp { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | Exp "&&" Exp { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | Exp "||" Exp { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | Exp RELOP Exp { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | Exp '+' Exp { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | Exp '-' Exp { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | Exp '*' Exp { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | Exp '/' Exp { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | '(' Exp ')' { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | '-' Exp { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 2, $1, $2); }
    | '!' Exp { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 2, $1, $2); }
    | ID '(' Args ')' { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 4, $1, $2, $3, $4); }
    | ID '(' ')' { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | Exp '[' Exp ']' { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 4, $1, $2, $3, $4); }
    | Exp '.' ID { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | ID { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 1, $1); }
    | INT { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 1, $1); }
    | FLOAT { $$ = create_syn_node("Exp", @$.first_line, ENUM_ERROR, 1, $1); }
;

Args: Exp ',' Args { $$ = create_syn_node("Args", @$.first_line, ENUM_ERROR, 3, $1, $2, $3); }
    | Exp { $$ = create_syn_node("Args", @$.first_line, ENUM_ERROR, 1, $1); }
;

%%

int yyerror(char* msg) {
    // 输出错误信息
    fprintf(stderr, "Error type B at line %d: %s.\n", yylineno, msg);
}
