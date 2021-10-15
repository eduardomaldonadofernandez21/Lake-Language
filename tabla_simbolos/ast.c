#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ast.h"
#include "symbolTable.h"

struct ast *newAst(int nodeType, struct ast *left, struct ast *right)
{
  struct ast *m = malloc(sizeof(struct ast));

  if (!m)
  {
    printf("Falta de memoria\n");
  }

  m->nodeType = nodeType;
  m->left = left;
  m->right = right;

  return m;
}

struct ast *newChar(char *ch)
{
  struct constant *constante = malloc(sizeof(struct constant));
  if (!constante)
    printf("Falta de memoria\n");

  constante->nodeType = 'K';
  constante->stringVal = ch;
  constante->type = lookupTypeInSymbolTable(5);

  return (struct ast *)constante;
}

struct ast *newString(char *stringValue)
{
  struct constant *constante = malloc(sizeof(struct constant));
  if (!constante)
    printf("Falta de memoria\n");

  constante->nodeType = 'K';
  constante->type = lookupTypeInSymbolTable(5);
  constante->vector = 1;
  constante->stringVal = stringValue;

  return (struct ast *)constante;
}

struct ast *newNumber(int type, double numberVal)
{
  struct constant *constante = malloc(sizeof(struct constant));
  if (!constante)
    printf("Falta de memoria\n");

  constante->nodeType = 'K';
  constante->type = lookupTypeInSymbolTable(type);
  constante->realVal = numberVal;

  return (struct ast *)constante;
}

struct ast *newDeclaration(int type, char *name)
{
  struct declaration *dec = malloc(sizeof(struct declaration));
  
  if (!dec) printf("Falta de memoria\n");

  dec->nodeType = 'D';
  dec->name = name;
  dec->type = lookupTypeInSymbolTable(type);
  dec->length = -1;

  return (struct ast *)dec;
}

struct ast *newArrayDeclaration(int type, char *name, int length)
{
  struct declaration *dec = (struct declaration *)(newDeclaration(type, name));
  dec->length = length;

  return (struct ast *)dec;
}

struct ast *newReference(char *name) {
  struct reference *ref = malloc(sizeof(struct reference));

  if (!ref) printf("Falta de memoria\n");

  ref->nodeType = 'R';
  ref->name = name;
  ref->a = NULL;

  return (struct ast *)ref;
}

struct ast *newIndexReference(char *name, struct ast *index) {
  struct reference *ref = (struct reference *) newReference(name);
  ref->a = index;

  return (struct ast *)ref;
}

struct ast *newRightDeclaration(struct ast *ref) {
  struct reference *r = (struct reference *)ref;
  r->rightHand = 1;

  return (struct ast *)r;
}

struct ast *newFunction(int type, char *name, struct ast *params, struct ast *list)
{
  struct functAst *funct = malloc(sizeof(struct functAst));

  if (!funct)
  {
    printf("Falta de memoria\n");
  }

  funct->nodeType = 'F';
  funct->name = name;
  funct->type = lookupTypeInSymbolTable(type);
  funct->params = params;
  funct->list = list;

  return (struct ast *)funct;
}

struct ast *newCallFunction(char *name, struct ast *params)
{
  struct callFunction *call = malloc(sizeof(struct ast));
  if (!call)
  {
    printf("Falta de memoria\n");
  }

  call->nodeType = 'C';
  call->params = params;
  call->name = name;

  return (struct ast *)call;
}

struct ast *newAssign(struct ast *left, struct ast *right)
{
  struct ast *a = malloc(sizeof(struct ast));
  if (!a)
  {
    printf("Falta de memoria\n");
  }

  a->nodeType = '=';
  a->left = left;
  a->right = right;

  return a;
}

struct ast *newNothing()
{
  struct ast *nothing = malloc(sizeof(struct ast));
  if (!nothing)
  {
    printf("Falta de memoria\n");
  }
  nothing->nodeType = 'N';
  return nothing;
}

struct ast *newIf(struct ast *cond, struct ast *ifList, struct ast *elseList)
{
  struct ifFlow *i = malloc(sizeof(struct ifFlow));

  if (!i)
  {
    printf("Falta de memoria\n");
  }

  i->nodeType = 'I';
  i->cond = cond;
  i->ifList = ifList;
  i->elseList = elseList;

  return (struct ast *)i;
}

struct ast *newList(struct ast *left, struct ast *right)
{
  struct ast *l = malloc(sizeof(struct ast));

  if (!l)
  {
    printf("Falta de memoria\n");
  }

  l->nodeType = 'L';
  l->left = left;
  l->right = right;

  return l;
}
