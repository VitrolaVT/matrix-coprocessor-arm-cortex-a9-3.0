# MATRIKS: Biblioteca para coprocessador aritmético de matrizes

**Matriks** é uma biblioteca em Assembly desenvolvida para facilitar a comunicação entre o processador ARM Cortex-A9 (rodando Linux) da plataforma DE1-SoC e um coprocessador aritmético para matrizes implementado na Intel FPGA em Verilog.

O coprocessador é capaz de performar operações básicas entre matrizes quadradas de n <= 5 (operações como soma, subtração, multiplicação por escalar ou outra matriz, determinante, oposta...). A biblioteca possui um conjunto de funções em Assembly que permitem ao usuário enviar dados, realizar operações e receber os resultados por meio de um mapeamento de memória.

Para obter mais informações sobre o coprocessador aritmético, acesse o repositório matrix-coprocessor-arm-cortex-a9.

## 🚀 Sumário

* [Introdução](#-introdução)
* [Pré-requisitos](#-requisitos)
* [Como instalar?](#-como-instalar)
* [Requisitos do problema](#-requisitos-do-problema)
* [Recursos utilizados](#-recursos-utilizados)
* [Metodologia](#metodologia)
  * [Unidade de controle](#-unidade-de-controle)
* [Testes](#-testes)
  * [Como realizar testes?](#-como-realizar-testes)
* [Como utilizar o coprocessador?](#-como-utilizar-o-coprocessador)
* [Conclusão](#-conclusão)
* [Referências](#-referências)
* [Colaboradores](#-colaboradores)

## 🧠 Introdução
Os anananannanaana

# 🔧 Como instalar?
* Faça o download do projeto como arquivo `.zip` e extraia a pasta matrix-coprocessor-arm-cortex-a9.
* Abra o **Quartus Prime**.
* Vá em **File** > **Open Project**.
* Encontre o arquivo `matrix-coprocessor-arm-cortex-a9.qpf` na pasta que você extraiu do GitHub.
* Selecione-o e abra.
* Com o projeto aberto, clique no botão que é uma seta azul para a direita, para iniciar a compilação, ou vá em **Processing** > **Start Compilation**.
* Vai em **Tools** > **Programmer**.
* Clique em Hardware Setup pra garantir que o Quartus achou sua placa.
* Depois, carregue o arquivo `.sof` gerado e clique em **Start**.


## 📚 Referências
* Patterson, D. A. ; Hennessy, J. L. 2016. Morgan Kaufmann Publishers. Computer organization and design: ARM edition. 5ª edição.
* GEKSFORGEEKS. Co-processor in Computer Architecture. Disponível em: https://www.geeksforgeeks.org/co-processor-computer-architecture/. 

* INTEL CORPORATION. Intel 8087 Numeric Data Processor: User’s Manual. Disponível em: https://datasheets.chipdb.org/Intel/x86/808x/datashts/8087/205835-007.pdf. 

* PANTUZA, J. Organização e arquitetura de computadores: pipeline em processadores. Disponível em: https://blog.pantuza.com/artigos/organizacao-e-arquitetura-de-computadores-pipeline-em-processadores. 

* FPGA TUTORIAL. How to write a basic Verilog Testbench. Disponível em: https://fpgatutorial.com/how-to-write-a-basic-verilog-testbench/.


## 👥 Colaboradores
* **Rian da Silva Santos** -  [Rian](https://github.com/riancmd)
* **Victor Ariel Matos Menezes** - [Victor](https://github.com/VitrolaVT)
* **Edgar Rodrigo Rocha Silva** - [Edgar](https://github.com/Edgardem)
