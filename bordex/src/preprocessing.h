// preprocessing.h
#ifndef PREPROCESSING_H
#define PREPROCESSING_H

#include <stdint.h>

// define struct de erros
typedef struct {
    int codigo;
    char mensagem[100];
    time_t timestamp;
} Erro;

void registrarErro(Erro erro);

int preprocess(char* nomeImg, int8_t** pixels, unsigned char** cabec, int* offsetOut, int* rowSizeOut);

#endif
