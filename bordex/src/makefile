help:
	@echo help: exibe essa ajuda
	@echo compile: compila o codigo
	@echo run: executa o codigo
	@echo clean: limpa a pasta
	@echo derun: faz tudo de vez

compile:
	@rm -f lib/matriksLib.o lib/bordex.o main.o main.dump main preprocessing.o
	@as -c lib/matriksLib.s -o lib/matriks.o
	@gcc -c bordex.c -o main.o -I./lib -std=c99 -lm
	@gcc main.o lib/matriks.o -o main -std=c99 -lm
run:
	@sudo ./main

clean:
	@rm -f lib/matriksLib.o lib/bordex.o main.o main.dump main ../img/output/preprocessed.bmp ../img/output/sobel.bmp

derun:
	@rm -f lib/matriksLib.o lib/bordex.o main.o main.dump main ../img/output/preprocessed.bmp ../img/output/sobel.bmp
	@as -c lib/matriksLib.s -o lib/matriks.o
	@gcc -c bordex.c -o main.o -I./lib -std=c99 -lm
	@gcc main.o lib/matriks.o -o main -std=c99 -lm
	@sudo ./main