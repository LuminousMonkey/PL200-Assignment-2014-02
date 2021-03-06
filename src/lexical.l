/* Common Regex */
LETTERS [a-zA-Z]
DIGITS  [0-9]
WSPACE  [ \t\v\f\r]

%{
/* Remove function that isn't used. */
#define YY_NO_INPUT

#include <stdio.h>
#include <string.h>

#include "node.h"
#include "parser.h"

int yycolumn = 1;

/*
 * Define our action that is always run before the rule action.
 */
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno; \
    yylloc.first_column = yycolumn; yylloc.last_column = yycolumn+yyleng-1; \
    yycolumn += yyleng;

%}

%option nounput
%option warn nodefault
%option yylineno
%option case-insensitive

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

{LETTERS}+       { yylval.text = strdup(yytext); return IDENT; }
{DIGITS}+        { yylval.numValue = atoi(yytext); return NUMBER; }

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
.                {fprintf(stderr, "Line: %d - Unexpected text: (%s)\n", yylineno, yytext);}
%%

/*
 * We only scan one file at a time, so always return 1 here. Means an
 * EOF is the end of lexical parsing.
 */
int yywrap(void) {
  return 1;
}
