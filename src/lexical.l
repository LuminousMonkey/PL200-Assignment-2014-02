/* Common Regex */
LETTERS [a-z]
DIGITS  [0-9]
WSPACE  [ \t\v\n\f]

%{
/* Remove function that isn't used. */
#define YY_NO_INPUT

#include <stdio.h>

#include "parser.h"
%}

%option nounput
%option warn nodefault

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

{LETTERS}*       { yylval.text = strdup(yytext); return IDENT; }
{DIGITS}*        { yylval.num = atoi(yytext); return NUMBER; }

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
"/"              { return '/'; }

{WSPACE}         { /* Whitespace seperates tokens. */ }
.                printf("Unexpected character.\n");
%%

int yywrap(void) {
  return 1;
}

void yyerror(const char *msg) {
  fflush(stdout);
  fprintf(stderr, "*** %s\n", msg);
}
