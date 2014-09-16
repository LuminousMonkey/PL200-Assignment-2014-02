%{
#include <stdio.h>

#include "parser.h"
#include "lexical.h"

void yyerror(const char *msg);

%}

%token ARRAY ASSIGN _BEGIN_ CALL CONST DECLARATION DO END FOR FUNCTION IDENT
%token IF IMPLEMENTATION INTERVAL NUMBER OF PROCEDURE THEN TYPE VAR WHILE

%%

compound_statement:
                _BEGIN_ statement END { printf("Compound statement.\n"); }
                ;

statement:      assignment { printf("Statement\n"); }
                ;

assignment:     ident ASSIGN expression { printf("Assignment.\n"); }
                ;

expression:
                term { printf("Expression\n"); }
        |       term '+' term { printf("Expr: term + term\n"); }
        |       term '-' term { printf("Expr: term - term\n"); }
                ;

term:
                id_num { printf("id_num\n"); }
        |       id_num '*' id_num { printf("id_num * id_num\n"); }
        |       id_num '+' id_num { printf("id_num + id_num\n"); }
                ;

id_num:
                ident { printf("Id_num: Ident\n"); }
        |       number { printf("Id_num: Number\n"); }
                ;

number:
                NUMBER { printf("Number.\n"); }
                ;

ident:
                IDENT { printf("Ident.\n"); }
                ;

%%
#include <stdio.h>

int main() {
  do {
    yyparse();
  } while (!feof(yyin));

  return 0;
}
