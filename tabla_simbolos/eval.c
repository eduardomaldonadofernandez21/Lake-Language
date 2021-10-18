#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ast.h"
#include "symbolTable.h"

#define PRINT -12

struct reg * returnResult;
int actualScope = 0;
int callReturn = 0;
int breakLabel = 0;
int reference = 0;

//Función para insertar variables locales en nuestra tabla de símbolos
void insertAsLocalVariable(struct ast *a, int scope, int offset, int reference) {
  struct declaration *decl = (struct declaration *)a;
  struct constant *constante;  
  int length = decl->length;
  int array = (decl->length >= 0) ? 1 : 0;

  insertLocalVariableToSymbolTable(decl->name, offset, decl->type, scope, length, array, reference);
}

//Función que devuelve la cantidad de bytes a reservar para poder guardar en la pila las variables locales
int spaceRequiredForLocalVariable(struct ast *body, int offset) {
  int aux;
  struct declaration *decl;
  int length;

  if (body->nodeType == 'L') {
    aux = spaceRequiredForLocalVariable(body->left, offset);
    aux = spaceRequiredForLocalVariable(body->right, aux);
    return aux;
  }

  if (body->nodeType == 'I' /* || body->nodeType == 'F' */ || body->nodeType == 'W') {
    return spaceRequiredForLocalVariable(((struct flow *)body)->list, offset);
  }

  if (body->nodeType == 'D') {
    decl = (struct declaration *)body;
    length = decl->length <= 0 ? 1 : decl->length;
    aux = decl->type->bytes * length;

    if ((aux % 4) != 0) aux = (int)(aux / 4) * 4 + 4;

    //insertAsLocalVariable(body, getActiveLabel(), -offset - aux, 0);
    return offset + aux;
  }

  return offset;
}

void evalWhile(struct ast *a) {
  int auxBreakLabel = breakLabel;
  //breakLabel = getNextLabel();
  
  //manageConditions(a->left, breakLabel);  
  eval(a->right);           
  //gcWriteLabel(breakLabel);
  //breakLabel = auxBreakLabel;  
}

void evalBreak() {
  //gcJumpToLabel(breakLabel);
}


void evalList(struct ast *a) {
  eval(a->left);
  eval(a->right);
}

void evalIf(struct ast *a) {
  struct ifFlow *i = (struct ifFlow *)a;
  //int label = getNextLabel();
  int elseLabel;

  //manageConditions(i->cond, label);
  eval(i->ifList);   

  if (i->elseList != NULL) {
    //elseLabel = getNextLabel();
    //gcJumpToLabel(elseLabel);
    //gcWriteLabel(label);
    eval(i->elseList);
    //label = elseLabel;
  }
  //gcWriteLabel(label);
}

void evalPrint(struct ast *a) {
  struct context *c;
  struct reg *r0, *r1, *r2;
  int label;

  //c = pushContext();
  //gcWriteContext(c);
  //label = getNextLabel();

  //r0 = getRegister(lookupTypeInSymbolTable(1), "R", 0);
  //gcNumericConstant(r0, label);

  r1 = eval(a->left);

  if (a->right != NULL) {
    r2 = eval(a->right);
  }

  //gcJumpToLabel(PRINT);
  //gcWriteLabel(label);
  //gcRestoreContext(c);
  //popContext(c);
}

struct reg *evalNegativeNumber(struct ast *a){
  struct reg *r = eval(a->left);

  if (!(equalTypes(r->type, lookupTypeInSymbolTable(1)) ||
        equalTypes(r->type, lookupTypeInSymbolTable(2)) ||
        equalTypes(r->type, lookupTypeInSymbolTable(3))))  //Tipos: int, float, ??
  {
    printf("Operando incorrecto para la operación\n");
  }

  //gcMultiplyByConstant(r, -1);
  return r;
}


