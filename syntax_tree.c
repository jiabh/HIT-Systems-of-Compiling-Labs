#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "syntax_tree.h"

SyntaxNode *create_syn_node(char *name, int lineno, ENUM_NODE_TYPE node_type, int child_cnt, ...)
{
    if (lineno <= 0 || child_cnt < 0) // 数据非法
        return NULL;

    // 创建新节点
    SyntaxNode *new_node = malloc(sizeof(SyntaxNode) + child_cnt * sizeof(SyntaxNode *));

    // 保存基本信息
    strcpy(new_node->name, name);
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

/**
 * 根据递归深度打印缩进
 */
#define _PRINT_INDENTATION         \
    for (int i = 0; i < deep; i++) \
        fprintf(stream, "  ");

void preorder_traversal(FILE *stream, SyntaxNode *root, int deep)
{
    if (stream == NULL || root == NULL || deep < 0)
        return;

    /* 首先打印根节点信息 */
    if (root->child_cnt > 0) // 不是叶子节点，输出"节点名 (行号)"
    {
        _PRINT_INDENTATION
        fprintf(stream, "%s (%d)\n", root->name, root->lineno);
    }
    else // 是叶子节点，按照节点类型输出union val中的值
    {
        switch (root->node_type)
        {
        case ENUM_INT:
            _PRINT_INDENTATION
            fprintf(stream, "INT: %d\n", root->intval);
            break;
        case ENUM_FLOAT:
            _PRINT_INDENTATION
            fprintf(stream, "FLOAT: %f\n", root->floatval);
            break;
        case ENUM_ID:
            _PRINT_INDENTATION
            fprintf(stream, "ID: %s\n", root->strval);
            break;
        case ENUM_TYPE:
            _PRINT_INDENTATION
            fprintf(stream, "TYPE: %s\n", root->strval);
            break;
        case ENUM_OTHER:
            if (strlen(root->strval))
            {
                _PRINT_INDENTATION
                fprintf(stream, "%s\n", root->strval);
            } // 否则为空产生式，不输出任何字符
            break;
        default:
            break;
        }
    }

    /* 依次打印各儿子节点的信息 */
    for (size_t i = 0; i < root->child_cnt; i++)
    {
        SyntaxNode *child = root->children[i];
        preorder_traversal(stream, child, deep + 1);
    }
}
