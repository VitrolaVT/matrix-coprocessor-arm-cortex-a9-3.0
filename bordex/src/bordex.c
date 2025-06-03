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

    // declaração de espaços para os pixels da imagem e cabeçalho para o retorno
    int8_t* dadosPixels = NULL;
    unsigned char* dadosCabec = NULL;

    // pega a imagem e realiza preprocessamento
    preprocess ("1", &dadosPixels, &dadosCabec); // 1.bmp é o nome da imagem

    // itera por todos os pixels
    for(i = 0; i < 9600; i++){
        img[i] = dadosPixels[i];
    }

    // envia para operação de convolução
    operate_buffer_send(opcode, 3, 0, img_section, SOBEL_X, SOBEL_Y, &novoElemento);

    // libera memória para dadosPixels e cabec
    free (dadosPixels);
    free (dadosCabec);

    return 0;
}