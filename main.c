#include "syntax_tree.h"
#include "C--syntax.tab.h"

extern SyntaxNode *root;

extern int yydebug; // Bison debug flag

extern int yylineno;
extern int yyparse();
extern void yyrestart(FILE *);

int lex_error_cnt = 0; // 词法错误个数
int syn_error_cnt = 0; // 语法错误个数

int main(int argc, char **argv)
{
    if (argc <= 1)
    {
        yyparse();
        return 1;
    }

    FILE *f = fopen(argv[1], "r");
    if (!f)
    {
        perror(argv[1]);
        return 1;
    }

    yyrestart(f);

#ifdef DEBUG
    yydebug = 1;
#endif
    yyparse();

#ifndef DEBUG
    if (!lex_error_cnt && !syn_error_cnt)
#endif
        preorder_traversal(stdout, root, 0);

    free_syn_tree(root);
    return 0;
}
