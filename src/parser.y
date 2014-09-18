%{
#include <stdarg.h>
#include <stdio.h>

#include "parser.h"
#include "lexical.h"

void yyerror(const char *msg);

int nodeCount = 0;

/*
 * outputGvNodeHeader
 *
 * Takes an id string (type), label, node, and count of how many nodes
 * that have been read already. Will modify the given node so it will
 * have the given type and label incase these are needed further up in
 * the tree. It will then output the GraphViz header for this node.
 *
 * Yes, this is doing two things, mutating and outputting, however,
 * given the format of Bison and how well this function fits with what
 * is being done, I've bend that rule a little.
 *
 * type - String that describes the type of the node.
 * label - String to show in the actual node.
 * node - Pointer to node structure that we will modify and print
 *        header for.
 * inNodeCounter - pointer to int that counts how many nodes we're
 *                 read.
 */
void outputGvNodeHeader(const char* const type,
                        const char* const label,
                        NodeStruct *node, int* const inNodeCounter) {
  node->index = (*inNodeCounter)++;
  node->type = type;
  node->label = label;

  printf("%s%d [label=\"%s\"]\n", type, node->index, label);
}

void outputGvNodeEdge(const NodeStruct* const parent, const int nArgs, ...) {
  va_list argp;

  va_start(argp, nArgs);

  NodeStruct* currentChild;

  for (int currentArg = 0; currentArg < nArgs; currentArg++ ) {
    currentChild = va_arg(argp, NodeStruct*);
    printf("%s%d -> %s%d\n", parent->type, parent->index, currentChild->type, currentChild->index);
  }
}
%}

%code requires {
  typedef struct {
    int index;
    int numValue;
    const char *text;
    const char *type;
    const char *label;
  } NodeStruct;

#define YYSTYPE NodeStruct
}

%token ARRAY ASSIGN _BEGIN_ CALL CONST DECLARATION DO END FOR FUNCTION
%token IDENT IF IMPLEMENTATION INTERVAL NUMBER OF PROCEDURE THEN TYPE
%token VAR WHILE

/* Our types for token values, use the union fields above. */

%start basic_program
%%

basic_program:  declaration_unit
        |       implementation_unit
                ;

declaration_unit:
                DECLARATION OF ident
                optional_const_declaration
                optional_var_declaration
                DECLARATION END
                { printf("DECLARATION OF " "%s" "DECLARATION END", $3.text); }
                ;

optional_const_declaration:
                CONST constant_declaration
        |
                ;

optional_var_declaration:
                VAR variable_declaration
        |
                ;

constant_declaration:
                const_assignment ';' {
                outputGvNodeHeader("const_decl", "Const Dec", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

const_assignment:
                ident '=' number
                {
                outputGvNodeHeader("const_assign", "Const Assign", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       ident '=' number ',' const_assignment {
                outputGvNodeHeader("const_assign", "Const Assign", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 3, &$1, &$3, &$5); }
                ;

variable_declaration:
                var_assignment ';' {
                outputGvNodeHeader("var_decl", "Var Decl", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

var_assignment:
                ident ':' number {
                outputGvNodeHeader("var_assign", "Var Assign", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       ident ':' number ',' var_assignment {
                outputGvNodeHeader("var_assign", "Var Assign", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 3, &$1, &$3, &$5); }
                ;

procedure_declaration:
                PROCEDURE ident ';' block ';'
                ;

function_declaration:
                FUNCTION ident ';' block ';'
                ;

implementation_unit:
                IMPLEMENTATION OF ident block '.' {
                outputGvNodeHeader("implem_unit", "Implementation", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$3, &$4); }
                ;

block:          specification_part implementation_part {
                outputGvNodeHeader("block", "Block", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$2); }
                ;

implementation_part:
                statement {
                outputGvNodeHeader("implem_part", "Implem Part", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

specification_part:
                CONST constant_declaration {
                outputGvNodeHeader("spec_part", "Spec Part", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$2); }
        |       VAR variable_declaration {
                outputGvNodeHeader("spec_part", "Spec Part", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$2); }
        |       procedure_declaration {
                outputGvNodeHeader("spec_part", "Spec Part", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       function_declaration {
                outputGvNodeHeader("spec_part", "Spec Part", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

compound_statement:
                _BEGIN_ statement_loop END {
                outputGvNodeHeader("compound_statement", "Compound Statement", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$2); }
                ;

statement_loop: statement_loop ';' statement {
                outputGvNodeHeader("statement_loop", "Statement Loop", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       statement {
                outputGvNodeHeader("statement_loop", "Statement Loop", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

statement:      assignment {
                outputGvNodeHeader("statement", "Statement", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       procedure_call { printf("Statement: Procedure call.\n"); }
        |       if_statement {
                outputGvNodeHeader("statement", "Statement", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       while_statement {
                outputGvNodeHeader("statement", "Statement", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       do_statement
        |       for_statement {
                outputGvNodeHeader("statement", "Statement", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       compound_statement {
                outputGvNodeHeader("statement", "Statement", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

assignment:     ident ASSIGN expression {
                outputGvNodeHeader("assign", "Assign", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
                ;

procedure_call: CALL ident { printf("[label=\"Call\"]\n"); }
                ;

if_statement:   IF expression THEN statement END IF {
                outputGvNodeHeader("if", "IF", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$2, &$4); }
                ;

while_statement:
                WHILE expression DO statement_loop END WHILE {
                outputGvNodeHeader("while", "While", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$2, &$4); }

do_statement:   DO statement WHILE expression END DO {printf("DO\n");}
                ;

for_statement:  FOR ident ASSIGN expression DO statement_loop END FOR {
                outputGvNodeHeader("for", "For", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 3, &$2, &$4, &$6); }
                ;

expression:     term {
                outputGvNodeHeader("expr", "Expr", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       term '+' term {
                outputGvNodeHeader("expr", "Expr: *", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       term '-' term {
                outputGvNodeHeader("term", "Term: -", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
                ;

term:           id_num '*' id_num {
                outputGvNodeHeader("term", "Term: *", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       id_num '/' id_num {
                outputGvNodeHeader("term", "Term: /", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       id_num {
                outputGvNodeHeader("term", "Term", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

id_num:         ident {
                outputGvNodeHeader("id_num", "ID Num", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       number {
                outputGvNodeHeader("id_num", "ID Num", &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

number:         NUMBER {
                $1.index = nodeCount++;
                printf("number%d [shape=\"circle\" label=\"number: %d\"]\n", $1.index, $1.numValue);
                $$ = $1;
                $$.type = "number";
                $$.label = "Number";}
                ;

ident:          IDENT {
                $1.index = nodeCount++;
                printf("ident%d [shape=\"circle\" label=\"ident: %s\"]\n", $1.index, $1.text);
                $$ = $1;
                $$.type = "ident";
                $$.label = "Ident";}
                ;

%%
#include <stdio.h>

int main() {
  printf("digraph G {\n");
  printf("\tnode [shape=rectangle]\n");

  do {
    yyparse();
  } while (!feof(yyin));

  printf("}\n");

  return 0;
}
