/* Common Regex */
LETTERS [a-z]
DIGITS  [0-9]
WSPACE  [ \t\v\n\f]

%{
#include "TokenTypes.h"
%}

%%

"ARRAY"          { return ARRAY; }
"BEGIN"          { return _BEGIN_; }
"CALL"           { return CALL; }
"CONST"          { return CONST;}
"DECLARATION"    { return DECLARATION; }
"DO"             { return DO; }
"END"            { return END; }
"FOR"            { return FOR; }
"FUNCTION"       { return FUNCTION; }
"IF"             { return IF; }
"IMPLEMENTATION" { return IMPLEMENTATION; }
"OF"             { return OF; }
"PROCEDURE"      { return PROCEDURE; }
"THEN"           { return THEN; }
"TYPE"           { return TYPE; }
"VAR"            { return VAR; }
"WHILE"          { return WHILE; }

{LETTERS}*       { return IDENT; }
{DIGITS}*        { return NUMBER; }

":="             { return ASSIGN; }
".."             { return INTERVAL; }

"("              { return '('; }
")"              { return ')'; }

"="              { return '='; }
":"              { return ':'; }
";"              { return ';'; }

"{"              { return '{'; }
"}"              { return '}'; }

"["              { return '['; }
"]"              { return ']'; }

","              { return ','; }
"."              { return '.'; }

"+"              { return '+'; }
"-"              { return '-'; }
"*"              { return '*'; }

{WSPACE}         { /* Whitespace seperates tokens. */ }
.                printf("Unexpected character.\n");
%%

int yywrap(void) {
  return 1;
}
