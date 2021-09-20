%{
#include <stdio.h>
#include <stdlib.h>

extern FILE *yyin;   /* declarado en lexico */
extern int numlin;   /* lexico le da valores */
//int yydebug=1;       /* modo debug si -t */
void yyerror(char*); 
%}

%union {
  char *name;
  char *str;
  double real;
  double real;
  int function;
  int mainCode;     
  int compare;                       
  int integer;
  int type;
  struct ast *node;
}

%token <real> FLOAT
%token <integer> INTEGER
%token <str> CHAR STRING
%token <name> NAME
%token <function> FUNCT
%token <mainCode> MAINCODE
%token <type> TYPE
%token IF ELSE WHILE BREAK FOR 
%token PRINT PRINTLN RETURN
%token EOL

%right '='
%left '+' '-'
%left '*' '/' '%'
%left '(' ')'
%nonassoc <compare> COMPARE
%nonassoc UMINUS



%type <node>  expr

%%

expr :     | '(' expr ')'                   { $$ = $2; }
           | expr '-' expr                  { $$ = $1 - $3; }
           | expr '+' expr                  { $$ = $1 + $3; }
           | expr '*' expr                  { $$ = $1 * $3; }
           | expr '/' expr                  { $$ = $1 / $3; }
           | expr '%' expr                  { $$ = $1 % $3; }

           ;


%% 

void yyerror(char* mens) {
  printf("Error en linea %i: %s \n", numlin, mens);
}