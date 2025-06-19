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
#define CONV2 0b1011

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
// filtro teste
void edgeDet(img* img);

int main(){
    start_program(); // mapeia memória
    char imagi;
    char imagi2;
    
    // pré-processamento do arquivo
    // cria imagem
    img img;
    
    printf("Digite o numero da imagem: ");
    scanf("%c", &imagi);
    //snprinft(imagi2, sizeof(imagi2), "%d", imagi);
    preprocess(&imagi, &img);
    edgeDet(&img);
    saveImg("preprocessed", &img);

    
    return 0;
}

void preprocess(char* nomeImg, img* image){
    FILE* sample; // ponteiro para os dados do arquivo
    // primeiro, abre o arquivo em sample
    const char* prefixo = "../img/sample/";
    const char* sufixo = ".bmp";
    char caminho[150];
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
    /**/
    if (depth != 24){
        printf("ERRO 2: Profundidade não suportada.");
    }

    // offset pequeno
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
            mean = (*r + *g + *b)/3;
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
    // cria arquivo de saída
    saida = fopen("../img/output/resultado.bmp", "wb");
    
    // cabecalho
    fwrite(img->header, sizeof(unsigned char), img->offset, saida);

    // repassa dados
    fwrite(img->data, sizeof(unsigned char), img->size, saida);

    fclose(saida);
}

