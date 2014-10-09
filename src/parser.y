%{
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "node.h"
#include "parser.h"

/* Defined below */
void yyerror(const char *s, ...);

int yylex(void);
extern FILE *yyin;

/* Yes, globals, they serve a purpose in this case. */
static int nodeCount = 0;
static bool graphVizOutput = false;

/* We expect -gv if the user wants GraphViz output. */
static const char* gvOutputArgString = "-gv";

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
                        const int startLine, const int endLine,
                        YYLTYPE *loc,
                        NodeStruct *node, int* const inNodeCounter) {
  node->index = (*inNodeCounter)++;
  node->type = type;
  node->label = label;

  if (graphVizOutput) {
    printf("\t%s%d [label=\"%s\"]\n", type, node->index, label);
  } else {
    printf("Line: %d to %d. Non-terminal: %s\n", startLine, endLine, label);
  }

  loc->first_line = startLine;
  loc->last_line = endLine;
}

/*
 * outputGvNodeEdge
 *
 * Takes the parent node, count of the number of children, and a varg
 * of the children nodes, outputs the links necessary to produce an
 * edge in GraphViz.
 *
 * parent - Parent node.
 * nArgs - Number of child nodes passed in.
 * varg - Child nodes to link to.
 */
void outputGvNodeEdge(const NodeStruct* const parent, const int nArgs, ...) {
  if (graphVizOutput) {
    va_list argp;

    va_start(argp, nArgs);

    NodeStruct* currentChild;

    if (nArgs != 0) {
      printf("\t%s%d -> {", parent->type, parent->index);

      for (int currentArg = 0; currentArg < nArgs; currentArg++ ) {
        currentChild = va_arg(argp, NodeStruct*);
        if (currentChild->type != NULL) {
          printf("%s%d ", currentChild->type, currentChild->index);
        }
      }
      printf("}\n");
    }

    va_end(argp);
  }
}
%}

%define parse.lac full
%define parse.error verbose
%locations

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
                opt_const_declaration
                opt_var_declaration
                opt_type_declaration
                opt_procedure_interface
                opt_function_interface
                DECLARATION END {
                outputGvNodeHeader("declaration", "Declaration Unit",
                                   @1.first_line, @6.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 3, &$3, &$4, &$5);
                }
                ;