char *invertCondition(int operation)
{
  switch (operation)
  {
  case 1:
    return "<=";
  case 2:
    return ">=";
  case 3:
    return "<";
  case 4:
    return ">";
  case 5:
    return "!=";
  case 6:
    return "==";
  default:
    printf("Operador de comparación\n");
    break;
  }
}

struct reg *evalCondition(struct ast *a) {
  struct reg *left = eval(a->left);
  struct reg *right = eval(a->right);
  char *operation = invertCondition(a->nodeType);

  //gcWriteLogicalOperation(operation, left, right);

  //freeRegister(right);
  return left;
}

void manageConditions(struct ast *cond, int label) {
  struct reg *aux = eval(cond);

  //gcWriteConditionUsingRegister(aux, label);
}

struct reg *evalRefArray(struct reference *r, struct Symbol *s) {
  struct reg *reg, *free;

  if (r->a) {
    reg = eval(r->a);

    if (!equalTypes(reg->type, lookupTypeInSymbolTable(1))) printf("El tamaño del array solo puede tener un valor Int\n");

    //gcMultiplyRegisterForNumericConstant(reg, s->type);

    if (r->rightHand) {
      /*free = assignRegister(reg->type);
      gcStoreArrayDataInRegister(s->address, reg, s->type, free);

      if (isInFunction() && s->reference) gcStorePointerInRegisterInTheSameRegister(reg);

      freeRegister(free);
    } else {
      free = assignRegister(reg->type);
      gcStoreArrayDirInRegister(s->address, reg, free);

      if (isInFunction() && s->reference) gcStorePointerInRegisterInTheSameRegister(reg);

      freeRegister(free);
      */
    }
  } else {
    //reg = assignRegister(s->type);
    reg->vector = 1;
    reg->length = s->a->length;
    //gcStoreArrayAddressInRegister(s->address, reg);
  }

  reg->type = s->type;
  return reg;
}

struct reg *evalRef(struct ast *a) {
  struct reference *ref = (struct reference *)a;
  struct Symbol *sym;

  struct reg *reg;

  //sym = !isInFunction() ? lookupVariableInSymbolTable(ref->name) : lookupLocalVariableInSymbolTable(ref->name, actualScope);

  if (!sym) printf("Variable no declarada\n");

  if (sym->a) {
    reg = evalRefArray(ref, sym); 
  } else {
    if (ref->rightHand)
    {
      //reg = assignRegister(sym->type);
      //gcCopyContentToRegister(reg, sym);
    }
    else
    {
      //reg = assignRegister(lookupTypeInSymbolTable(1));
      if (sym->a)
      {
        reg->vector = 1;
        reg->length = sym->a->length;
      }
      //gcCopyAddrToRegister(reg, sym->address);
      reg->type = sym->type;
    }
  }

  return reg;
}

int _checkParams(struct ast *params, struct Symbol *func)
{
  struct ast *aux;
  int count = 0;
  aux = params;

  while (aux != NULL) {
    aux = aux->nodeType == 'L' ? aux->right : NULL;
    count++;
  }

  if (count != func->fun->numberOfParams)
  {
    printf("Argumento inexistente\n");
  }

  return count;
}

struct reg *evalCalculator(struct ast *a) {
  struct reg *left = eval(a->left);
  struct reg *right = eval(a->right);
  struct reg *result, *free;

  if (!(((equalTypes(left->type, lookupTypeInSymbolTable(1))) ||
         (equalTypes(left->type, lookupTypeInSymbolTable(2))) ||
         (equalTypes(left->type, lookupTypeInSymbolTable(3)))) &&
        ((equalTypes(right->type, lookupTypeInSymbolTable(1))) ||
         (equalTypes(right->type, lookupTypeInSymbolTable(2))) ||
         (equalTypes(right->type, lookupTypeInSymbolTable(3))))))
  {
    printf("Operando incorrecto para la operación\n");
  }

  //gcRegisterNumericCalculation(a->nodeType, left, right);
  //freeRegister(right);
  return left;
}

