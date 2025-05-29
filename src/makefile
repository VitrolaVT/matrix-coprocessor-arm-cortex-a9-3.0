help:
	@echo help: exibe essa ajuda
	@echo compile: compila o codigo
	@echo run: executa o codigo
	@echo clean: limpa a pasta

compile:
	@as -c lib/matriksLib.s -o lib/matriks.o && gcc -c lib/functions.c -o lib/functions.o -I./lib && gcc -c main.c -o main.o -I./lib && gcc main.o lib/functions.o lib/matriks.o -o main

run:
	@sudo ./main

debug:
	@sudo gdb ./main

clean:
	@rm -f lib/matriksLib.o lib/functions.o main.o main.dump main