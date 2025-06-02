#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include "matriksLib.h"
#include "functions.h"


void showMenu(){
    // Aloca espaço para opcao
    char* option;
    option = (char *)calloc(1, sizeof(char));

    // Aloca espaço para matrizes
    int8_t* matrixA;
    int8_t* matrixB;
    int8_t* result;
    matrixA = (int8_t *)calloc(25, sizeof(int8_t));
    matrixB = (int8_t *)calloc(25, sizeof(int8_t));
    result = (int8_t *)calloc(25, sizeof(int8_t));
    
    while(1){
        printf("                ___  ___   __  __         _          _  _           ___  ___\n");
        usleep(250000);
        printf("               |  _||  _| |  \\/  |       | |        (_)| |         |_  ||_  |\n");
        usleep(250000);
        printf("               | |  | |   | \\  / |  __ _ | |_  _ __  _ | | __ ___    | |  | |\n");
        usleep(250000);
        printf("               | |  | |   | |\\/| | / _` || __|| '__|| || |/ // __|   | |  | |\n");
        usleep(250000);
        printf("               | |  | |   | |  | || (_| || |_ | |   | ||   < \\__ \\   | |  | |\n");
        usleep(250000);
        printf("               | |_ | |_  |_|  |_| \\__,_| \\__||_|   |_||_|\\_\\|___/  _| | _| |\n");
        usleep(250000);
        printf("               |___||___|                                          |___||___|\n");
        usleep(250000);
        printf("++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n");
        usleep(1000000);
        printf("Seja bem vindo(a) à biblioteca Matriks.\n");
        usleep(250000);
        printf("Para realizar operações com matrizes nxn, n<=5, prossiga.\n");
        printf("\n");
        usleep(250000);
        printf("(1) - Realizar operação");
        printf("\n(2) - Sair");
        printf("\n");
        printf("\nDigite uma opção: ");
        scanf("%c", option);
            
        
        switch (*option){
            case '1': 
                    clean();
                    start_program();
                    menuOperation(matrixA, matrixB, result);
                    break;            
            case '2': 
                    exit(0);
                    break;
            default: 
                    printf("\n Opção inválida.\n");
                    clean();
        }
    }
}

