#include <stdio.h>
#include "TokenTypes.h"

extern int yylex();
extern int yylineno;
extern char* yytext;

char* name[] = {"ident", "number"};

int main(void) {
  int nameToken, valueToken;

  nameToken = yylex();

  while(nameToken != 0) {
    printf("%d\n", nameToken);
    nameToken = yylex();
  }

  return 0;
}
