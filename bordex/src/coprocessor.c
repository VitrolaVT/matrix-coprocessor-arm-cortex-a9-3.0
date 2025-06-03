#include "coprocessor.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

int operate_buffer_receive(int opcode, int size, int position, int8_t* matrizA, int8_t* matrizB, int8_t* matrizC, uint8_t* matrizres){
    int i;
    int8_t mA[25];
    int8_t mB[25];
    int8_t mC[25];

    for (i = 0; i < 13; i++){
        mA[i] = matrizA[i];
        mB[i] = matrizB[i];
        mC[i] = matrizC[i];

        switch (opcode){
            case (CONV):
                conv(matrizA, matrizB, matrizC, matrizres);
                break;
        }
    }
}

void soma(int8_t* matrizA, int8_t* matrizB, int8_t* res){
    int i;
    for (i = 0; i < 25; i++){
        res[i] = matrizA[i] + matrizB[i];
    }
}

void subt(int8_t* matrizA, int8_t* matrizB, int8_t* res){
    int i;
    for (i = 0; i < 25; i++){
        res[i] = matrizA[i] - matrizB[i];
    }
}

void multm(int8_t* matrizA, int8_t* matrizB, int8_t* res){

}

void multi(int8_t* matrizA, int8_t* matrizB, int8_t* res){

}

void detm(int8_t* matrizA, int size, int8_t* res){

}

void transm(int8_t* matrizA, int8_t* res){

}

void oppm(int8_t* matrizA, int8_t* res){

}

// função que realiza a operação de convolução e retorna o elemento correspondente
void conv(int8_t* matrizA, int8_t* filtroX, int8_t* filtroY, uint8_t* res){
    // definição de variáveis
    int soma_X, soma_Y, i, elemento;

    // aloca espaço para matrizes temporárias
    int8_t tempMX[25];
    int8_t tempMY[25];

    // inicializa res com 0s
    (*res) = (uint8_t)0;

    // realiza produto e soma
    multConv(matrizA, filtroX, tempMX);
    multConv(matrizA, filtroY, tempMY);

    soma_X = soma_Y = 0;
    
    for(i = 0; i < 25; i++){
        soma_X += tempMX[i];
        soma_Y += tempMY[i];
    }

    // realiza operação de módulo
    elemento = round(sqrt(pow(soma_X, 2) + pow(soma_Y, 2)));

    // se maior que 255, satura
    if (elemento > 255){
        elemento = 255;
    }

    // casta o valor pra unsigned (nn importa ser signed)
    (*res) = (uint8_t)elemento;
}

int8_t multConv(int8_t* matrizA, int8_t* matrizB, int8_t* res){
    int i;
    // multiplica cada elemento pelo elemento da matrizB correspondente (filtro) com saturação
    for (i=0; i<25; i++){
        res[i] = (matrizA[i] * matrizB[i]);

        if (res[i] > 127) {
            res[i] = (int8_t)(127);            
        }
        else if (res[i] < - 128){
            res[i] = (int8_t)(-128);
        }
    }
}