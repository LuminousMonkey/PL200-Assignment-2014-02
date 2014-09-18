/*
 * Programming Languages 200 - Assignment 2014
 *
 * Author: Mike Aldred (09831542)
 *
 * Defines struct used in the nodes of the parser.
 */

#ifndef NODE_H_
#define NODE_H_

typedef struct {
  int index;
  int numValue;
  const char *text;
  const char *type;
  const char *label;
} NodeStruct;

#define YYSTYPE NodeStruct

#endif
