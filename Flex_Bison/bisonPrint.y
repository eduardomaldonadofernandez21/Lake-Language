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

%start function_definition

%type <node> function_definition leftDeclaration list declaration parameter_funct parameter_to_funct statement variable_declaration variable_definition expr

%%

function_definition : FUNCT TYPE NAME '(' parameter_funct ')' '{' EOL list  '}'    { $$ = printf("Definición de funciones\n"); }
                    ;

list : statement EOL                       { $$ = printf("Cuerpo\n"); } 
     | statement EOL list                  { $$ = printf("");  }
     | list EOL
     | EOL                                 { $$ = printf("Fin de línea\n");  }
     ;

declaration : TYPE NAME                                                                  { $$ = printf("Nueva declaración de %s\n",$2);   }                                   
            | TYPE '[' INTEGER ']' NAME                                                  { $$ = printf("Nueva declaración de posición %i de array %s\n",$3,$5);   }
            ;

parameter_funct :                                                                { $$ = printf("\n");  }
                   | declaration                                                                                                                 
                   | declaration ',' parameter_funct                            { $$ = printf("Declaración de parametro %s de una función\n", $1);  }
                   ;

parameter_to_funct :                                                             { $$ = printf("\n");  }
                      | expr                                                     
                      | expr ',' parameter_to_funct                            { $$ = printf("Expresion de parametro %s de una función\n", $1);  }
                      ;

statement : variable_declaration ';'
          | variable_definition ';'
          | expr ';'
          | IF '(' expr ')' '{' EOL list '}'                                { $$ = printf("IF Condición %s\n", $3);  }
          | IF '(' expr ')' '{' EOL list '}' ELSE '{' EOL list '}'          { $$ = printf("IF Condición %s ELSE\n",$3);  }
          | WHILE '(' expr ')' '{' EOL list '}'                             { $$ = printf("WHILE Condición %s\n",$3); }
          | RETURN expr ';'                                                 { $$ = printf("RETURN %s\n",$2);  }
          | NAME '(' parameter_to_funct ')' ';'                             { $$ = printf("%s (%s)\n",$1,$3);  }
          | BREAK ';'                                                       { $$ = printf("BREAK\n");}
          ;

variable_declaration : TYPE NAME                   { $$ = printf("Declaración de variable\n"); }
                     | TYPE NAME '[' INTEGER ']'   { $$ = printf("Declaración de una posición de array\n");  }
                     | TYPE NAME '=' expr          { $$ = printf("Declaración de variable dandole un valor\n");  }
                     ;

variable_definition : leftDeclaration '=' expr     { $$ =  printf("Definición de variable\n"); }  
                    ;

leftDeclaration : NAME                                                      { $$ = printf("%s\n",$1); }  
                | NAME '[' expr ']'                                         { $$ = printf("%s [%s]\n",$1,$3); } 
                ;

expr :     leftDeclaration                  { $$ = printf("LeftDeclaration\n");  }
           | '(' expr ')'                   { $$ = printf("Expresión dentro de ()\n");  }
           | expr '-' expr                  { $$ = printf("Resta %f - %f\n",$1,$3);  }
           | expr '+' expr                  { $$ = printf("Suma %f + %f\n",$1,$3);  }
           | expr '*' expr                  { $$ = printf("Multiplicación %f * %f\n",$1,$3);  }
           | expr '/' expr                  { $$ = printf("División %f / %f\n",$1,$3);  }
           | expr '%' expr                  { $$ = printf("Modulo %f  %f\n",$1,$3);  }
           | '-' expr %prec UMINUS          { $$ = printf("Número negativo %f\n",$2);  }
           | PRINT '('  ',' expr ')'  { $$ = printf("Función print %s",$4);  }
           | expr COMPARE expr              { $$ = printf("Símbolo comparación %f %i %f\n",$1,$2,$3);   }
           | NAME '(' parameter_to_funct ')'{ $$ = printf("Llamada a función %s\n",$1);  }
           | CHAR                           { $$ = printf("Char %c\n",$1);  }
           | STRING                         { $$ = printf("String %s\n",$1);  }
           | INTEGER                        { $$ = printf("Integer %i\n",$1); }
           | FLOAT                          { $$ = printf("Float %f\n",$1);  }
           ;


%%

int main(int argc, char** argv) {
  if (argc>1) yyin=fopen(argv[1],"r");
  yyparse();
}

void yyerror(char* mens) {
  printf("Error en linea: %s \n", mens);
}