void menuOperation(int8_t* matrixA, int8_t* matrixB, int8_t* result){
    int qty; // variável guarda se op precisa de 2 ou 1 matriz
    int size;
    int option2;
    int i,j; // iteradores
    int opcode;
    int8_t* tempM;
    tempM = (int8_t *)calloc(25, sizeof(int8_t));
    int flagOK1, flagOK2, flagResult;
    int8_t* temp_pos; // Ponteiro que indica endereço atual do conjunto de números carregados

    printf("\n\nOperações:\n\n(1) Soma\n(2) Subtração\n(3) Multiplicação de matrizes\n(4) Multiplicação por inteiro\n(5) Determinante\n(6) Transposta\n(7) Oposta\n");
    printf("\nDigite uma opção: ");
    scanf("%d", &option2);

    qty = (option2 > 4) ? 1 : 2; // verifica qtd de matrizes
    
    switch (option2){
        case 1: 
                opcode = SOM;
                break;
        case 2: 
                opcode = SUB;
                break;
        case 3: 
                opcode = MULM;
                break;
        case 4: 
                opcode = MULI;
                break;
        case 5: 
                opcode = DET;
                break;
        case 6: 
                opcode = TRANS;
                break;
        case 7: 
                opcode = OPP;
                break;
        default:
                printf("Erro de opcode\n");
                exit(0);
    }

    // DEFINIR LÓGICA PARA OPCODE = CONSTANTES

    printf("\nTamanhos: \n");
    for (i=0;i<4;i++){
        printf("(%d) Matriz %dx%d \n", (i+2), (i+2), (i+2));
    }

    printf("\nQual o tamanho da matriz?: ");
    scanf("%d", &size);

    printf("\nDigite a(s) matriz(es) em ordem de M[i,j].\n\n");

    // recebe input da matriz A
    for(i = 0; i < (size*size); i++){
        printf("matrizA[%d][%d]: ", (i/size), (i%size)); // printa a posição do elemento
        scanf("%hhd", &(tempM[i]));
    }

    // passa para matriz A
    for (i = 0; i < 5; i++) {
        for (j = 0; j < 5; j++) {
            if (i < size && j < size) {
                // copia os valores da matriz original
                matrixA[i*5 + j] = tempM[i*size + j];
            } else {
                // preenche com zeros
                matrixA[i*5 + j] = 0;
            }
        }
    }

    // recebe o input da matriz B ou de número
    if((option2) == 4){
        printf("\n Digite o número: ");
        scanf("%hhd", &(matrixB[0]));
        // preenche restante com zeros
        for (i = 1; i < 25; i++){
            matrixB[i] = 0;
        }
    }
    // se qualquer operação com 2 matrizes, passa para matriz B
    else if (qty == 2){
        for(i = 0; i < (size*size); i++){
        printf("matrizB[%d][%d]: ", (i/size), (i%size)); // printa a posição do elemento
        scanf("%hhd", &(tempM[i]));
        }

        // passa para matriz B
        for (i = 0; i < 5; i++) {
            for (j = 0; j < 5; j++) {
                if (i < size && j < size) {
                    // copia os valores da matriz original
                    matrixB[i*5 + j] = tempM[i*size + j];
                } else {
                    // preenche com zeros
                    matrixB[i*5 + j] = 0;
                }
            }
        }
    }

    flagOK1 = 0;
    flagOK2 = 0;

    // envia os dados com o opcode
    temp_pos = matrixA;
    for (i=0;i<13;i++){
        flagOK1 = operate_buffer_send(storeMatrixA, (size-2), i, temp_pos);
        temp_pos += 2;
    }

    if (qty == 2){
        temp_pos = matrixB;
            for (i=0;i<13;i++){
            flagOK2 = operate_buffer_send(storeMatrixB, (size-2), i, temp_pos);
            temp_pos += 2;
            }
    }else {flagOK2 = 1;}
    
    
    // envia operação
    if (flagOK1 && flagOK2){ // verifica 
        calculate_matriz(opcode, (size-2), 0); // envia sinal para iniciar op

        temp_pos = result; //

        for (i=0;i<7;i++){
            flagResult = operate_buffer_receive(loadMatrixResult, (size-2), i, temp_pos);
            temp_pos += 4;
        }
        
    }
    
    if (flagResult) printarMatriz(result, matrixA, matrixB, size, opcode, qty);

    printf("\nDeseja continuar?");
    printf("\n(1) Sim\n(0) Não\n");
    scanf("%d", &option2);
    if(!option2){exit(0);}

}

void printarMatriz(int8_t* matriz, int8_t* matrizA, int8_t* matrizB, int size, int opcode, int qty){ 
    int i, indice, linha, coluna;

    printf("\n\nMatrizA: \n");
    //For para printar Matriz A 
    for (linha = 0; linha < size; linha++) {
        for (coluna = 0; coluna < size; coluna++) {
            // calcula o índice na matriz 5x5
            indice = linha * 5 + coluna;
            printf("    %3d    ", matrizA[indice]);
        }
        printf("\n"); // Nova linha após cada linha da matriz
    }

    //Verifica se é necessário printar Matriz B ou Escalar
    if (qty == 2){
        if (opcode == MULI){
            printf("\n\nEscalar: \n%d\n", matrizB[0]);
        }
        else {
            printf("\n\nMatrizB: \n");

            for (linha = 0; linha < size; linha++) {
                for (coluna = 0; coluna < size; coluna++) {
                    // calcula o índice na matriz 5x5
                    indice = linha * 5 + coluna;
                    printf("    %3d    ", matrizB[indice]);
                }
                printf("\n"); // Nova linha após cada linha da matriz
            }
        }
    }

    printf("\n\nResultante: \n");

    if (opcode == DET){ // determinante
        printf("    %3d    ", matriz[0]);
    } else{
        for (linha = 0; linha < size; linha++) {
            for (coluna = 0; coluna < size; coluna++) {
                // calcula o índice na matriz 5x5
                indice = linha * 5 + coluna;
                printf("    %3d    ", matriz[indice]);
            }
            printf("\n"); // Nova linha após cada linha da matriz
        }
        
    }

    printf("\n\nOverflow: \n%d\n", signal_overflow());

    //
}

void clean(){
    system("clear");
}