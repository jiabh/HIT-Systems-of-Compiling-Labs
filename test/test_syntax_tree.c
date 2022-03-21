#include <stdlib.h>
#include "../lib/CuTest.h"
#include "../syntax_tree.h"

void test_syntax_node(CuTest *tc)
{
    int child_cnt = 2;

    SyntaxNode *node = malloc(sizeof(SyntaxNode) + child_cnt * sizeof(SyntaxNode *));
    CuAssertPtrNotNull(tc, node);

    node->children[0] = NULL;
    node->children[1] = node;
    CuAssertPtrEquals(tc, NULL, *(node->children));
    CuAssertPtrEquals(tc, node, *(node->children + 1));

    free(node);
}

void test_create_syn_node(CuTest *tc)
{
    SyntaxNode *father, *son1, *son2, *son3, *grandson;
    grandson = create_syn_node("grandson", 1, ENUM_INT, 0);
    son1 = create_syn_node("son1", 2, ENUM_ERROR, 1, grandson);
    son2 = create_syn_node("son2", 3, ENUM_ID, 0);
    son3 = create_syn_node("son3", 4, ENUM_FLOAT, 0);
    father = create_syn_node("father", 5, ENUM_ERROR, 3, son1, son2, son3);

    CuAssertStrEquals(tc, "father", father->name);
    CuAssertStrEquals(tc, "son1", son1->name);

    CuAssertIntEquals(tc, ENUM_INT, grandson->node_type);

    CuAssertPtrEquals(tc, son1, father->children[0]);
    CuAssertPtrEquals(tc, son2, father->children[1]);
    CuAssertPtrEquals(tc, son3, father->children[2]);
    CuAssertPtrEquals(tc, grandson, father->children[0]->children[0]);

    free(father);
    free(son1);
    free(son2);
    free(son3);
    free(grandson);

    // test invalid input
    CuAssertPtrEquals(tc, NULL, create_syn_node("a", -1, ENUM_INT, 0));
    CuAssertPtrEquals(tc, NULL, create_syn_node("a", 1, ENUM_INT, -1));
}

void test_free_syn_tree(CuTest *tc)
{
    SyntaxNode *father, *son1, *son2, *son3, *grandson;
    grandson = create_syn_node("grandson", 1, ENUM_INT, 0);
    son1 = create_syn_node("son1", 2, ENUM_ERROR, 1, grandson);
    son2 = create_syn_node("son2", 3, ENUM_ID, 0);
    son3 = create_syn_node("son3", 4, ENUM_FLOAT, 0);
    father = create_syn_node("father", 5, ENUM_ERROR, 3, son1, son2, son3);

    free_syn_tree(father);
}

CuSuite *SyntaxTreeGetSuite()
{
    CuSuite *suite = CuSuiteNew();
    SUITE_ADD_TEST(suite, test_syntax_node);
    SUITE_ADD_TEST(suite, test_create_syn_node);
    SUITE_ADD_TEST(suite, test_free_syn_tree);
    return suite;
}

void RunAllTests(void)
{
    CuString *output = CuStringNew();
    CuSuite *suite = CuSuiteNew();

    CuSuiteAddSuite(suite, SyntaxTreeGetSuite());

    CuSuiteRun(suite);
    CuSuiteSummary(suite, output);
    CuSuiteDetails(suite, output);
    printf("%s\n", output->buffer);
}

int main(void)
{
    RunAllTests();
}
