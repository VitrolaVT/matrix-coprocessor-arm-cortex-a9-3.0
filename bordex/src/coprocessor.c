#include <coprocessor.h>
#include <stdlib.h>
#include <stdio.h>

int main(){
    
    return 0;
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