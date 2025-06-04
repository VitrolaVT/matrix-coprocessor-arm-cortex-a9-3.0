#include "coprocessor.h"
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "preprocessing.h"
#include <time.h>

#define WIDTH 320
#define HEIGHT 240

int main(){
    // declaração de variáveis
    int opcode, i, linha, coluna,
    linha_central, coluna_central, 
    linha_offset, linha_vizinha, coluna_offset, 
    coluna_vizinha, indiceVizinho, posicaoNaJanela;
    int8_t img[WIDTH * HEIGHT];
    uint8_t finalImg[WIDTH * HEIGHT];
    int8_t img_section[25];
    uint8_t novoElemento;

    // declaração dos filtros
    int8_t SOBEL_X[25] = {
     0,  0,  0,  0,  0,
     0, -1,  0,  1,  0,
     0, -2,  0,  2,  0,
     0, -1,  0,  1,  0,
     0,  0,  0,  0,  0
    };

    int8_t SOBEL_Y[25] = {
        0,  0,   0,  0,  0,
        0, -1,  -2, -1,  0,
        0,  0,   0,  0,  0,
        0,  1,   2,  1,  0,
        0,  0,   0,  0,  0
    };

    // declaração de espaços para os pixels da imagem e cabeçalho para o retorno
    int8_t* dadosPixels;
    unsigned char* dadosCabec;
    int offset;
    int rowSize;
    dadosPixels = NULL;
    dadosCabec = NULL;

    // pega a imagem e realiza preprocessamento
    preprocess ("1", &dadosPixels, &dadosCabec, &offset, &rowSize); // 1.bmp é o nome da imagem

    if(dadosPixels == NULL){
        Erro erro9 = {
            .codigo = 9,
            .mensagem = "Pré-processamento falhou. Dados da imagem não obtidos.",
            .timestamp = time(NULL)
        };
        registrarErro(erro9);
        return 1;
    }

    else if(dadosCabec == NULL){
        Erro erro10 = {
            .codigo = 10,
            .mensagem = "Pré-processamento falhou. Dados do cabeçalho não obtidos.",
            .timestamp = time(NULL)
        };
        registrarErro(erro10);
        return 1;
    }

    // itera por todos os pixels
    //for(i = 0; i < WIDTH * HEIGHT; i++){
    //    img[i] = dadosPixels[i];
    //}
    // bytesPixel é implicitamente 3 para uma imagem de 24 bits.
    int bytesPerPixel_original = 3; // Para imagem de 24 bits
    int current_pixel_img = 0;
    for (linha = 0; linha < HEIGHT; linha++) {
        for (coluna = 0; coluna < WIDTH; coluna++) {
            // calcula o índice do componente Azul (primeiro byte) do pixel em dadosPixels
            int index_in_dadosPixels = linha * rowSize + coluna * bytesPerPixel_original;

            // verifica se o índice está dentro dos limites de dadosPixels
            // (rowSize * HEIGHT) é o tamanho total de dadosPixels
            if (index_in_dadosPixels < (rowSize * HEIGHT)) {
                 // o valor em dadosPixels é unsigned char (0-255) a img, int8_t
                img[current_pixel_img] = dadosPixels[index_in_dadosPixels];
            } else {
                // se indice fora dos limites, preenche com 0 (just in case ne)
                img[current_pixel_img] = 0;
            }
            current_pixel_img++;
        }
    }

    opcode = CONV;
    
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
        operate_buffer_receive(opcode, 3, 0, img_section, SOBEL_X, SOBEL_Y, &novoElemento);
        finalImg[i] = novoElemento;
    }

    // cria arquivo de saída
    FILE* saida;

    saida = fopen("../img/output/sobel.bmp", "wb");

    // salva imagem com filtro
    // cabeçalho
    fwrite(dadosCabec, sizeof(unsigned char), (offset), saida);
    
    // novo código que coloca imagem com filtro no arquivo
    // alocando uma imagem temporária de 24 bits para escrita
    uint8_t* output_24bit_img = malloc((rowSize) * HEIGHT);
    if (output_24bit_img == NULL) {
        Erro erro_mem = {
            .codigo = 11,
            .mensagem = "Falha na alocação de memória para imagem temporária de saída.",
            .timestamp = time(NULL)
        };
        registrarErro(erro_mem);
        free(dadosPixels);
        free(dadosCabec);
        return 1;
    }

    // convertendo a imagem de 8 bits (finalImg) para 24 bits (output_24bit_img) e lidando com o padding de linha
    for (linha = 0; linha < HEIGHT; linha++) {
        for (coluna = 0; coluna < WIDTH; coluna++) {
            uint8_t pixel_val = finalImg[linha * WIDTH + coluna];
            output_24bit_img[linha * (rowSize) + coluna * 3 + 0] = pixel_val; // Blue
            output_24bit_img[linha * (rowSize) + coluna * 3 + 1] = pixel_val; // Green
            output_24bit_img[linha * (rowSize) + coluna * 3 + 2] = pixel_val; // Red
        }
        // adiciona padding, se houver
        for (int p = WIDTH * 3; p < (rowSize); p++) {
            output_24bit_img[linha * (rowSize) + p] = 0;
        }
    }

    // finalImg já tá em ordem bottom-up!! então não precisa inverter, só passar direto
    fwrite(output_24bit_img, sizeof(unsigned char), (rowSize) * HEIGHT, saida);

    // libera memória para dadosPixels e cabec
    free (dadosPixels);
    free (dadosCabec);

    return 0;
}