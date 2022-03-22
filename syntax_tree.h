#ifndef _SYNTAX_TREE_H_
#define _SYNTAX_TREE_H_

#include <stdio.h>

/**
 * 用于标识语法树叶子节点类型
 */
typedef enum
{
    ENUM_INT,
    ENUM_FLOAT,
    ENUM_ID,
    ENUM_TYPE,
    ENUM_OTHER, // 其余语法单元处理方式相同，标识为同一单元
    ENUM_ERROR  // 节点不是token
} ENUM_NODE_TYPE;

/**
 * 语法树节点
 */
typedef struct syntax_node
{
    char name[32]; // 节点名，输出节点时用
    int lineno;    // 所在行号
    int child_cnt; // 孩子个数

    ENUM_NODE_TYPE node_type; // 节点类型
    union                     // 节点值
    {
        int intval;
        float floatval;
        char strval[32]; // 假设token长度不超过32
    };

    struct syntax_node *children[0]; // 每个指针指向一个孩子
} SyntaxNode;

/**
 * 创建一个语法树节点。节点值未设置，记得返回后自行设置intval/floatval/strval
 *
 * @param name 节点名
 * @param lineno 节点所在行号
 * @param node_type 节点类型。若不是叶子节点，则应设为ENUM_ERROR
 * @param child_cnt 该节点的孩子个数
 * @param ... 指向该节点孩子的child_cnt个指针，类型均为 SyntaxNode *
 * @return 新节点的指针
 */
SyntaxNode *create_syn_node(char *name, int lineno, ENUM_NODE_TYPE node_type, int child_cnt, ...);

/**
 * 销毁一棵语法树
 * @param root 树根节点
 */
void free_syn_tree(SyntaxNode *root);

/**
 * 销毁一棵语法树
 * @param stream 输出流，将向此处输出语法树
 * @param root 树根节点
 * @param deep 传入0
 */
void preorder_traversal(FILE *stream, SyntaxNode *root, int deep);

#endif
