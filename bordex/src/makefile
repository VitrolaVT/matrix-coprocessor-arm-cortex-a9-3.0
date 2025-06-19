help:
	@echo help: exibe essa ajuda
	@echo compile: compila o codigo
	@echo run: executa o codigo
	@echo clean: limpa a pasta
	@echo derun: faz tudo de vez

compile:
	@as -c lib/matriksLib.s -o lib/matriks.o 
	@gcc std=c99 -c preprocessing.c -o preprocessing.o
	@gcc std=c99 -c bordex.c -o main.o -I./lib 
	@gcc main.o preprocessing.o lib/matriks.o -o main
run:
	@sudo .\main

clean:
	@rm -f lib/matriksLib.o lib/bordex.o main.o main.dump main preprocessing.o

derun:
	@rm -f lib/matriksLib.o lib/bordex.o main.o main.dump main preprocessing.o
	@as -c lib/matriksLib.s -o lib/matriks.o
	@gcc -c bordex2.c -o main.o -I./lib -std=c99 -lm
	@gcc main.o lib/matriks.o -o main -std=c99 -lm
	@sudo ./main