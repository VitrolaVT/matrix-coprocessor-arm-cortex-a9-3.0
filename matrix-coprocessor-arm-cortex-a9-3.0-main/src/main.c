/*
            Para compilar e rodar corretamente, é necessário utilizar as seguintes linhas no terminal, com o makefile:
                make compile
                make run

            A primeira linha compila o programa, já a segunda, executa

            Para compilar e montar separadamente assembly e código C, siga os seguintes passos:
                as -c lib/matriksLib.s -o lib/matriksLib.o  [MONTA O ASSEMBLY]
                gcc -c lib/functions.c -o lib/functions.o -I./lib [COMPILA O FUNCTIONS]
                gcc -c main.c -o main.o -I./lib [COMPILA A MAIN]
                gcc main.o lib/functions.o lib/matriksLib.o -o main [LINKA TUDO]
                sudo ./main [RODA A MAIN]
*/
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include "lib/matriksLib.h"
#include "lib/functions.h"


int main(){
    showMenu();
    return 0;
}
