# Makefile basico para no repETIR comandos para generar,


# make milex	[genera] lexico desde milex.l
# make F=n.x	[genera] y ejecuta lexico sobre n.x; via stdin: make<n.x

#F is a test file
F=lake_pruebaDef.lke 

all: lexLake $(F)
	./lexLake $(F)

bison:
	bison -d -t bisonLake1.y

flex:
	flex lexLake.l

delete: 
	rm -f lex.yy.c milex y.tab.* bisonLake1.tab.* output

exec: 
	gcc -g lex.yy.c bisonLake1.tab.c ../tabla_simbolos/ast.c ../tabla_simbolos/eval.c ../tabla_simbolos/symbolTable.c ../tabla_simbolos/errorException.c -o output -lfl

run: delete bison milex exec

test:	
	./output $(F)

debug:
	gdb --args ./output $(F) core

# "No rule to make target" T si no encuentra ni puede crear T.
# Por supuesto, no regenera milex si no es necesario.
