%{
#include <stdio.h>
#include <stdlib.h>
#include "../tabla_simbolos/ast.h"
//#include "../tabla_simbolos/symbolTable.h"

extern FILE *yyin;   /* declarado en lexico */
extern int numlin;   /* lexico le da valores */
//int yydebug=1;       /* modo debug si -t */
void yyerror(char*); 
%}

%union {
  char *name;
  char *string;
  double real;
  int function;     
  int compare;                       
  int integer;
  int type;
  struct ast *node;
}

%token <real> FLOAT
%token <integer> INTEGER
%token <string> CHAR STRING
%token <name> NAME
%token <function> FUNCT
%token <type> TYPE
%token IF ELSE WHILE BREAK FOR 
%token PRINT RETURN
%token EOL

%right '='
%left '+' '-'
%left '*' '/' '%'
%left '(' ')'
%nonassoc <compare> COMPARE
%nonassoc UMINUS

%type <node> function_definition leftDeclaration list declaration parameter_funct parameter_to_funct statement variable_declaration variable_definition expr

%start initial_main

%%
initial_main : /* HOLA */
             | initial_main function_definition EOL                                             {
                                                                                                  eval($2);
                                                                                                  treefree($2);
                                                                                                } 
             | initial_main statement EOL                                                       {
                                                                                                  eval($2);
                                                                                                  treefree($2);
                                                                                                }       
             | initial_main EOL               
             | initial_main error EOL                                                          { yyerrok; printf("> "); }                                                                                            
             ;

function_definition : FUNCT TYPE NAME '(' parameter_funct ')' '{' EOL list  '}'    { $$ = newFunction($2, $3, $5, $9); }
                    ;

list : statement EOL                       { $$ = $1; }
     | statement EOL list                  { $$ = newList($1, $3); }
     | list EOL
     | EOL                                 { $$ = newNothing(); }
     ;

declaration : TYPE NAME                                                                  { $$ = newDeclaration($1, $2); }                                      
            | TYPE '[' INTEGER ']' NAME                                                  { $$ = newArrayDeclaration($1, $5, $3); }
            ;

parameter_funct :                                                                 { $$ = NULL; }
                   | declaration                                                                                                                 
                   | declaration ',' parameter_funct                              { $$ = newList($1, $3); }
                   ;

parameter_to_funct :                                                             { $$ = NULL; }
                      | expr                                                     
                      | expr ',' parameter_to_funct                              { $$ = newList($1, $3); }
                      ;

statement : variable_declaration ';'
          | variable_definition ';'
          | expr ';'
          | IF '(' expr ')' '{' EOL list '}'                                { $$ = newIf($3, $7, NULL); }
          | IF '(' expr ')' '{' EOL list '}' ELSE '{' EOL list '}'          { $$ = newIf($3, $7, $12); }
          | WHILE '(' expr ')' '{' EOL list '}'                             { $$ = newAst('W', $3, $7); }
          | FOR '(' variable_declaration  ';' expr ')' '{' EOL list '}'                       { printf("FOR con 1 definicion de variable y 1 Condición \n"); }
          | FOR '(' expr ')' '{' EOL list '}'                       { printf("FOR con 1 Condición \n"); }
          | FOR '(' variable_declaration  ';' expr   ';' variable_definition ')' '{' EOL list '}'                       { printf("FOR con 1 definicion de variable, 1 Condición y suma de iteracion \n"); }
          | RETURN expr ';'                                                 { $$ = newAst('X', $2, NULL); }
          | NAME '(' parameter_to_funct ')' ';'                             { $$ = newCallFunction($1, $3); }
          | BREAK ';'                                                       { $$ = newAst('B', NULL, NULL); }
          ;

variable_declaration : TYPE NAME                   { $$ = newDeclaration($1, $2); }  
                     | TYPE NAME '[' INTEGER ']'   { $$ = newArrayDeclaration($1, $2, $4); }
                     | TYPE NAME '=' expr          { $$ = newList(newDeclaration($1, $2), newAssign(newReference($2), $4)); }
                     ;

variable_definition : leftDeclaration '=' expr     { $$ = newAssign($1, $3); }  
                    ;

leftDeclaration : NAME                                                      { $$ = newReference($1); } 
                | NAME '[' expr ']'                                         { $$ = newIndexReference($1, $3); }
                ;

expr :     leftDeclaration                  { $$ = newRightDeclaration($1); } 
           | '(' expr ')'                   { $$ = $2; }  
           | INTEGER                        { $$ = newNumber(1, $1); } 
           | FLOAT                          { $$ = newNumber(2, $1); }
           | '-' expr %prec UMINUS          { $$ = newAst('M', $2, NULL); }
           | expr '+' expr                  { $$ = newAst('+', $1, $3); }
           | expr '-' expr                  { $$ = newAst('-', $1, $3); }
           | expr '*' expr                  { $$ = newAst('*', $1, $3); }
           | expr '/' expr                  { $$ = newAst('/', $1, $3); }
           | expr '%' expr                  { $$ = newAst('%', $1, $3); }
           | PRINT '(' STRING ',' expr ')'  { $$ = newAst('P', newString($3), $5); }
           | expr COMPARE expr               { $$ = newAst($2, $1, $3); } 
           | NAME '(' parameter_to_funct ')'{ $$ = newCallFunction($1, $3); }  
           | CHAR                           { $$ = newChar($1); }
           | STRING                         { $$ = newString($1); }
           ;


%%

int main(int argc, char** argv) {
  loadPrimitives();
  if (argc>1) yyin=fopen(argv[1],"r");
  yyparse();
  printSymbolTableContent();
}

void yyerror(char* mens) {
  printf("Error en linea: %i: %s \n", numlin ,mens);
}