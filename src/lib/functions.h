#ifndef functions_h
#define functions_h
#include <stdint.h>

// definição das operações load e store
#define storeMatrixA 0b0111
#define storeMatrixB 0b1000
#define loadMatrixResult 0b1001

// definição das operações (IS - instruction set)
#define SOM 0b000
#define SUB 0b001
#define MULM 0b010
#define MULI 0b011
#define DET 0b100
#define TRANS 0b101
#define OPP 0b110

// protótipo das funções
void showMenu();
void clean();
void menuOperation(int8_t* matrixA, int8_t* matrixB, int8_t* result);
void printarMatriz(int8_t* matriz, int8_t* matrizA, int8_t* matrizB, int size, int opcode, int qty);

#endif