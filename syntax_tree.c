#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "syntax_tree.h"

SyntaxNode *create_syn_node(char *name, int lineno, ENUM_NODE_TYPE node_type, int child_cnt, ...)
{
    if (lineno <= 0 || child_cnt < 0) // 数据非法
        return NULL;

    // 创建新节点
    SyntaxNode *new_node = malloc(sizeof(SyntaxNode) + child_cnt * sizeof(SyntaxNode *));

    // 保存基本信息
    new_node->name = name;
    new_node->lineno = lineno;
    new_node->child_cnt = child_cnt;
    new_node->node_type = node_type;

    // 保存各子节点
    va_list args;
    va_start(args, child_cnt);
    for (size_t i = 0; i < child_cnt; i++)
    {
        new_node->children[i] = va_arg(args, SyntaxNode *);
    }
    va_end(args);

    return new_node;
}

void free_syn_tree(SyntaxNode *node)
{
    if (node == NULL)
        return;

    // 依次释放所有孩子节点
    for (size_t i = 0; i < node->child_cnt; i++)
        free_syn_tree(node->children[i]);

    // 释放自己
    free(node);
}

void preorder_traversal(FILE *stream, SyntaxNode *root)
{
    // TODO 实现语法树的先序遍历
}
