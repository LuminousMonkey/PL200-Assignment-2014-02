/*
 * Programming Languages 200 - Assignment 2014
 *
 * Author: Mike Aldred (09831542)
 *
 * General code for handling syntax tree nodes.
 */

#include "node.h"

#include <stddef.h>

void initNode(NodeStruct* const inNode) {
  inNode->index = 0;
  inNode->numValue = 0;
  inNode->text = NULL;
  inNode->type = NULL;
  inNode->label = NULL;
}
