help:
	@echo help: exibe essa ajuda
	@echo compile: compila o codigo
	@echo run: executa o codigo
	@echo clean: limpa a pasta

compile:
	@gcc -m64 -c coprocessor.c -o coprocessor.o
	@gcc -m64 -c preprocessing.c -o preprocessing.o
	@gcc -m64 -c bordex.c -o bordex.o
	@gcc -m64 -mconsole bordex.o coprocessor.o preprocessing.o -o main
run:
	@./main

debug:
	@./main

clean:
	@del /Q *.o *.exe

derun:
	@del /Q *.o *.exe
	@gcc -m64 -c coprocessor.c -o coprocessor.o
	@gcc -m64 -c preprocessing.c -o preprocessing.o
	@gcc -m64 -c bordex.c -o bordex.o
	@gcc -m64 -mconsole bordex.o coprocessor.o preprocessing.o -o main
	@ 
	@.\main