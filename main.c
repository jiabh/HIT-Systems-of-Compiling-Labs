#include "syntax_tree.h"
#include "C--syntax.tab.h"

extern SyntaxNode *root;

extern int yylineno;
extern int yyparse();
extern void yyrestart(FILE *);

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
    yyparse();
    
    free_syn_tree(root);
    return 0;
}
