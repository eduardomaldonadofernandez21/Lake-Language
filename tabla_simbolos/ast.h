extern int numlin;

struct ast
{
  int nodeType;
  struct ast *left;
  struct ast *right;
};

struct reg
{
  int vector;
  int length;
  int reference;
  struct TypeSymbol *type;
  char *label;
  int index;
};

struct ifFlow
{
  int nodeType;
  struct ast *cond;
  struct ast *ifList;
  struct ast *elseList;
};

struct flow
{
  int nodeType;
  struct ast *list;
};

struct declaration
{
  int nodeType;
  char *name;
  struct TypeSymbol *type;
  int length;
};

struct functAst
{
  int nodeType;
  char *name;
  struct TypeSymbol *type;
  struct ast *params;
  struct ast *list;
};

struct reference
{
  int nodeType;
  int rightHand;
  char *name;
  struct ast *a;
};

struct callFunction
{
  int nodeType;
  char *name;
  struct ast *params;
};

struct constant
{
  int nodeType;
  struct TypeSymbol *type;
  double realVal;
  char *stringVal;
  int vector;
};

struct ast *newAst(int nodeType, struct ast *left, struct ast *right);

struct ast *newChar(char *ch);
struct ast *newString(char *stringValue);
struct ast *newNumber(int type, double numberVal);

struct ast *newDeclaration(int type, char *name);
struct ast *newArrayDeclaration(int type, char *name, int length);
struct ast *newReference(char *name);
struct ast *newIndexReference(char *name, struct ast *index);
struct ast *newRightDeclaration(struct ast *ref);
struct ast *newFunction(int type, char *name, struct ast *params, struct ast *list);
struct ast *newCallFunction(char *name, struct ast *params);
struct ast *newAssign(struct ast *left, struct ast *right);
struct ast *newNothing();
struct ast *newIf(struct ast *cond, struct ast *ifList, struct ast *elseList);
struct ast *newList(struct ast *left, struct ast *right);


void manageConditions(struct ast *cond, int label);

struct reg * eval(struct ast *a);
void treefree(struct ast *a);