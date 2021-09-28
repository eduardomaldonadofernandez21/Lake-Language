%{
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "bisonPrint.tab.h"
int numlin = 1;
char *substr(char *src, int m, int  n);
%}

DIGITO		    [0-9]
LETRA		    [a-zA-Z]
ESPACIO         [" "]
NOMBRE  {LETRA}+({DIGITO}|{LETRA})*
CHAR_LETRA      (\"[^\"]\")
CHAR_COMA       [","]
CHAR_PUNTO      ["."]
CHAR_PUNTOYCOMA [";"]
CHAR_DOSPUNTOS  [":"]

CONST_INTEGER   (-?[1-9][0-9]{0,4})|0
CONST_FLOAT     {DIGITO}{0,8}{CHAR_PUNTO}{DIGITO}{1,8}
/* La regex de abajo considera String a todo lo que este dentro de las comillas dobles excepto al EOF y la propia comilla doble */
CONST_CADENA    (\"[^\"]*\")    

/* Operadores lógicos y operadores aritméticos básicos*/
OP_SUMA         "+"
OP_RESTA        "-" 
OP_MULT         "*"
OP_DIV          "/" 
OP_IGUAL        "=" 
OP_MAYOR        ">"                     
OP_MENOR        "<"     
OP_MOD          "%"               
OP_NEGACION     "!"   
OP_DISTINTO     "!="          
OP_COMP_IGUAL   "=="                    
OP_MAYORIGUAL   ">="                 
OP_MENORIGUAL   "<="

/* Tiene doble funcionalidad, definir un tipo de datos o asignar un valor */
OP_DOSPUNTOS        ":"

/* Caracteres de apertura, cierre y fin de linea */
LLAVE_ABRIR         "{"
LLAVE_CERRAR        "}"
PARENTESIS_ABRIR    "("
PARENTESIS_CERRAR   ")"
FIN_SENTENCIA       ";"
CORCHETE_ABRIR      "["
CORCHETE_CERRAR     "]"

/* Estructuras del lenguaje y palabras reservadas */
IF      "IF"
WHILE   "WHILE"
BREAK   "BREAK"
ELSE    "ELSE"
FOR     "FOR"
AND     "AND"
OR      "OR"
FLOAT   "Float"
LONG    "Long"
INTEGER "Int"
FUNCT   "funct"
RETURN  "return"
CHAR    "Char"
STRING 	"String"
BOOLEAN "Boolean"
PRINT   "print"


/* SECCION REGLAS (Patrón y acción semántica  (Bloque de codigo que se ejecuta al detectar el patron) */
/* Es importante el orden, se va ejecutando en orden secuencial la acción cuando encuentra el patrón correspondiente */
/* Ej: Si pongo la regla del FLOAT primero no va  llegar a las reglas de palabras reservadas */
%%
OP_SUMA 			    |
OP_RESTA 		    	|
OP_MULT				    |
OP_DIV				    |
OP_MOD				    |	
OP_IGUAL 			    |
OP_DOSPUNTOS 		  |
PARENTESIS_ABRIR	|   
PARENTESIS_CERRAR	|
CORCHETE_ABRIR    |
CORCHETE_CERRAR		|
LLAVE_ABRIR       |
LLAVE_CERRAR      |
CHAR_COMA			    |
FIN_SENTENCIA				  { return yytext[0]; }

OP_MAYOR       				  { yylval.compare = 1; return COMPARE; }                    
OP_MENOR   					  { yylval.compare = 2; return COMPARE; }
OP_MAYORIGUAL				  { yylval.compare = 3; return COMPARE; }
OP_MENORIGUAL				  { yylval.compare = 4; return COMPARE; }
OP_COMP_IGUAL			      { yylval.compare = 5; return COMPARE; }
OP_DISTINTO					  { yylval.compare = 6; return COMPARE; }
OP_NEGACION					  { yylval.compare = 7; return COMPARE; }

INTEGER						  { yylval.type = 1; return TYPE; }			
LONG                          { yylval.type = 2; return TYPE; }
FLOAT  						  { yylval.type = 3; return TYPE; }
BOOLEAN                       { yylval.type = 4; return TYPE; }
STRING 					      { yylval.type = 5; return TYPE; }

IF							  { return IF;}
ELSE					      { return ELSE;}	
WHILE						  { return WHILE;}
BREAK						  { return BREAK;}

FUNCT   					  { return FUNCT;}
RETURN   					  { return RETURN;}
PRINT   					  { return PRINT;}


{NOMBRE}				  { yylval.name = substr(yytext, 0, yyleng); return NAME; }
{CHAR_LETRA}					  { yylval.string = substr(yytext, 1, yyleng-1); return CHAR; }			  
{CONST_CADENA}				  { yylval.string = substr(yytext, 1, yyleng-1); return STRING; }
{CONST_INTEGER}					   { yylval.integer = atoi(yytext); return INTEGER; }
{CONST_FLOAT}					   { yylval.real = atof(yytext); return FLOAT;}


[ \t\r]
\n        {numlin++; return EOL; } 
.         {yyerror("Existe un error léxico"); }
%%

char *substr (char *src, int n, int m) {
    
    int len = m - n;

    char *dest = (char *)malloc(sizeof(char) * (len + 1));

    for (int i = n; i < m && (*(src + i) != '\0'); i++)
    {
        *dest = *(src + i);
        dest++;
    }

    *dest = '\0';

    return dest - len;
}