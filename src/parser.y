%{
#include <stdio.h>

#include "parser.h"
#include "lexical.h"

void yyerror(const char *msg);

int nodeCount = 0;

%}

%code requires {
  typedef struct {
    int index;
    char *text;
    int numValue;
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
                const_assignment ';'
                { $$.index = nodeCount++;
                printf("const_decl%d [label=\"Const Dec\"]\n", $$.index);
                printf("const_decl%d -> const_assign%d\n", $$.index, $1.index);
                }
                ;

const_assignment:
                ident '=' number
                {
                printf("const_assign%d [label=\"Const Assign\"]\n", $$.index);
                printf("const_assign%d -> ident%d\n", $$.index, $1.index);
                printf("const_assign%d -> number%d\n", $$.index, $3.index);}
        |       ident '=' number ',' const_assignment
                { $$.index = nodeCount++;
                printf("const_assign%d [label=\"Const Assign\"]\n", $$.index);
                printf("const_assign%d -> ident%d\n", $$.index, $1.index);
                printf("const_assign%d -> number%d\n", $$.index, $3.index);
                printf("const_assign%d -> const_assign%d\n", $$.index, $5.index);
                }
                ;

variable_declaration:
                var_assignment ';'
                { $$.index = nodeCount++;
                printf("var_decl%d [label=\"Var Dec\"]\n", $$.index);
                printf("var_decl%d -> var_assign%d\n", $$.index, $1.index);
                }
                ;

var_assignment:
                ident ':' number
                {
                printf("var_assign%d [label=\"Var Assign\"]\n", $$.index);
                printf("var_assign%d -> ident%d\n", $$.index, $1.index);
                printf("var_assign%d -> number%d\n", $$.index, $3.index);}
        |       ident ':' number ',' var_assignment
                { $$.index = nodeCount++;
                printf("var_assign%d [label=\"Var Assign\"]\n", $$.index);
                printf("var_assign%d -> ident%d\n", $$.index, $1.index);
                printf("var_assign%d -> number%d\n", $$.index, $3.index);
                printf("var_assign%d -> var_assign%d\n", $$.index, $5.index);
                }
                ;

procedure_declaration:
                PROCEDURE ident ';' block ';'
                ;

function_declaration:
                FUNCTION ident ';' block ';'
                ;

implementation_unit:
                IMPLEMENTATION OF ident block '.' {
                $$.index = nodeCount++;
                printf("implem_unit%d [label=\"Implementation\"]\n", $$.index);
                printf("implem_unit%d -> ident%d\n", $$.index, $3.index);
                printf("implem_unit%d -> block%d\n", $$.index, $4.index); }
                ;

block:          specification_part implementation_part
                { $$.index = nodeCount++;
                printf("block%d [label=\"Block\"]\n", $$.index);
                printf("block%d -> spec_part%d\n", $$.index, $1.index);
                printf("block%d -> implem_part%d\n", $$.index, $2.index);}
                ;

implementation_part:
                statement {
                $$.index = nodeCount++;
                printf("implem_part%d [label=\"implem_part\"]\n", $$.index);
                printf("implem_part%d -> statement%d\n", $$.index, $1.index);}
                ;

specification_part:
                CONST constant_declaration {
                $$.index = nodeCount++;
                printf("spec_part%d [label=\"spec_part\"]\n", $$.index);
                printf("spec_part%d -> const_decl%d\n", $$.index, $2.index);}
        |       VAR variable_declaration
        |       procedure_declaration
        |       function_declaration
                ;

compound_statement:
                _BEGIN_ statement_loop END {
                $$.index = nodeCount++;
                printf("compound_statement%d [label=\"Compound statement\"]\n", $$.index);
                printf("compound_statement%d -> statement_loop%d\n", $$.index, $2.index); }
                ;

statement_loop: statement_loop ';' statement {
                $$.index = nodeCount++;
                printf("statement_loop%d [label=\"Statement loop\"]\n", $$.index);
                printf("statement_loop%d -> statement_loop%d\n", $$.index, $1.index);
                printf("statement_loop%d -> statement%d\n", $$.index, $3.index);
                }
        |       statement {
                $$.index = nodeCount++;
                printf("statement_loop%d [label=\"Statement loop\"]\n", $$.index);
                printf("statement_loop%d -> statement%d\n", $$.index, $1.index);
                }
                ;

statement:      assignment {
                $$.index = nodeCount++;
                printf("statement%d [label=\"Statement\"]\n", $$.index);
                printf("statement%d -> assign%d\n", $$.index, $1.index); }
        |       procedure_call { printf("Statement: Procedure call.\n"); }
        |       if_statement
        |       while_statement
        |       do_statement
        |       for_statement
        |       compound_statement {
                $$.index = nodeCount++;
                printf("statement%d [label=\"Statement\"]\n", $$.index);
                printf("statement%d -> compound_statement%d\n", $$.index, $1.index);
                }
                ;

assignment:     ident ASSIGN expression {
                $$.index = nodeCount++;
                printf("assign%d [label=assign]\n", $$.index);
                printf("assign%d -> ident%d\n", $$.index, $1.index);
                printf("assign%d -> expr%d\n", $$.index, $3.index);}
                ;

procedure_call: CALL ident { printf("[label=\"Call\"]\n"); }
                ;

if_statement:   IF expression THEN statement END IF {printf("IF\n");}
                ;

while_statement:
                WHILE expression DO statement END WHILE {printf("While\n"); }

do_statement:   DO statement WHILE expression END DO {printf("DO\n");}
                ;

for_statement:  FOR ident ASSIGN expression DO statement END FOR { printf("[label=For]"); }
                ;

expression:     term {
                $$.index = nodeCount++;
                printf("expr%d [label=\"Expr\"]\n", $$.index);
                printf("expr%d -> term%d\n", $$.index, $1.index); }
        |       term '+' term {
                $$.index = nodeCount++;
                printf("expr%d [label=\"Expr: +\"]\n", $$.index);
                printf("expr%d -> term%d\n", $$.index, $1.index);
                printf("expr%d -> term%d\n", $$.index, $3.index);
                }
        |       term '-' term {
                $$.index = nodeCount++;
                printf("expr%d [label=\"Expr: -\"]\n", $$.index);
                printf("expr%d -> term%d\n", $$.index, $1.index);
                printf("expr%d -> term%d\n", $$.index, $3.index);
                }
                ;

term:           id_num '*' id_num {
                $$.index = nodeCount++;
                printf("term%d [label=\"term: *\"]\n", $$.index);
                printf("term%d -> id_num%d\n", $$.index, $1.index);
                printf("term%d -> id_num%d\n", $$.index, $3.index);
                }
        |       id_num '/' id_num {
                $$.index = nodeCount++;
                printf("term%d [label=\"term: /\"]\n", $$.index);
                printf("term%d -> id_num%d\n", $$.index, $1.index);
                printf("term%d -> id_num%d\n", $$.index, $3.index);
                }
        |       id_num {
                $$.index = nodeCount++;
                printf("term%d [label=\"term\"]\n", $$.index);
                printf("term%d -> id_num%d\n", $$.index, $1.index); }
                ;

id_num:         ident {
                $$.index = nodeCount++;
                printf("id_num%d [label=\"id_num\"]\n", $$.index);
                printf("id_num%d -> ident%d\n", $$.index, $1.index); }
        |       number {
                $$.index = nodeCount++;
                printf("id_num%d [label=\"id_num\"]\n", $$.index);
                printf("id_num%d -> number%d\n", $$.index, $1.index); }
                ;

number:         NUMBER { $1.index = nodeCount++; printf("number%d [shape=\"circle\" label=\"number: %d\"]\n", $1.index, $1.numValue); $$ = $1; }
                ;

ident:          IDENT { $1.index = nodeCount++; printf("ident%d [shape=\"circle\" label=\"ident: %s\"]\n", $1.index, $1.text); $$ = $1; }
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