opt_const_declaration:
                CONST const_declaration ';' {
                  outputGvNodeHeader("opt_const_declaration", "Opt Const Decl",
                                     @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                  outputGvNodeEdge(&$$, 1, &$2); }
                |       {}
                ;

opt_var_declaration:
                VAR var_declaration ';' {
                  outputGvNodeHeader("opt_var_declaration", "Opt Var Decl",
                                     @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                  outputGvNodeEdge(&$$, 1, &$2);
                }
                |       {}
                ;

opt_type_declaration:
                type_declaration {
                  outputGvNodeHeader("opt_type_declaration", "Opt Type Decl",
                                     @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                }
                |       {}
                ;

const_declaration:
                ident '=' number {
                outputGvNodeHeader("const_dec", "Const Decl",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       ident '=' number ',' const_declaration {
                outputGvNodeHeader("const_dec", "Const Decl",
                                   @1.first_line, @5.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 3, &$1, &$3, &$5); }
                ;

var_declaration:
                ident ':' ident {
                outputGvNodeHeader("var_dec", "Var Decl",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       ident ':' ident ',' var_declaration {
                outputGvNodeHeader("var_dec", "Var Decl",
                                   @1.first_line, @5.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 3, &$1, &$3, &$5); }
                ;

procedure_declaration:
                PROCEDURE ident ';' block ';' {
                outputGvNodeHeader("procedure_decl", "Procedure Decl",
                                   @1.first_line, @5.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$2, &$4); }
                ;

function_declaration:
                FUNCTION ident ';' block ';' {
                outputGvNodeHeader("function_decl", "Function Decl",
                                   @1.first_line, @5.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$2, &$4); }
                ;

opt_procedure_interface:
                PROCEDURE ident formal_params {
                outputGvNodeHeader("procedure_interface", "Procedure Interface",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$2, &$3); }
                ;

opt_function_interface:
                FUNCTION ident formal_params {
                outputGvNodeHeader("function_interface", "Function Interface",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$2, &$3); }
                ;

type_declaration:
                TYPE ident ':' type ';' {
                outputGvNodeHeader("type_declaration", "Type Declaration",
                                   @1.first_line, @5.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$2, &$4); }
                ;

formal_params:  '(' formal_params_ident_list ')' {
                outputGvNodeHeader("formal_params", "Formal Params",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$2); }
        |       { initNode(&$$); }
                ;

formal_params_ident_list:
                formal_params_ident_list ';' ident {
                outputGvNodeHeader("formal_params_ident_list", "Param Ident List",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       ident {
                outputGvNodeHeader("formal_params_ident_list", "Param Ident List",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

type:           basic_type {
                outputGvNodeHeader("type", "Type",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       array_type {
                outputGvNodeHeader("type", "Type",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

basic_type:     ident {
                outputGvNodeHeader("basic_type", "Basic Type",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       enumerated_type {
                outputGvNodeHeader("basic_type", "Basic Type",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       range_type {
                outputGvNodeHeader("basic_type", "Basic Type",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

enumerated_type:
                '{' ident_list '}' {
                outputGvNodeHeader("enumerated_type", "Enumerated Type",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$2); }
                ;

ident_list:     ident_list ',' ident {
                outputGvNodeHeader("ident_list", "Ident List",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       ident {
                outputGvNodeHeader("ident_list", "Ident List",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

range_type:     '[' range ']' {
                outputGvNodeHeader("range_type", "Range Type",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$2); }
                ;

array_type:     ARRAY ident '[' range ']' OF type {
                outputGvNodeHeader("array", "Array",
                                   @1.first_line, @7.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 3, &$2, &$4, &$7); }
                ;

range:          number INTERVAL number {
                outputGvNodeHeader("range", "Range",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
                ;

implementation_unit:
                IMPLEMENTATION OF ident block '.' {
                outputGvNodeHeader("implem_unit", "Implementation",
                                   @1.first_line, @5.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$3, &$4); }
                ;

block:          specification_part implementation_part {
                outputGvNodeHeader("block", "Block",
                                   @1.first_line, @2.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$2); }
                ;

implementation_part:
                statement {
                outputGvNodeHeader("implem_part", "Implem Part",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

specification_part:
                CONST const_declaration ';' {
                outputGvNodeHeader("spec_part", "Spec Part",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$2); }
        |       VAR var_declaration ';' {
                outputGvNodeHeader("spec_part", "Spec Part",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$2); }
        |       procedure_declaration {
                outputGvNodeHeader("spec_part", "Spec Part",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       function_declaration {
                outputGvNodeHeader("spec_part", "Spec Part",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |
                ;

compound_statement:
                _BEGIN_ statement_loop END {
                outputGvNodeHeader("compound_statement", "Compound Statement",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$2); }
                ;

statement_loop: statement_loop ';' statement {
                outputGvNodeHeader("statement_loop", "Statement Loop",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       statement {
                outputGvNodeHeader("statement_loop", "Statement Loop",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

statement:      assignment {
                outputGvNodeHeader("statement", "Statement: Assign",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       procedure_call {
                outputGvNodeHeader("statement", "Statement: Call",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       if_statement {
                outputGvNodeHeader("statement", "Statement: If",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       while_statement {
                outputGvNodeHeader("statement", "Statement: While",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       do_statement {
                outputGvNodeHeader("statement", "Statement: Do",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                }
        |       for_statement {
                outputGvNodeHeader("statement", "Statement: For",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       compound_statement {
                outputGvNodeHeader("statement", "Statement: Compound",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

assignment:     ident ASSIGN expression {
                outputGvNodeHeader("assign", "Assign",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
                ;

procedure_call: CALL ident {
                outputGvNodeHeader("call", "Call",
                                   @1.first_line, @2.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$2); }
                ;

if_statement:   IF expression THEN statement END IF {
                outputGvNodeHeader("if", "If",
                                   @1.first_line, @6.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$2, &$4); }
                ;

while_statement:
                WHILE expression DO statement_loop END WHILE {
                outputGvNodeHeader("while", "While",
                                   @1.first_line, @6.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$2, &$4); }

do_statement:   DO statement WHILE expression END DO {
                outputGvNodeHeader("do", "Do",
                                   @1.first_line, @6.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$2, &$4); }
                ;

for_statement:  FOR ident ASSIGN expression DO statement_loop END FOR {
                outputGvNodeHeader("for", "For",
                                   @1.first_line, @8.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 3, &$2, &$4, &$6); }
                ;

expression:     term {
                outputGvNodeHeader("expr", "Expr",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       term '+' term {
                outputGvNodeHeader("expr", "Expr: *",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       term '-' term {
                outputGvNodeHeader("term", "Term: -",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
                ;

term:           id_num '*' id_num {
                outputGvNodeHeader("term", "Term: *",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       id_num '/' id_num {
                outputGvNodeHeader("term", "Term: /",
                                   @1.first_line, @3.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 2, &$1, &$3); }
        |       id_num {
                outputGvNodeHeader("term", "Term",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

id_num:         ident {
                outputGvNodeHeader("id_num", "ID Num",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
        |       number {
                outputGvNodeHeader("id_num", "ID Num",
                                   @1.first_line, @1.last_line, &@$, &$$, &nodeCount);
                outputGvNodeEdge(&$$, 1, &$1); }
                ;

number:         NUMBER {
                $1.index = nodeCount++;
                if (graphVizOutput) {
                  printf("\tnumber%d [fontcolor=white, color=\"#4f80bd\" "
                         "style=\"rounded,filled\" label=\"number: %d\"]\n",
                         $1.index, $1.numValue);
                } else {
                  printf("Line: %d to %d. Terminal: Number (%d)\n",
                         yyloc.first_line, yyloc.last_line, $1.numValue);
                }
                $$ = $1;
                $$.type = "number";
                $$.label = "Number";}
                ;

ident:          IDENT {
                $1.index = nodeCount++;
                if (graphVizOutput) {
                  printf("\tident%d [fontcolor=white, color=\"#4f80bd\" "
                         "style=\"rounded,filled\" label=\"ident: %s\"]\n",
                         $1.index, $1.text);
                } else {
                  printf("Line: %d to %d. Terminal: Ident (%s)\n",
                         yyloc.first_line, yyloc.last_line, $1.text);
                }
                $$ = $1;
                $$.type = "ident";
                $$.label = "Ident";
                free($$.text);
                $$.text = NULL;}
                ;

%%

int main(int argc, char* argv[]) {
  if (argc == 2) {
    if (strncmp (argv[1], gvOutputArgString, strlen(gvOutputArgString)) == 0) {
      graphVizOutput = true;
    }
  }

  if (graphVizOutput) {
    printf("digraph G {\n");
    printf("\tgraph [fontname = \"Concourse T4\"];\n");
    printf("\tedge [arrowhead=vee, fontname = \"Concourse T4\", "
           "color=\"#4f80bd\"];\n");
    printf("\tnode [pad=\".75\", color=\"#666666\", shape=rectangle, "
           "fontname =\"Concourse T4\", fontcolor=\"#4f80bd\"]\n");
  }

  do {
    yyparse();
  } while (!feof(yyin));

  if (graphVizOutput) {
    printf("}\n");
  }

  return 0;
}

void yyerror(const char *s, ...) {
  va_list ap;
  va_start(ap, s);

  if(yylloc.first_line)
    fprintf(stderr, "Line: %d. Column: %d to Line: %d. Column: %d: error: ",
            yylloc.first_line, yylloc.first_column, yylloc.last_line,
            yylloc.last_column);
  vfprintf(stderr, s, ap);
  fprintf(stderr, "\n");

}

void lyyerror(YYLTYPE t, char *s, ...) {
  va_list ap;
  va_start(ap, s);

  if(t.first_line)
    fprintf(stderr, "Line: %d. Column: %d to Line: %d. Column: %d: error: ",
            t.first_line, t.first_column, t.last_line, t.last_column);
  vfprintf(stderr, s, ap);
  fprintf(stderr, "\n");
}
