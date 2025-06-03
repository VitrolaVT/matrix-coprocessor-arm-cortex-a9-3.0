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

#define WIDTH 320
#define HEIGHT 240

int main(){
    // declaração de variáveis
    int opcode, i, linha, coluna,
    linha_central, coluna_central, 
    linha_offset, linha_vizinha, coluna_offset, 
    coluna_vizinha, indiceVizinho, posicaoNaJanela;
    int8_t img[WIDTH * HEIGHT];
    int8_t finalImg[WIDTH * HEIGHT];
    int8_t img_section[25];
    int8_t novoElemento;

    // declaração de espaços para os pixels da imagem e cabeçalho para o retorno
    int8_t* dadosPixels;
    unsigned char* dadosCabec;
    int* offset;
    int* rowSize;
    dadosPixels = NULL;
    dadosCabec = NULL;
    offset = NULL;

    // pega a imagem e realiza preprocessamento
    preprocess ("1", &dadosPixels, &dadosCabec, &offset, &rowSize); // 1.bmp é o nome da imagem

    // itera por todos os pixels
    for(i = 0; i < WIDTH * HEIGHT; i++){
        img[i] = dadosPixels[i];
    }
    
    for (i = 0; i < WIDTH * HEIGHT; i++) {
        // envia pequenas seções de 5x5 para utilizar o filtro
        linha_central = i / WIDTH;
        coluna_central = i % WIDTH;

        posicaoNaJanela = 0;

        // percorre as 5 linhas da janela
        for (linha_offset = -2; linha_offset <= 2; linha_offset++) {
            linha_vizinha = linha_central + linha_offset;

            // percorre as 5 colunas da janela
            for (coluna_offset = -2; coluna_offset <= 2; coluna_offset++) {
                coluna_vizinha = coluna_central + coluna_offset;

                // verifica se a posição vizinha tá dentro da imagem
                if (linha_vizinha >= 0 && linha_vizinha < HEIGHT &&
                    coluna_vizinha >= 0 && coluna_vizinha < WIDTH) {
                    
                    // converte o indice para o array unidim ao inves de considerar uma matriz
                    indiceVizinho = linha_vizinha * WIDTH + coluna_vizinha;
                    img_section[posicaoNaJanela] = img[indiceVizinho];
                } else {
                    // se for fora da imagem, preenche com 0
                    img_section[posicaoNaJanela] = 0;
                }

                posicaoNaJanela++;
            }
        }

        // envia para operação de convolução
        operate_buffer_send(opcode, 3, 0, img_section, SOBEL_X, SOBEL_Y, &novoElemento);
        finalImg[i] = novoElemento;
    }

    // cria arquivo de saída
    FILE* saida;

    saida = fopen("bordex/img/output/filtro1.bmp", "wb");

    // salva imagem com filtro
    // cabeçalho
    fwrite(dadosCabec, sizeof(unsigned char), offset, saida);

    for (i = 0; i < HEIGHT; i++) {
        memcpy(&finalImg[i * (*rowSize)], &finalImg[(HEIGHT - 1 - i) * (*rowSize)], (*rowSize));
    }
    fwrite(finalImg, sizeof(unsigned char), (*rowSize)*HEIGHT, saida);

    // libera memória para dadosPixels e cabec
    free (dadosPixels);
    free (dadosCabec);

    return 0;
}