#include <coprocessor.h>

const int8_t SOBEL_X[25] = {
     0,  0,  0,  0,  0,
     0, -1,  0,  1,  0,
     0, -2,  0,  2,  0,
     0, -1,  0,  1,  0,
     0,  0,  0,  0,  0
};

const int8_t SOBEL_Y[25] = {
     0,  0,   0,  0,  0,
     0, -1,  -2, -1,  0,
     0,  0,   0,  0,  0,
     0,  1,   2,  1,  0,
     0,  0,   0,  0,  0
};

int main(){
    // declaração de variáveis
    int opcode, i;
    int8_t img[76800];
    int8_t img_section[25];
    int8_t novoElemento;

    // envia para operação de convolução
    operate_buffer_send(opcode, 3, 0, img_section, SOBEL_X, SOBEL_Y, &novoElemento);

    return 0;
}