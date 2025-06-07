// código refatorado, a começar por uma struct para imagem
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include "matriksLib.h"
#include <math.h> // necessario pro calculo de matrizes

#define storeMatrixA 0b0111
#define storeMatrixB 0b1000
#define loadMatrixResult 0b1001
#define CONV 0b1010
#define ROB 0b1011
#define LAP 0b1100

#define WIDTH 320
#define HEIGHT 240

// define a struct para imagem
typedef struct{
    int width; // pixels da largura
    int height; // pixels da altura
    int depth; // profundidade (bits) de cada pixel
    int offset;
    int size;
    int rowSize;
    unsigned char* header;
    unsigned char* data;
}img;

// img bmp para preto e branco
void preprocess(char* nomeImg, img* rowSizeOut);
// salva bmp
void saveImg(char* fileName, img* img);
// funções para aplicação do filtro
void sobel3(img* img);
void sobel5(img* img);
void prewitt(img* img);
void laplacian(img* img);
void roberts(img* img);

int main(){
    start_program(); // mapeia memória
    
    // pré-processamento do arquivo
    // cria imagem
    img img;
    preprocess("1", &img);
    saveImg("preprocessed", &img);
    sobel3(&img);
    saveImg("sobel3", &img);
    
    return 0;
}

// função para o preprocessamento
void preprocess(char* nomeImg, img* image){
    FILE* sample; // ponteiro para os dados do arquivo
    // primeiro, abre o arquivo em sample
    const char* prefixo = "../img/sample/";
    const char* sufixo = ".bmp";
    char caminho[150];

    // pega o nome do arquivo com base no argumento
    snprintf(caminho, sizeof(caminho), "%s%s%s", prefixo, nomeImg, sufixo);
    sample = fopen(caminho, "rb");

    // informações da imagem
    unsigned char tempHeader[14]; // 14 primeiros bytes
    unsigned char* header;
    unsigned char* imageData;
    unsigned char* invertedData;
    unsigned char* r;
    unsigned char* g;
    unsigned char* b;
    int i, j, width, height, offset, rowSize, bytesPixel, imgSize, line, position, mean, row;
    unsigned short depth;
    unsigned int compression;
    long file_size;

    // leitura do arquivo para pegar o offset
    fread(tempHeader, sizeof(unsigned char), 14, sample);

    // verifica se sample é bmp
    if(tempHeader[0] != 'B' || tempHeader[1] != 'M') {
        printf("ERRO 1: Arquivo não é BMP.");}

    // pega o valor do offset (dos valores da imagem)
    memcpy(&offset, &tempHeader[10], sizeof(int));

    // salva o cabeçalho (tudo antes dos dados)
    header = malloc(offset * sizeof(unsigned char));
    fseek(sample, 0, SEEK_SET); // define inicio do arquivo a partir do offset
    fread(header, sizeof(unsigned char), offset, sample);

    // coloca os valores de width, height, depth e compression nas vars respectivas
    memcpy(&width, &header[18], sizeof(int));
    memcpy(&height, &header[22], sizeof(int));
    memcpy(&depth, &header[28], sizeof(unsigned short));
    memcpy(&compression, &header[30], sizeof(unsigned int));

    // realiza verificações
    // se profundidade diferente de 24bits (mais de 3 canais)
    if (depth != 24){
        printf("ERRO 2: Profundidade não suportada.");
    }

    // se offset pequeno
    if (offset < 54){
        printf("ERRO 3: Tamanho de cabeçalho inválido.");
    }

    // coloca os valores de bytes por pixel, tamanho da imagem e tamanho da coluna
    bytesPixel = depth/8;
    rowSize = (width * bytesPixel + 3) & (~3); // tamanho de cada linha em bytes (incluindo o tal do padding la, preenchimento). 
    imgSize = rowSize * height;

    // coloca os dados dos pixels de sample num buffer
    imageData = (unsigned char*)calloc(imgSize, sizeof(unsigned char));
    fread(imageData, sizeof(unsigned char), imgSize, sample);

    // fecha imagem
    fclose(sample);
    
    // transforma imagem baseado nos canais b, g e r (nessa ordem)
    // coloca em preto e branco
    for (int i = 0; i < height; i++) {
        row = height - i - 1;
        for (int j = 0; j < width; j++) {
            position = row * rowSize + j * bytesPixel;
            b = &imageData[position + 0];
            g = &imageData[position + 1];
            r = &imageData[position + 2];
            mean = (*r + *g + *b)/3; // todos os canais recebem a média dos valores - preto e branco
            *r = mean;
            *g = mean;
            *b = mean;
        }
    }

    // coloca dados em img (a struct)
    image->width = width;
    image->height = height;
    image->depth = depth;
    image->offset = offset;
    image->size = imgSize;
    image->rowSize = rowSize;
    image->header = header;
    image->data = imageData;
}

