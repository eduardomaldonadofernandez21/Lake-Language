#include <stdio.h>
#include <stdlib.h>
#include "errorException.h"

char *messages[] = {
    "",
    "Out of Space",
    "Variable already declared",
    "Out of Registers",
    "Output file error",
    "Variable not declared",
    "Indexing is only posible with arrays and strings",
    "Incompatible Types",
    "Array Length can only be int type",
    "Internal Error",
    "Function not declared",
    "Arguments missmatch",
    "Bad Operands for numeric operation",
    "Right hand side length is bigger than left hand size.",
    "Bad logical operation",
    "An array can only be assign to another array."
    };

void throwError(int index)
{
  fprintf(stderr, "Error: %s\n", messages[index]);
  exit(index);
}