int evalArgumentList(struct ast *a, int paramCounter) {
  int returnValue = 0;

  struct reg *r = NULL, *dummy;
  reference = 1;

  if (!(dummy = malloc(sizeof(struct reg)))) printf("Falta de memoria\n");

  dummy->index = 7;
  dummy->label = "R";

  if (paramCounter == 0) {
    return 0;
  } else if (paramCounter == 1) {
    r = eval(a);
    returnValue += r->type->bytes;
    dummy->type = r->type;
    //gcMoveStackPointer(-r->type->bytes);
    //gcSaveInMemoryUsingRegister(dummy, r);
  } else {
    if (paramCounter >= 2) returnValue += evalArgumentList(a->right, paramCounter - 1);

    r = eval(a->left);
    returnValue += r->type->bytes;
    dummy->type = r->type;
    //gcMoveStackPointer(-r->type->bytes);
    //gcSaveInMemoryUsingRegister(dummy, r);
  }

  //freeRegister(r);
  reference = 0;

  return returnValue;
}

void evalCallFunct(struct ast *a) {
  struct callFunction *callFunct = (struct callFunction *)a;
  struct context *cont;
  int moved;
  int label;
  int paramCounter;

  struct Symbol *sym = lookupFunctionInSymbolTable(callFunct->name);
  if (!sym) printf("Función no declarada\n");;

  paramCounter = _checkParams(callFunct->params, sym);
  //cont = pushContext();

  //gcWriteContext(cont);
  moved = evalArgumentList(callFunct->params, paramCounter);
  /*
  gcMoveStackPointer(-8);
  //label = getNextLabel();
  
  gcSaveActualBase();
  gcSaveReturningLabel(label);
  gcJumpToLabel(sym->fun->label);
  gcWriteLabel(label);
  gcMoveStackPointer(moved + 8);
  popContext();
  gcRestoreContext(cont);
  */
}

void *evalReturn(struct ast *a) {
  returnResult = eval(a->left);
  callReturn = 1;
}

int isReturnInFunction(){
  return callReturn != 0 && actualScope > 0;
}

void manageFunctionDeclarationInQ(int label, struct ast *params, struct ast *body,
                                  int numberOfParams, int bytesRequiered)
{
  struct reg *r;

  actualScope = label;
  
  //inFunction();

  //gcWriteLabel(label);
  //gcNewBase();
  //gcReserveSpaceForLocalVariables(bytesRequiered);
  eval(body);
  //gcFreeLocalSpace();
  //gcRestoreBase();
  //r = assignRegister(lookupTypeInSymbolTable(1));
  //gcStoreReturnLabelFromStackInRegister(r);
  //gcPrintGTFromRegister(r);
  //outsideFunction();

  actualScope = 0;
  //freeRegister(r);
}

struct reg *evalConstant(struct ast *a)
{
  struct constant *cons = (struct constant *)a;
  struct reg *r;
  int addr;

  //r = assignRegister(cons->type);

  if (equalTypes(lookupTypeInSymbolTable(5), cons->type) && cons->vector) {
    r->vector = 1;
    r->length = strlen(cons->stringVal) + 1;
    //addr = getNextFreeAddress(strlen(cons->stringVal));
    //gcStoreStringInMemory(addr, cons->stringVal);
    //gcCopyAddrToRegister(r, addr);
  }
  else
  {
    //gcNumericConstant(r, cons->realVal);
  }

  return r;
}

void evalDeclarationArray(struct declaration *decl) {
  int addr;
  int space;

  space = decl->length * decl->type->bytes;

  //addr = getNextFreeAddress(space);

  insertArrayToSymbolTable(decl->name, addr, decl->length, decl->type);

  //gcStoreArrayInMemory(addr, space);
}

