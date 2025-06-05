compile:
	@as -c lib/matriksLib.s -o lib/matriks.o && gcc -c lib/functions.c -o lib/functions.o && gcc -c main.c -o main.o && gcc main.o lib/functions.o lib/matriks.o -o main

run:
	@sudo ./main