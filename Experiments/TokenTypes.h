#ifndef TOKENTYPES_H_
#define TOKENTYPES_H_

enum {
  NONE,
  IDENT,
  NUMBER,
  PLUS,
  MINUS,
  MULTIPLY,
  SEMICOLON,
  BEGIN_BEGIN,
  END_BEGIN,
  BEGIN_FOR,
  END_FOR,
  ASSIGNMENT,
  BEGIN_DO,
  END_DO,
  BEGIN_WHILE,
  END_WHILE,
  BEGIN_IF,
  END_IF,
  THEN
} TokenTypes;

#endif
