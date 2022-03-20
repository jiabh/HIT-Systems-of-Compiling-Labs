/**
  * 教材P16示例，统计输入的行数、单词数和字符个数
**/

%option noyywrap
%{
    #include <stdio.h>
    int line_cnt = 0;
    int word_cnt = 0;
    int char_cnt = 0;
%}

letter [a-zA-Z]

%%

{letter}+ { word_cnt++; char_cnt += yyleng; }
\n { char_cnt++; line_cnt++; }
. { char_cnt++; }

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
    printf("# of lines = %d, # of words = %d, # of chars = %d\n", line_cnt, word_cnt, char_cnt);

    return 0;
}
