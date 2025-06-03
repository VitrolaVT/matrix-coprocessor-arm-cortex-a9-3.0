#ifndef coprocessor_h
#define coprocessor_h
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

// definição das operações load e store
#define storeMatrixA 0b0111
#define storeMatrixB 0b1000
#define loadMatrixResult 0b1001

// definição dos tamanhos
#define M2 0b00
#define M3 0b01
#define M4 0b10
#define M5 0b11

// definição das operações
#define SOM 0b000
#define SUB 0b001
#define MULM 0b010
#define MULI 0b011
#define DET 0b100
#define TRANS 0b101
#define OPP 0b110
#define CONV 0b111

// protótipo das funções de interface
void start_program(void);

int operate_buffer_receive(int opcode, int size, int position, int8_t* matrizA, int8_t* matrizB, int8_t* matrizC, uint8_t* matrizres);

int calculate_matriz(int opcode, int size, int position);

int operate_buffer_send(int opcode, int size, int position, int8_t* matriz);

int signal_overflow(void);

void exit_program(void);

// protótipo das funções do coprocessador
void soma(int8_t* matrizA, int8_t* matrizB, int8_t* res);
void subt(int8_t* matrizA, int8_t* matrizB, int8_t* res);
void multm(int8_t* matrizA, int8_t* matrizB, int8_t* res);
void multi(int8_t* matrizA, int8_t* matrizB, int8_t* res);
void detm(int8_t* matrizA, int size, int8_t* res);
void transm(int8_t* matrizA, int8_t* res);
void oppm(int8_t* matrizA, int8_t* res);
void conv(int8_t* matrizA, int8_t* matrizB, int8_t* matrizC, uint8_t* res);

// operações intermediárias
int8_t multConv(int8_t* matrizA, int8_t* matrizB, int8_t* res);

#endif