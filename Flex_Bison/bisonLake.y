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
  char *string;
  double real;
  double real;
  int function;     
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

%start mainCode

%type <node> startCode list function_definition leftDeclaration parameter_funct parameter_to_funct statement variable_declaration variable_definition expr

startCode :
          | startCode function_definition EOL       {
                                                      eval($2);
                                                      treefree($2);
                                                    }

          | startCode statement EOL
                                                    {
                                                      eval($2);
                                                      treefree($2);
                                                    }
          | startCode EOL               
            startCode error EOL                    { yyerrok; printf("> "); }                                                                                            
          ;

variable_definition : leftDeclaration '=' expr     { $$ = newAssign($1, $3); }   
                    ;''

variable_declaration : TYPE NAME                   { $$ = newDeclaration($1, $2); }
                     | TYPE NAME '[' INTEGER ']'   { $$ = newArrayDeclaration($1, $2, $4); }  //OJITO, DIFERENTE
                     | TYPE NAME '=' expr          { $$ = newList(newDeclaration($1, $2), newAssign(newReference($2), $4)); } 
                     ;

function_definition : FUNCT TYPE NAME '(' parameter_funct ')' '{' EOL list  '}'    { $$ = newFunction($2, $3, $5, $9); }
                    ;

list : statement EOL                       { $$ = $1; }
     | statement EOL list                  { $$ = newList($1, $3); }
     | list EOL
     | EOL                                 { $$ = newNothing(); }
     ;

expr :     leftDeclaration
           | '(' expr ')'                   { $$ = $2; }
           | expr '-' expr                  { $$ = newAst('-', $1, $3); }
           | expr '+' expr                  { $$ = newAst('+', $1, $3); }
           | expr '*' expr                  { $$ = newAst('*', $1, $3); }
           | expr '/' expr                  { $$ = newAst('/', $1, $3); }
           | expr '%' expr                  { $$ = newAst('%', $1, $3); }
           | '-' exp %prec UMINUS           { $$ = newAst('M', $2, NULL); }
           | PRINT '('  ',' expression ')'  { $$ = newAst('P', newString($3), $5); }
           | expr COMPARE expr              { $$ = newAst($2, $1, $3); } 
           | NAME '(' parameter_to_funct ')'{ $$ = newCallFunction($1, $3); }
           | CHAR                           { $$ = newChar($1); }
           | STRING                         { $$ = newString($1); }
           | INTEGER                        { $$ = newNumber(1, $1); }s
           | FLOAT                          { $$ = newNumber(2, $1); }
           ;


statement : variable_declaration ';'
          | variable_definition ';'
          | expr ';'
          | IF '(' expr ')' '{' EOL list '}'                                { $$ = newIf($3, $7, NULL); }
          | IF '(' expr ')' '{' EOL list '}' ELSE '{' EOL list '}'          { $$ = newIf($3, $7, $12); }
          | WHILE '(' expr ')' '{' EOL list '}'                             { $$ = newAst('W', $3, $7); }
          | RETURN expr ';'                                                 { $$ = newAst('X', $2, NULL); }
          | NAME '(' parameter_to_funct ')' ';'                             { $$ = newCall($1, $3); } 
          | BREAK ';'                                                       { $$ = newAst('B', NULL, NULL); }
          ;

leftDeclaration : NAME                                                      { $$ = newReference($1); }
                | NAME '[' expr ']'                                         { $$ = newIndexReference($1, $3); }
                ;

void yyerror(char* mens) {
  printf("Error en linea %i: %s \n", numlin, mens);
}