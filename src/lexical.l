/* Common Regex */
LETTERS [a-z]
DIGITS  [0-9]
WSPACE  [ \t\v\f]

%{
/* Remove function that isn't used. */
#define YY_NO_INPUT

#include <stdio.h>

#include "node.h"
#include "parser.h"

int yycolumn = 1;

#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno; \
    yylloc.first_column = yycolumn; yylloc.last_column = yycolumn+yyleng-1; \
    yycolumn += yyleng;

%}

%option nounput
%option warn nodefault
%option yylineno

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
{DIGITS}*        { yylval.numValue = atoi(yytext); return NUMBER; }

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
\n               { yycolumn = 1; }
.                printf("Unexpected character.\n");
%%

int yywrap(void) {
  return 1;
}
