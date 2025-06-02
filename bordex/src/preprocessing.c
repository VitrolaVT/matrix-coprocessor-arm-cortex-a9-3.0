#include <stdio.h> // possui macro para FILE
#include <stdlib.h>
#include <time.h>
#include <windows.h>

// define struct para erros
typedef struct {
    int codigo;
    char mensagem[100];
    time_t timestamp;
} Erro;

// funcao que adiciona o erro
void registrarErro(Erro erro) {
    FILE *log_file = fopen("log.txt", "a"); // 'a' para append (adicionar ao final)
    
    if (log_file == NULL) {
        printf("Erro ao abrir arquivo de log!\n");
    }

    // Converte o timestamp para formato legível
    char timestamp_str[20];
    strftime(timestamp_str, sizeof(timestamp_str), "%Y-%m-%d %H:%M:%S", localtime(&erro.timestamp));

    // Escreve no arquivo de log
    fprintf(log_file, "[%s] ERRO %d: %s\n", timestamp_str, erro.codigo, erro.mensagem);
    fclose(log_file);
}

int main(){
    //inicializa o arquivo de log (cria novo ou limpa existente)
    FILE *log_init = fopen("log.txt", "w");
    if (log_init) fclose(log_init);

    FILE* sample; // ponteiro para os dados do arquivo
    // primeiro, abre o arquivo em sample
    sample = fopen("img/sample/1.bmp", "rb");

    // verifica se existe a imagem
    if(sample == NULL){
        Erro erro1 = {
            .codigo = 1,
            .mensagem = "O arquivo não existe.",
            .timestamp = time(NULL)
        };
        registrarErro(erro1);
        printf("Erro 1. O arquivo não existe.\n");
        return 1;
    }

    // informações da imagem
    unsigned char tempHeader[14]; // 14 primeiros bytes
    unsigned char* header;
    unsigned char* imageData;
    unsigned char* invertedData;
    unsigned char* r;
    unsigned char* g;
    unsigned char* b;
    int i, j, width, height, offset, rowSize, bytesPixel, imgSize, line, position, mean;
    unsigned short depth;
    unsigned int compression;

    // leitura do arquivo para pegar o offset
    fread(tempHeader, sizeof(unsigned char), 14, sample);

    // verifica se sample é bmp
    if(tempHeader[0] != 'B' || tempHeader[1] != 'M'){
        Erro erro2 = {
            .codigo = 2,
            .mensagem = "Imagem não é bitmap.",
            .timestamp = time(NULL)
        };
        registrarErro(erro2);
        printf("Erro 2. Imagem não é bitmap.\n");
        fclose(sample);
        return 1;
    }

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
        Erro erro4 = {
            .codigo = 4,
                .mensagem = "Profundidade não suportada.",
                .timestamp = time(NULL)
            };
        registrarErro(erro4);
        fclose(sample);
        return 1;
        }

    // se offset muito pequeno ou muito grande
    if(offset < 54) {
        Erro erro5 = {
            .codigo = 5,
            .mensagem = "Cabeçalho com tamanho incorreto (muito pequeno).",
            .timestamp = time(NULL)
        };
        registrarErro(erro5);
        //fclose(sample);
        //free(header);
        //return 1;
    }

    fseek(sample, 0, SEEK_END);
    long file_size = ftell(sample);
    fseek(sample, 0, SEEK_SET);


    if (file_size - offset < imgSize) {
        Erro erro7 = {
            .codigo = 7,
            .mensagem = "Arquivo BMP corrompido (dados de imagem incompletos).",
            .timestamp = time(NULL)
        };
        registrarErro(erro7);
        printf("Erro 7. Dados da imagem insuficientes (esperado: %d, disponível: %ld).\n", imgSize, file_size - offset);
        fclose(sample);
        free(header);
        return 1;
    }

    // se offset maior que tamanho do arquivo
    if(offset > file_size) {
        Erro erro6 = {
            .codigo = 6,
            .mensagem = "Offset maior que o tamanho do arquivo.",
            .timestamp = time(NULL)
        };
        registrarErro(erro6);
        fclose(sample);
        free(header);
        return 1;
    }

    // coloca os valores de bytes por pixel, tamanho da imagem e tamanho da coluna
    bytesPixel = depth/8;
    rowSize = (width * bytesPixel + 3) & (~3); // tamanho de cada linha em bytes (incluindo o tal do padding la, preenchimento). 
    imgSize = rowSize * height;

    // coloca os dados dos pixels de sample 
    imageData = malloc(imgSize * sizeof(unsigned char));
    for (i = 0; i < height; i++){
        int line_in_file = height - i - 1; // NOVAS LINHAS DE TESTE
        fseek(sample, offset + line_in_file * rowSize, SEEK_SET); // NOVAS LINHAS DE TESTE
        fread(&imageData[i * rowSize], sizeof(unsigned char), rowSize, sample);
    }
    //fread(imageData, sizeof(unsigned char), imgSize, sample);
    fclose(sample);

    // transforma imagem baseado nos canais b, g e r (nessa ordem)
    // coloca em preto e branco
    for (int i = 0; i < height; i++) {
        //int line = height - i - 1;
        for (int j = 0; j < width; j++) {
            position = i * rowSize + j * bytesPixel;
            b = &imageData[position + 0];
            g = &imageData[position + 1];
            r = &imageData[position + 2];
            mean = (*r + *g + *b)/3;
            *r = mean;
            *g = mean;
            *b = mean;
        }
    }

    // cria arquivo de saída
    FILE* saida;

    saida = fopen("img/out/out.bmp", "wb");

    if(saida == NULL){
        Erro erro3 = {
            .codigo = 2,
            .mensagem = "Imagem não foi criada.",
            .timestamp = time(NULL)
        };
        registrarErro(erro3);
        printf("Erro 2. Imagem não foi criada.\n");
        fclose(saida);
        return 1;
    }

    // cabeçalho
    fwrite(header, sizeof(unsigned char), offset, saida);

    // aloca espaço e inverte dados da imagem para recolocar no arquivo
    invertedData = malloc(imgSize * sizeof(unsigned char));

    for (i = 0; i < height; i++) {
        memcpy(&invertedData[i * rowSize], &imageData[(height - 1 - i) * rowSize], rowSize);
    }
    fwrite(invertedData, sizeof(unsigned char), imgSize, saida);
    free(invertedData);

    fclose(saida);

    return 0;
}