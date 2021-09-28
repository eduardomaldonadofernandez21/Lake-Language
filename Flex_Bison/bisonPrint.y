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

%start function_definition

%%

function_definition : FUNCT TYPE NAME '(' parameter_funct ')' '{' EOL list  '}'    { printf("Definición de funciones\n"); }
                    ;

list : statement EOL                       { printf("Cuerpo\n"); } 
     | statement EOL list                  { printf("Statement list");  }
     | list EOL
     | EOL                                 { printf("Fin de línea\n");  }
     ;

declaration : TYPE NAME                                                                  { printf("Nueva declaración de %s\n",$2);   }                                   
            | TYPE '[' INTEGER ']' NAME                                                  { printf("Nueva declaración de posición %i de array %s\n",$3,$5);   }
            ;

parameter_funct :                                                                { printf("\n");  }
                   | declaration                                                                                                                 
                   | declaration ',' parameter_funct                            { printf("Declaración de parametro de una función\n");  }
                   ;

parameter_to_funct :                                                             { printf("\n");  }
                      | expr                                                     
                      | expr ',' parameter_to_funct                            { printf("Expresion de parametro de una función\n");  }
                      ;

statement : variable_declaration ';'
          | variable_definition ';'
          | expr ';'
          | IF '(' expr ')' '{' EOL list '}'                                { printf("IF Condición\n");  }
          | IF '(' expr ')' '{' EOL list '}' ELSE '{' EOL list '}'          { printf("IF Condición ELSE\n");  }
          | WHILE '(' expr ')' '{' EOL list '}'                             { printf("WHILE Condición\n"); }
          | RETURN expr ';'                                                 { printf("RETURN\n");  }
          | NAME '(' parameter_to_funct ')' ';'                             { printf("NOMBRE DE VARIABLE ()");  }
          | BREAK ';'                                                       { printf("BREAK\n");}
          ;

variable_declaration : TYPE NAME                   { printf("Declaración de variable\n"); }
                     | TYPE NAME '[' INTEGER ']'   { printf("Declaración de una posición de array\n");  }
                     | TYPE NAME '=' expr          { printf("Declaración de variable dandole un valor\n");  }
                     ;

variable_definition : leftDeclaration '=' expr     { printf("Definición de variable\n"); }  
                    ;

leftDeclaration : NAME                                                      { printf("NAME\n"); }  
                | NAME '[' expr ']'                                         { printf("NAME [Expr]\n"); } 
                ;

expr :     leftDeclaration                  { printf("LeftDeclaration\n");  }
           | '(' expr ')'                   { printf("Expresión dentro de ()\n");  }
           | expr '-' expr                  { printf("Resta\n");  }
           | expr '+' expr                  { printf("Suma\n");  }
           | expr '*' expr                  { printf("Multiplicación\n");  }
           | expr '/' expr                  { printf("División\n");  }
           | expr '%' expr                  { printf("Modulo\n");  }
           | '-' expr %prec UMINUS          { printf("Número negativo\n");  }
           | PRINT '('  ',' expr ')'        { printf("Función print");  }
           | expr COMPARE expr              { printf("Símbolo comparación\n");   }
           | NAME '(' parameter_to_funct ')'{ printf("Llamada a función\n");  }
           | CHAR                           { printf("Char\n");  }
           | STRING                         { printf("String\n");  }
           | INTEGER                        { printf("Integer\n"); }
           | FLOAT                          { printf("Float\n");  }
           ;


%%

int main(int argc, char** argv) {
  if (argc>1) yyin=fopen(argv[1],"r");
  yyparse();
}

void yyerror(char* mens) {
  printf("Error en linea: %i: %s \n", numlin ,mens);
}