void edgeDet(img* img){
    unsigned char* new_imgData;
    int16_t tempConvRes;
    int i, j, k, l, currentRow, index, nbRow, nbCol, nbIndex, newElement;
    int8_t tempM[25] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    int8_t convX[25] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    int8_t convY[25] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    // aloca espaco para novos dados da imagem
    new_imgData = (unsigned char*)calloc(img->size, sizeof(unsigned char));

   // declara matrizes com os filtros
   int8_t SOBEL_3X3[25] = {
    -1,  0,  1,  0, 0,
    -2,  0,  2,  0, 0,
    -1,  0,  1,  0, 0,
     0,  0,  0,  0, 0,
     0,  0,  0,  0, 0
   };

   int8_t SOBEL_5X5_V1[25] = { //Rian
        2,    2,    4,    2,    2,
        1,    1,    2,    1,    1,
        0,    0,    0,    0,    0,
       -1,   -1,   -2,   -1,   -1,
       -2,   -2,   -4,   -2,   -2
   };
  
   int8_t SOBEL_5X5_V2[25] = { //IA
       -2,   -2,   -4,   -2,   -2,
       -1,   -1,   -2,   -1,   -1,
        0,    0,    0,    0,    0,
        1,    1,    2,    1,    1,
        2,    2,    4,    2,    2
   };

   int8_t SOBEL_5X5_V4[25] = { //Robson
     -1,   -2,   0,   2,   1,
     -2,   -3,   0,   3,   2,
     -3,   -4,   0,   3,   4,
     -2,   -3,   0,   3,   2,
     -1,   -2,   0,   2,   1
};

   int8_t SOBEL_5X5_V3[25] = { //GIULIA
       -1,   -2,   0,   2,   1,
       -4,   -8,   0,   8,   4,
        -6,    -12,    0,    12,    6,
        -4,    -8,    0,    8,    4,
        -1,    -2,    0,    2,    1
   };

   int8_t PREWITT_3X3[25] = {
       -1, 0,  1,  0,  0,
       -1, 0,  1,  0,  0,
       -1, 0,  1,  0,  0,
       0,  0,  0,  0,  0,
       0,  0,  0,  0,  0
   };
   
   int8_t ROBERTS_2X2[25] = {
       1, 0,  0,  0,  0,
       0, -1,  0,  0,  0,
       0, 0,  0,  0,  0,
       0,  0,  0,  0,  0,
       0,  0,  0,  0,  0
   };

   int8_t LAPLACE_5X5[25] = {
       0, 0,  -1,  0,  0,
       0, -1,  -2,  -1,  0,
       -1, -2,  16,  -2,  -1,
       0,  -1,  -2,  -1,  0,
       0,  0,  -1,  0,  0
   };

   int c, v, t, u;
   int opcode;
   printf("Digite o filtro\n(1) Sobel3x3\n(2) Sobel5x5\n(3) Prewitt3x3\n(4) Roberts2x2\n(5) Laplace5x5\n");
   scanf("%d", &c);

    //Divisão 
    int d;
    int e;

   uint8_t* temp_pos2;

   switch(c) {
    case 1:
        temp_pos2 = SOBEL_3X3;
        v = 1;
        t = 2;
        u = -1;
        d = 4;
        e = 4;
        opcode = CONV;
        printf("Sobel 3x3 selecionado\n");
        break;
    case 2:
        temp_pos2 = SOBEL_5X5_V1;
        printf("Sobel 5x5 selecionado\n");
        v = 2;
        t = 3;
        u = -2;
        d = 32;
        e = 2;
        opcode = CONV;
        break;
    case 3:
        temp_pos2 = PREWITT_3X3;
        printf("Prewitt 3x3 selecionado\n");
        v = 1;
        t = 2;
        u = -1;
        d = 4;
        e = 4;
        opcode = CONV;
        break;
    case 4:
        temp_pos2 = ROBERTS_2X2;
        printf("Roberts 2x2 selecionado\n");
        v = 0;
        t = 2;
        u = 0;
        d = 1;
        e = 1;
        opcode = CONV2;
        break;
    case 5:
        temp_pos2 = LAPLACE_5X5;
        v = 2;
        t = 3;
        u = -2;
        d = 8;
        e = 2;
        opcode = CONV;
        printf("Laplace 5x5 selecionado\n");
        break;
    default:
        printf("Opção inválida! Usando Sobel 3x3 como padrão.\n");
        v = 1;
        t = 2;
        u = -1;
        d = 1;
        e = 1;
        opcode = CONV;
        temp_pos2 = SOBEL_3X3;
        break;
}    

    for (int g=0;g<13;g++){
        int flagOK2 = operate_buffer_send(storeMatrixB, 1, g, temp_pos2);
        temp_pos2 += 2;
    }


    // loop para passar pelos dados e convoluciona
    // esse for itera pela altura, começando de baixo (ja que é bottom-up)
    for (i = 0; i < img->height; i++){
        currentRow = img->height - i - 1;
        // agora, itera pela linha
        for (j = 0; j < img->width; j++){
            index = currentRow * img->rowSize + j * ((img->depth )/8);

            // preenche a matriz 5x5 considerando vizinhanças 3x3
            for (k = u; k < t; k++){
                for (l = u; l < t; l++){
                    nbRow = i + k;
                    nbCol = j + l;

                    // ve se posições estão nos limites
                    if(nbRow >= 0 && nbRow < img->height && nbCol >= 0 && nbCol < img->width){
                        nbIndex = (img->height - nbRow - 1) * img->rowSize + nbCol * ((img->depth)/8);
                        tempM[((k + v) * 5) + l + v] = (img->data[nbIndex])/d;
                    }
                }
            }

            int8_t *temp_pos = tempM;
            for (int b=0;b<13;b++){
                int flagOK1 = operate_buffer_send(storeMatrixA, 1, b, temp_pos);
                temp_pos += 2;
            }

            

            calculate_matriz(opcode, 1, 0); // envia sinal para iniciar op

            int8_t resultado[4];

            temp_pos = resultado;

            int flagResult = operate_buffer_receive(loadMatrixResult, 1, 0, temp_pos);


            if (c != 7){
                newElement = round(sqrt(pow(resultado[0]*e, 2)+pow(resultado[1]*e, 2))); //Nao laplace
            }
            else{
                newElement = abs(resultado[0]*e); // Laplace
                //if (newElement < 0) newElement = 0;
            }

            //newElement = resultado[2]*d; //Raiz (esta feia)

            //newElement = sqrt(pow(resultado[0]*e, 2)); //laplace

            if(newElement > 255) newElement = 255;

            // reescrevedo em 3 canais
            new_imgData[index] = (uint8_t)newElement;
            new_imgData[index + 1] = (uint8_t)newElement;
            new_imgData[index + 2] = (uint8_t)newElement;

    
        }

        
    }

    img->data=new_imgData;
}