void saveImg(char* fileName, img* img){
    FILE* saida;

    // primeiro, abre o arquivo em sample
    const char* prefixo = "../img/output/";
    const char* sufixo = ".bmp";
    char caminho[150];

    // pega o nome do arquivo com base no argumento
    snprintf(caminho, sizeof(caminho), "%s%s%s", prefixo, fileName, sufixo);
    saida = fopen(caminho, "wb");
    
    // cabecalho
    fwrite(img->header, sizeof(unsigned char), img->offset, saida);

    // repassa dados
    fwrite(img->data, sizeof(unsigned char), img->size, saida);

    fclose(saida);
}

// funcao que realiza a aplicação do filtro detector de borda + simulação da convolução do coprocssador
void sobel3(img* img){
    unsigned char* new_imgData; // guarda novos dados da imagem
    int16_t tempConvRes; // resultado temporário da convolução
    int i, j, k, l, currentRow, index, nbRow, nbCol, nbIndex, sumX, sumY, newElement;
    int8_t tempM[25] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    // aloca espaco para novos dados da imagem
    new_imgData = (unsigned char*)calloc(img->size, sizeof(unsigned char));

    // declara matrizes com os filtros
    int8_t SOBEL_3[25] = {
     -1,  0,  1,  0,  0,
     -2,  0,  2,  0,  0,
     -1,  0,  1,  0,  0,
      0,  0,  0,  0,  0,
      0,  0,  0,  0,  0
    };

    // loop para passar pelos dados e convoluciona
    // esse for itera pela altura, começando de baixo (ja que é bottom-up)
    for (i = 0; i < img->height; i++){
        currentRow = img->height - i - 1;
        // agora, itera pela linha
        for (j = 0; j < img->width; j++){
            index = currentRow * img->rowSize + j * ((img->depth )/8);

            // preenche a matriz 5x5 considerando vizinhanças 3x3
            for (k = -1; k < 2; k++){
                for (l = -1; l < 2; l++){
                    nbRow = i + k;
                    nbCol = j + l;

                    // ve se posições estão nos limites
                    if(nbRow >= 0 && nbRow < img->height && nbCol >= 0 && nbCol < img->width){
                        nbIndex = (img->height - nbRow - 1) * img->rowSize + nbCol * ((img->depth)/8);
                        // realiza o calculo do indice considerando linha e coluna da matriz num array unidimensional
                        tempM[((k + 1) * 5) + l + 1] = (img->data[nbIndex])/4;
                    }
                }
            }

            uint8_t *temp_pos = tempM;
            // envia a matriz A
            for (int b=0;b<13;b++){
                int flagOK1 = operate_buffer_send(storeMatrixA, 1, b, temp_pos);
                temp_pos += 2;
            }

            // envia o filtro (o SOBEL_X é calculado dentro do coprocessador)
            temp_pos = SOBEL_3;
            for (int g=0;g<13;g++){
                int flagOK2 = operate_buffer_send(storeMatrixB, 1, g, temp_pos);
                temp_pos += 2;
            }

            calculate_matriz(CONV, 1, 0); // envia sinal para iniciar op

            int8_t resultado[4];

            temp_pos = resultado;

            // recebe apenas 2 números 
            int flagResult = operate_buffer_receive(loadMatrixResult, 1, 0, temp_pos);

            // cálculo o módulo das duas somas
            newElement = round(sqrt(pow(resultado[0] * 4, 2)+pow(resultado[1] * 4, 2)));
            if(newElement > 255) newElement = 255;

            // reescrevendo em 3 canais
            new_imgData[index] = (uint8_t)newElement;
            new_imgData[index + 1] = (uint8_t)newElement;
            new_imgData[index + 2] = (uint8_t)newElement;

        }
    }

    img->data=new_imgData;
}

