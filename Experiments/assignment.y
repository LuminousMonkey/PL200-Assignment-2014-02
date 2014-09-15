%{
/* Experimenting with grammar. */

#include <stdio.h>

int yylex();

void yyerror(const char *inString);
%}

%token         NUMBER

%left '-' '+'

%%

program:        program expr '\n' {printf("%d\n", $2);}
        |
                ;

expr:           NUMBER { $$=$1; printf("Here"); }
        |       expr '+' expr { $$ = $1 + $3; }
        |       expr '-' expr { $$ = $1 - $3; }
                ;
%%
#include <stdio.h>

int main() {
  yyparse();
}

void yyerror(const char *inString) {
  fflush(stdout);
  fprintf(stderr, "*** %s\n", inString);
}
