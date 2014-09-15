%{
#include "TokenTypes.h"
%}

%%

"BEGIN"          return BEGIN_BEGIN;
"END"            return END_BEGIN;

"FOR"            return BEGIN_FOR;
"END FOR"        return END_FOR;

"DO"             return BEGIN_DO;
"END DO"         return END_DO;

"WHILE"          return BEGIN_WHILE;
"END WHILE"      return END_WHILE;

"IF"             return BEGIN_IF;
"THEN"           return THEN;
"END IF"         return END_IF;

;                return SEMICOLON;

:=               return ASSIGNMENT;

\+               return PLUS;
\-               return MINUS;
\*               return MULTIPLY;

[a-z]+           return IDENT;
[0-9]+           return NUMBER;

[ \t\n]          ;
.                printf("Unexpected character.\n");
%%

int yywrap(void) {
  return 1;
}
