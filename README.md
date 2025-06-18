# BORDEX: Detector de borda BMP para coprocessador aritmético de matrizes

**Bordex** é um programa desenvolvido em C para realizar detecção de bordas em imagens bitmap utilizando alguns filtros conhecidos. São eles: Sobel, Laplace, Prewitt e Roberts. O Bordex se utiliza da biblioteca em Assembly Matriks, que facilita a comunicação entre o processador ARM Cortex-A9 (rodando Linux) da plataforma DE1-SoC e um coprocessador aritmético para matrizes implementado na Intel FPGA em Verilog.

O coprocessador que acompanha o programa é capaz de performar operações básicas entre matrizes quadradas de n <= 5 (operações como soma, subtração, multiplicação por escalar ou outra matriz, determinante, oposta...), mas o que é efetivamente utilizado são as duas operações de convolução para aplicação dos filtros de detecção de borda. A biblioteca Matriks possui um conjunto de funções em Assembly que permitem ao usuário enviar dados, realizar operações e receber os resultados por meio de um mapeamento de memória. Já o programa Bordex permite o usuário escolher entre algumas imagens no diretório base e aplicar filtros a ela.

Para obter mais informações exclusivamente sobre o coprocessador aritmético, acesse o [repositório](https://github.com/riancmd/matrix-coprocessor-arm-cortex-a9).
Para a biblioteca Matriks, acesse o [repositório](https://github.com/riancmd/matrix-coprocessor-arm-cortex-a9-2.0).

## 🚀 Sumário

* [Sobre o programa](#-sobre-o-programa)
* [Pré-requisitos](#-pré-requisitos)
* [Como instalar?](#-como-instalar)
* [Recursos utilizados](#-recursos-utilizados)
* [Metodologia](#-metodologia)
  * [Módulos de convolução no coprocessador](#-modulos-de-convolução-no-coprocessador)
  * [Pré-processamento de imagem](#-pre-processamento-de-imagem)
  * [Integração com a biblioteca](#-integracao-com-a-biblioteca)
  * [Programa principal](#-programa-principal)
* [Testes](#testes)
* [Conclusão](#conclusão)
* [Referências](#-referências)
* [Colaboradores](#-colaboradores)

## 👨‍💻 Sobre o coprocessador
Para utilizar o programa Bordex, é necessário ter o coprocessador aritmético para matrizes implementado na FPGA do kit DE1-SoC e a biblioteca Matriks em Assembly. Caso contrário, não será possível utilizar o Bordex, pois ele depende de ambos para processamento das instruções.

O [coprocessador aritmético de matrizes](https://github.com/riancmd/matrix-coprocessor-arm-cortex-a9), desenvolvido para trabalhar em conjunto com o processador ARM Cortex A9, foi implementado em Verilog e possui toda sua documentação disponível no repositório linkado. Entretanto, junto a este repositório, há uma versão atualizada do coprocessador para trabalhar em conjunto com o programa, o que inclui os novos módulos e instruções de convolução. Portanto, **o programa deve ser usadao junto à nova versão do coprocessador**. A versão 3.0 do coprocessador possui modificações para conserto de alguns bugs, além da adição de novos módulos para a convolução (na aplicação de filtros), essencial para o Bordex.

## 📄 Pré-requisitos
Para que o projeto funcione corretamente, é necessário que você tenha:

- Um **kit de desenvolvimento DE1-SoC** com FPGA Cyclone V.
- O software **Quartus Prime Lite Edition 23.1.1** instalado no seu computador.
- Uma distribui **Linux instalado e funcional no HPS** (Hard Processor System) do kit DE1-SoC.
- Conexão entre o HPS e o computador via **cabo Ethernet**.
- O **compilador GCC** já instalado no Linux do HPS (geralmente vem por padrão).

> ⚠️ Estes requisitos **devem** ser seguidos. O projeto foi desenvolvido exclusivamente para o kit DE1-SoC, cuja pinagem e arquitetura são específicas. Ele **não funciona** com outros kits ou configurações diferentes.

## 🔧 Como instalar?
### 1. Preparar o projeto

- Faça o download do projeto como arquivo `.zip` no GitHub.
- Extraia a pasta `matrix-coprocessor-arm-cortex-a9-3.0`.

### 2. Compilar no Quartus Prime

- Abra o **Quartus Prime Lite Edition**.
- Vá em **File > Open Project**.
- Navegue até a pasta extraída do projeto, no subdiretório `matrix-coprocessor-arm-cortex-a9-3.0`.
- Selecione o arquivo `soc_system.qpf` e clique em **Abrir**.
- Clique na **seta azul para a direita** ou vá em **Processing > Start Compilation** para iniciar a compilação.
- Após a compilação, vá em **Tools > Programmer**.
- Clique em **Hardware Setup** e verifique se a placa foi reconhecida.
- Carregue o arquivo `.sof` gerado.
- Clique em **Start** para programar a FPGA.

### 3. Conectar ao HPS via SSH

- Conecte o HPS ao seu computador via **cabo Ethernet**.
- Verifique o IP da placa (disponível na sua placa).
- Abra o terminal no seu computador.
- Utilize o comando SSH para acessar o HPS:
  - `ssh <seu_usuario>@<ip_do_hps>`

### 4. Transferir os arquivos para o HPS
- Abra o subdiretório `bordex` no diretório raiz extraído.
- Certifique-se de que a pasta `src` (com `bordex.c` e `makefile`) e a pasta `lib` estão organizadas corretamente.
- Use um dos métodos abaixo para transferir os arquivos para o HPS:

#### Opção 1: Pelo terminal (Linux/macOS/WSL)

- Acesse o terminal no seu computador.
- Use o comando `scp` para copiar os arquivos:
  - `scp -r src lib <seu_usuario>@<ip_do_hps>:~/`

#### Opção 2: Pelo gerenciador de arquivos

- No **Linux**:
  - Abra o gerenciador de arquivos.
  - Acesse `sftp://<seu_usuario>@<ip_do_hps>` e copie os arquivos.
- No **Windows**:
  - Use programas como **WinSCP** ou **FileZilla** para realizar a transferência via SFTP.

### 5. Compilar e rodar no HPS

- Acesse o terminal do HPS via SSH.
- Navegue até a pasta `src` onde está o `makefile`.
- Compile o projeto com o comando `make compile`.
- Execute o programa com o comando `make run`.
- Siga as instruções do terminal para escolher a operação, o tamanho da matriz e digitar seus elementos.

## 📦 Recursos utilizados
### 🧩 Placa DE1-SoC

A placa DE1-SoC, baseada no SoC Cyclone V, integra um sistema de processador (HPS) com uma FPGA, permitindo projetos embarcados que combinam software e hardware dedicados.

[Manual da placa - Intel](https://www.intel.com/content/www/us/en/developer/articles/technical/fpga-academic-boards.html)

### 🛠️ Quartus Prime Lite (versões 20.1 e 23.1)

Ferramenta oficial da Intel para desenvolvimento com FPGAs. Permite a criação de circuitos digitais usando linguagens como Verilog e VHDL, com suporte a simulação, análise e programação das placas.

[Site Oficial do Software](https://www.intel.com.br/content/www/br/pt/products/details/fpga/development-tools/quartus-prime.html)

### 🐧 DE1-SoC-UP Linux

O sistema operacional DE1-SoC-UP Linux é a distribuição específica do HPS da DE1-SoC, responsável por rodar o programa que interage com o coprocessador implementado na FPGA através da biblioteca Assembly.

### 👨‍💻 IDE VSCode

Editor de código-fonte gratuito e multiplataforma desenvolvido pela Microsoft. Oferece suporte a diversas linguagens de programação, sistema de extensões robusto, terminal integrado, controle de versão Git nativo e recursos avançados como depuração e refatoração de código.

[Site Oficial do Software](https://code.visualstudio.com/)

---

## 🔨 Metodologia
A atualização do projeto consistiu em realizar 3 etapas básicas: I - Criação dos módulos de convolução no coprocessador para aplicação dos filtros de detecção de borda; II - Criação do código para pré-processamento da imagem em C; III - Programa Bordex para envio dos kernels dos filtros e tratamento final da imagem.

## ✖ Módulos de convolução no coprocessador
AAAAAAAAAAAAAAA

## 🤳 Pré-processamento de imagem
Este código implementa um sistema de pré-processamento para imagens BMP que trabalha com a estrutura específica desse formato de arquivo. Uma imagem BMP é organizada em duas partes principais: o cabeçalho (que contém informações como dimensões, profundidade de cor e offset) e os dados dos pixels propriamente ditos. O código utiliza uma struct (`img`) para armazenar todos esses metadados, fazendo a leitura completa do arquivo e extraindo as informações essenciais do cabeçalho. A conversão para escala de cinza ocorre nessa parte e é essencial para a aplicação dos filtros. Ela funciona da seguinte forma: como cada pixel colorido possui três canais (vermelho, verde e azul), o código calcula a média desses três valores e aplica esse resultado nos três canais simultaneamente. Quando os três canais RGB têm o mesmo valor, o resultado visual é uma tonalidade de cinza, preparando perfeitamente a imagem para algoritmos de detecção de bordas que trabalham melhor com informações apenas de luminosidade.

O desenvolvimento seguiu lidando com algumas peculiaridades do formato BMP, como o fato de que os dados dos pixels ficam separados do cabeçalho por um offset específico, e o sistema de padding que alinha cada linha em múltiplos de 4 bytes para otimização de memória. Apenas depois foi criada a struct que facilita o processo, numa refatoração do código. Outro detalhe importante é que as imagens BMP armazenam as linhas de forma invertida (de baixo para cima), então o código precisa considerar isso ao processar os pixels. A conversão para escala de cinza foi implementada de forma eficiente, percorrendo cada pixel e aplicando a transformação diretamente nos dados originais, economizando memória e deixando tudo pronto para os filtros de detecção de bordas.

## ✖ Integração com a biblioteca
AAAAAAAAAAAAAAA

## ✖ Programa principal
AAAAAAAAAAAAAAA

## ✖ Testes
AAAAAAAAAAAAAAA

## ✖ Conclusão
AAAAAAAAAAAAAAA

## 📚 Referências
* Patterson, D. A. ; Hennessy, J. L. 2016. Morgan Kaufmann Publishers. Computer organization and design: ARM edition. 5ª edição.
* GEKSFORGEEKS. Co-processor in Computer Architecture. Disponível em: https://www.geeksforgeeks.org/co-processor-computer-architecture/. 

* INTEL CORPORATION. Intel 8087 Numeric Data Processor: User’s Manual. Disponível em: https://datasheets.chipdb.org/Intel/x86/808x/datashts/8087/205835-007.pdf. 

* PANTUZA, J. Organização e arquitetura de computadores: pipeline em processadores. Disponível em: https://blog.pantuza.com/artigos/organizacao-e-arquitetura-de-computadores-pipeline-em-processadores. 

* FPGA TUTORIAL. How to write a basic Verilog Testbench. Disponível em: https://fpgatutorial.com/how-to-write-a-basic-verilog-testbench/.


## 👥 Colaboradores
* **Rian da Silva Santos** -  [Rian](https://github.com/riancmd)
* **Victor Ariel Matos Menezes** - [Victor](https://github.com/VitrolaVT)
