%{
#include <stdio.h>

#include "parser.h"
#include "lexical.h"

void yyerror(const char *msg);

%}

/* Idents are char strings. */
%union {
  char *text;
  int num;
}

%token ARRAY ASSIGN _BEGIN_ CALL CONST DECLARATION DO END FOR FUNCTION
%token IDENT IF IMPLEMENTATION INTERVAL NUMBER OF PROCEDURE THEN TYPE
%token VAR WHILE

/* Our types for token values, use the union fields above. */
%type <text> ident IDENT
%type <num> number NUMBER

%%

basic_program:  declaration_unit
        |       implementation_unit
                ;

declaration_unit:
                DECLARATION OF ident
                optional_const_declaration
                optional_var_declaration
                DECLARATION END
                { printf("DECLARATION OF " "%s" "DECLARATION END", $3); }
                ;

optional_const_declaration:
        |       CONST constant_declaration
                ;

optional_var_declaration:
        |       VAR variable_declaration
                ;

constant_declaration:
                ident '=' number ';' { printf("[label=const_decl]\n");}
        |       extra_const_declaration ';'
                ;

extra_const_declaration:
        |       ident '=' number ',' extra_const_declaration
                ;

variable_declaration:
                ident ':' ident ';'
                ;

procedure_declaration:
                PROCEDURE ident ';' block ';'
                ;

function_declaration:
                FUNCTION ident ';' block ';'
                ;

implementation_unit:
                IMPLEMENTATION OF ident block '.' { printf("[label=\"Implementation\"]\n"); }
                ;

block:          specification_part implementation_part { printf("[label=\"Block\"]\n");}
                ;

implementation_part:
                statement
                ;

specification_part:
                CONST constant_declaration { printf("CONST ");} {printf("Spec: Const dec.\n");}
        |       VAR variable_declaration
        |       procedure_declaration
        |       function_declaration
                ;

compound_statement:
                _BEGIN_ statement END { printf("Compound statement.\n"); }
                ;

statement:      assignment { printf("Statement: Assign\n"); }
        |       procedure_call { printf("Statement: Procedure call.\n"); }
        |       if_statement
        |       while_statement
        |       do_statement
        |       for_statement
        |       compound_statement
                ;

assignment:     ident ASSIGN expression { printf("assign: [label=%s]\n", $1); }
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

expression:     term { printf("Expression\n"); }
        |       term '+' term { printf("[label=\"expr: +\"]\n"); }
        |       term '-' term { printf("[label=\"expr: -\"]\n"); }
                ;

term:           id_num '*' id_num { printf("[label=\"term: *\"]\n"); }
        |       id_num '/' id_num { printf("[label=\"term: /\"]\n"); }
        |       id_num { printf("[label=\"term: id_num\"]  \n"); }
                ;

id_num:         ident { printf("[label=\"id_num\"]\n"); }
        |       number { printf("[label=\"id_num\"]\n"); }
                ;

number:         NUMBER { printf("[label=\"number: %d\"]\n", $1); $$ = $1; }
                ;

ident:          IDENT { printf("[label=\"ident: %s\"]\n", $1); $$ = $1; }
                ;

%%
#include <stdio.h>

int main() {
  do {
    yyparse();
  } while (!feof(yyin));

  return 0;
}