void evalFunction(struct ast *a) {
  struct functAst *func = (struct functAst *)a;
  struct ast *aux;
  int numberOfParams = 0, numberOfBytesRequiered, label;
  int baseDir = 8;
  int auxDir = 0;

  aux = func->params;
  //label = getNextLabel();

  printf("Function declaration, params: %d\n", func->params != NULL);

  while (aux != NULL) {
    if (aux->nodeType == 'L') {
      //insertAsLocalVariable(aux->left, label, baseDir, 1);
      auxDir = ((struct declaration *)aux->left)->type->bytes;
      baseDir += auxDir < 4 ? 4 : auxDir;
      aux = aux->right;
    } else {
      //insertAsLocalVariable(aux, label, baseDir, 1);
      auxDir = ((struct declaration *)aux)->type->bytes;
      baseDir += auxDir < 4 ? 4 : auxDir;
      aux = NULL;
    }
    numberOfParams++;
  }

  numberOfBytesRequiered = spaceRequiredForLocalVariable(func->list, 0);

  insertFunctionToSymbolTable(func->name, func->type, label, numberOfParams, numberOfBytesRequiered);

  manageFunctionDeclarationInQ(label, func->params, func->list, numberOfParams, numberOfBytesRequiered);
}

void evalDeclaration(struct ast *a){
  struct declaration *decl = (struct declaration *)a;
  int addr;

  if (decl->length >= 0) {
    evalDeclarationArray(decl);
  } else {
    //addr = getNextFreeAddress(decl->type->bytes);
 
    insertVariableToSymbolTable(decl->name, addr, decl->type);    
    //gcReservePrimitiveSpace(addr, decl->type);
  }
}

// Evaluación de los nodos de asignación
struct reg *evalA(struct ast *a) {
  struct reg *free;
  struct reg *left = eval(a->left);  
  struct reg *right = eval(a->right);  

  if (!areTypesCompatible(left->type, right->type)) printf("Tipos de variables incompatibles\n");

  if (left->vector) {
    if (!right->vector) printf("Un array solo puede ser asignado a otro array\n");

    if (!equalTypes(right->type, left->type)) printf("Tipos de variables incompatibles\n");

    if (right->length > left->length) printf("Operación lógica incorrecta\n");

    //free = assignRegister(right->type);
    //gcCopyArrayToArrayUsingRegister(left, right, free, right->length);
    //freeRegister(free);
  } else {
    //gcSaveInMemoryUsingRegister(left, right);
  }

  //freeRegister(left);
  return right;
}

struct reg *eval(struct ast *a) {
  // printf("NodeType: %d (%c)\n", a->nodeType, a->nodeType);
  struct reg *res = NULL;

  if (a->nodeType == 'L' || a->nodeType == 'F' || a->nodeType == 'W' ||
      a->nodeType == 'N' || a->nodeType == 'I' ||
      a->nodeType == 'B' || a->nodeType == 'C')
  {
    //freeAllRegisters();
  }

  switch (a->nodeType) {
    case 'K':
      res = evalConstant(a);
      break;
    case 'D':
      //if (!isInFunction()) 
      evalDeclaration(a);
      break;
    case 'N':
      break;
    case 'C':
      evalCallFunct(a);
      break;
    case 'F':
      evalFunction(a);
      break;
    case '=':
      res = evalA(a);     
      break;
    case 'L':
      evalList(a);
      break;
    case 'R':
      res = evalRef(a);
      break;
    case 'X':
      evalReturn(a);
      break;
    case 'I':
      evalIf(a);
      break;
    case '+':
    case '-':
    case '*':
    case '/':
    case '%':
    case '^':
      res = evalCalculator(a);
      break;
    case 1: // >
    case 2: // <
    case 3: // >=
    case 4: // <=
    case 5: // ==
    case 6: // !=
      res = evalCondition(a);
      break;
    case 'M':
      res = evalNegativeNumber(a);
      break;
    case 'W':
      evalWhile(a);
      break;
    case 'B':
      evalBreak();
      break;
    case 'P':
      evalPrint(a);
      break;
    default:
      break;
  }
  return res;
}

void treefree(struct ast * a) {
  //freeAllRegisters();
}
