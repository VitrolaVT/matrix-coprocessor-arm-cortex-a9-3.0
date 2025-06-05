#ifndef functions_h
#define functions_h

// definição das operações (IS - instruction set)
#define SOM 0b0000
#define SUB 0b0001
#define MULM 0b0010
#define MULI 0b0011
#define DET 0b0100
#define TRANS 0b0101
#define OPP 0b110

// definição das operações load e store
#define storeMatrixA 0b0111
#define storeMatrixB 0b1000
#define loadMatrixResult 0b1001

// definição das operações de convolução
#define CONV_TRANS 0b1010
#define CONV_ROBERTS 0b1011

// definição de constantes
#define pos 0

// protótipo das funções
void showMenu();
void clean();
void menuOperation(uint8_t* matrixA, uint8_t* matrixB, uint8_t* result);
void printarMatriz(uint8_t* matriz, int size);

#endif