// funcao que realiza a aplicação do filtro detector de borda + simulação da convolução do coprocssador
void sobel5(img* img){
    unsigned char* new_imgData; // guarda novos dados da imagem
    int16_t tempConvRes; // resultado temporário da convolução
    int i, j, k, l, currentRow, index, nbRow, nbCol, nbIndex, sumX, sumY, newElement;
    int8_t tempM[25] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    // aloca espaco para novos dados da imagem
    new_imgData = (unsigned char*)calloc(img->size, sizeof(unsigned char));

    // declara matrizes com os filtros
    int8_t SOBEL_5[25] = {
        -1,   -2,   0,   1,   1,
        -4,   -8,   0,   8,   4,
        -6,  -12,   0,  12,   6,
        -4,   -8,   0,   8,   4,
        -1,   -2,   0,   2,   1
    };

    // loop para passar pelos dados e convoluciona
    // esse for itera pela altura, começando de baixo (ja que é bottom-up)
    for (i = 0; i < img->height; i++){
        currentRow = img->height - i - 1;
        // agora, itera pela linha
        for (j = 0; j < img->width; j++){
            index = currentRow * img->rowSize + j * ((img->depth )/8);

            // preenche a matriz 5x5 considerando vizinhanças 5x5 mesmo
            for (k = -2; k < 3; k++){
                for (l = -2; l < 3; l++){
                    nbRow = i + k;
                    nbCol = j + l;

                    // ve se posições estão nos limites
                    if(nbRow >= 0 && nbRow < img->height && nbCol >= 0 && nbCol < img->width){
                        nbIndex = (img->height - nbRow - 1) * img->rowSize + nbCol * ((img->depth)/8);
                        // realiza o calculo do indice considerando linha e coluna da matriz num array unidimensional
                        tempM[((k + 2) * 5) + l + 2] = (img->data[nbIndex])/4; // agora é 5x5
                    }
                }
            }

            uint8_t *temp_pos = tempM;
            // envia a matriz A
            for (int b=0;b<13;b++){
                int flagOK1 = operate_buffer_send(storeMatrixA, 1, b, temp_pos);
                temp_pos += 2;
            }

            // envia o filtro (o SOBEL_X é calculado dentro do coprocessador)
            temp_pos = SOBEL_5;
            for (int g=0;g<13;g++){
                int flagOK2 = operate_buffer_send(storeMatrixB, 1, g, temp_pos);
                temp_pos += 2;
            }

            calculate_matriz(CONV, 1, 0); // envia sinal para iniciar op

            int8_t resultado[4];

            temp_pos = resultado;

            // recebe apenas 2 números 
            int flagResult = operate_buffer_receive(loadMatrixResult, 1, 0, temp_pos);

            // cálculo o módulo das duas somas
            newElement = round(sqrt(pow(resultado[0] * 4, 2)+pow(resultado[1] * 4, 2)));
            if(newElement > 255) newElement = 255;

            // reescrevendo em 3 canais
            new_imgData[index] = (uint8_t)newElement;
            new_imgData[index + 1] = (uint8_t)newElement;
            new_imgData[index + 2] = (uint8_t)newElement;

        }
    }

    img->data=new_imgData;
}

void prewitt(img* img){

}

void laplacian(img* img){
    unsigned char* new_imgData; // guarda novos dados da imagem
    int16_t tempConvRes; // resultado temporário da convolução
    int i, j, k, l, currentRow, index, nbRow, nbCol, nbIndex, sumX, sumY, newElement;
    int8_t tempM[25] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    // aloca espaco para novos dados da imagem
    new_imgData = (unsigned char*)calloc(img->size, sizeof(unsigned char));

    // declara matrizes com os filtros
    int8_t LAPLACE[25] = {
         0,   0,  -1,   0,   0,
         0,  -1,  -2,  -1,   0,
        -1,  -2,  16,  -2,  -1,
         0,  -1,  -2,  -1,   0,
         0,   0,  -1,   0,   0
    };   

    // esse for itera pela altura, começando de baixo (ja que é bottom-up)
    for (i = 0; i < img->height; i++){
        currentRow = img->height - i - 1;
        // agora, itera pela linha
        for (j = 0; j < img->width; j++){
            index = currentRow * img->rowSize + j * ((img->depth )/8);

            // preenche a matriz 5x5 considerando vizinhanças 5x5 mesmo
            for (k = -2; k < 3; k++){
                for (l = -2; l < 3; l++){
                    nbRow = i + k;
                    nbCol = j + l;

                    // ve se posições estão nos limites
                    if(nbRow >= 0 && nbRow < img->height && nbCol >= 0 && nbCol < img->width){
                        nbIndex = (img->height - nbRow - 1) * img->rowSize + nbCol * ((img->depth)/8);
                        // realiza o calculo do indice considerando linha e coluna da matriz num array unidimensional
                        tempM[((k + 2) * 5) + l + 2] = (img->data[nbIndex])/5; // agora é 5x5
                    }
                }
            }

            uint8_t *temp_pos = tempM;
            // envia a matriz A
            for (int b=0;b<13;b++){
                int flagOK1 = operate_buffer_send(storeMatrixA, 1, b, temp_pos);
                temp_pos += 2;
            }

            // envia o filtro (o SOBEL_X é calculado dentro do coprocessador)
            temp_pos = LAPLACE;
            for (int g=0;g<13;g++){
                int flagOK2 = operate_buffer_send(storeMatrixB, 1, g, temp_pos);
                temp_pos += 2;
            }

            calculate_matriz(LAP, 1, 0); // envia sinal para iniciar op

            int8_t resultado[4];

            temp_pos = resultado;

            // recebe apenas 2 números 
            int flagResult = operate_buffer_receive(loadMatrixResult, 1, 0, temp_pos);

            // cálculo o módulo das duas somas
            newElement = abs(resultado[0]) * 5;
            if(newElement > 255) newElement = 255;

            // reescrevendo em 3 canais
            new_imgData[index] = (uint8_t)newElement;
            new_imgData[index + 1] = (uint8_t)newElement;
            new_imgData[index + 2] = (uint8_t)newElement;

        }
    }

    img->data=new_imgData;

}