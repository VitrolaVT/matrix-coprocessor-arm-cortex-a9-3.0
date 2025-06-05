@ Biblioteca Matriks p comunicação com o coprocessador aritmético de matrizes
@ Existem 3 PIOs para a comnunicação, são elas:
@ - PIO1 (Instrução do coprocessador- OFFSET 0x0000) - 8 bits_N1, 8 bits_N2, 4 bits_Opcode, 2 bits_tamanho, 3 bits_position, 1 bit_start
@ - PIO2 (Dados de saída do FPGA - OFFSET 0x0010) - 32bits
@ - PIO3 (Sinais de controle do FPGA - OFFSET 0x0020) - 1 bit_ready_coprocessor, 1 bit_overflow

@ Definição de constantes para as syscalls e stdin/o
.equ EXIT,  1
.equ READ,  3
.equ WRITE, 4
.equ OPEN,  5
.equ CLOSE, 6
.equ MUNMAP, 91
.equ MMAP, 192

.equ STDI, 0 @ Standard input
.equ STDO, 1 @ Standard output

@ Definição de constantes para as syscalls e stdin/o
.equ EXIT,  1
.equ READ,  3
.equ WRITE, 4
.equ OPEN,  5
.equ CLOSE, 6
.equ MUNMAP, 91
.equ MMAP, 192

.equ STDI, 0 @ Standard input
.equ STDO, 1 @ Standard output

@ Definição dos endereços físicos da De1-SoC
.equ FPGA_BRIDGE_PHYS,  0xFF200  @ Endereço físico base
.equ PIO_COPROCESSOR_INSTRUCTION_OFFSET, 0x0000      @ Offset do PIO instrução do coprocessador(HPS->FPGA)
.equ PIO_DATA_OUT_OFFSET, 0x0010      @ Offset do PIO de dados(FPGA->HPS)
.equ PIO_READY_SIGNALS_OFFSET,  0x0020      @ Offset do PIO de de sinais de ready (FPGA->HPS)
.equ PAGE_SIZE,         0x1000        @ Tamanho da página

@ Constantes para o mmap
.equ PROT_READ,      1
.equ PROT_WRITE,     2
.equ MAP_SHARED,     1
.equ O_RDWR,         2
.equ O_SYNC,         0x1000
.equ MAP_FAILED,     -1
.equ COUNTER, 0x1000

@ Definição das funções
.global start_program
.type start_program, %function

.global exit_program
.type exit_program, %function

.global operate_buffer_send
.type operate_buffer_send, %function

.global calculate_matriz
.type calculate_matriz, %function

.global operate_buffer_receive
.type operate_buffer_receive, %function

@ Dados
.section .data
    dev_mem: .asciz "/dev/mem"
    file_descriptor: .word 0
    axi_lw_adrss: .word 0
    mmap_error: .asciz "Erro no mapeamento de memória. Finalizando...\n"
    len1: .word .-mmap_error

@ Procedimento de Mapeamento dos endereços virtuais dos PIOs
.section .text
start_program:
    push {r1-r10, lr} @ Salva os registradores que devem ser preservados e o Registrador de retorno (lr)

    ldr r0,=dev_mem @ Utiliza o dev/mem para acessar a memória física
    mov r1, #2 @ "open for read and write"
    mov r7, #OPEN
    svc #0
    mov r10, r0 @ Salva o File Descriptor
    
    cmp r0, #0
    blt mmap_fail @ Caso haja algum erro no mapeamento, encerra o programa

    @ Mapeamento da memória
    mov r0, #0 @ Kernel escolhe qual endereço utilizar
    ldr r1, =PAGE_SIZE @ Tamanho do mapeamento = 4096b
    mov r2, #3
    mov r3, #MAP_SHARED
    mov r4, r10 @ File descriptor do /dev/mem
    ldr r5,=FPGA_BRIDGE_PHYS @ Endereço físico base
    mov r7, #MMAP
    svc #0

    cmp r0, #MAP_FAILED
    beq mmap_fail
    ldr r1, =axi_lw_adrss
    STR r0, [r1] @ Endereço virtual mapeado colocado na variàvel
       
    pop {r1-r10, lr} @ Restaura registradores e retorna para o antigo lr
    bx lr

mmap_fail:
    mov r0, #STDO @standard output
    ldr r1,=mmap_error @ Guarda valor da string
    ldr r2,=len1
    mov r7, #WRITE @ Syscall: write
    svc #0
    mov r7, #EXIT @ Syscall: exit
    svc #0


@ Procedimento para finalizar o programa
exit_program:
    @ Desmapeia a memória
    LDR R0, =axi_lw_adrss
    LDR R0, [R0]
    MOV R1,#PAGE_SIZE
    MOV R7,#MUNMAP
    SWI 0

    @ Fecha /dev/mem
    MOV R0,R10
    MOV R7,#CLOSE
    SWI 0

    @ Encerra o programa
    MOV R7, #EXIT
    MOV R0, #0
    SWI 0

@ Procedimentos de envio de dados
operate_buffer_send:
    PUSH {R4-R8, LR} @ Salva os registradores que devem ser preservados e o Registrador de retorno (LR)

    @ R3 contém o endereço do array de inteiros (int*)
    LDRB R5, [R3, #0]    @ Carrega o primeiro inteiro (1 byte)
    LDRB R6, [R3, #1]    @ Carrega o segundo inteiro

    @ Concatena os argumentos em uma única instrução
    MOV R4, #0
    LSL R4, R5, #19         @ Num1 [26:19]
    ORR R4, R4, R6, LSL #11 @ Num2 [18:11]
    ORR R4, R4, R0, LSL #7  @ Opcode[10:7]
    ORR R4, R4, R1, LSL #5  @ Size[6:5]
    ORR R4, R4, R2, LSL #1 	@ Position[4:1]
    ORR R4, R4, #1	        @ Start[0]

    @ Escreve nos PIOs de dados de entrada e instrução
    LDR R8, =axi_lw_adrss
    LDR R8, [R8]

    STR R4, [R8, #PIO_COPROCESSOR_INSTRUCTION_OFFSET]

    @ Aguarda a resposta do buffer
wait_response_buffer_send:
    LDR R5, [R8, #PIO_READY_SIGNALS_OFFSET]
    TST R5, #0b10
    BEQ wait_response_buffer_send


    @ Zera o start
    BIC R4, R4, #1
    STR R4, [R8, #PIO_COPROCESSOR_INSTRUCTION_OFFSET]
    MOV R0, #1 @ Retorno de sucesso
    POP {R4-R8, LR} @ Restaura registradores e retorna para o antigo LR
    BX LR

@ Procedimento de iniciar operação com matriz
calculate_matriz:
    PUSH {R4-R8, LR} @Salva os registradores que devem ser preservados e o Registrador de retorno (LR)

    @ Concatena os argumentos em uma única instrução
    MOV R4, #0
    LSL R4, R0, #7          @ Opcode[10:7]
    ORR R4, R4, R1, LSL #5  @ Size[6:5]
    ORR R4, R4, R2, LSL #1 	@ Position[4:1]
    ORR R4, R4, #1	        @ Start[0]  

    @ Escreve no PIO de instrução do coprocessador
    LDR R8, =axi_lw_adrss
    LDR R8, [R8]
    STR R4, [R8, #PIO_COPROCESSOR_INSTRUCTION_OFFSET]


    @ Aguarda resposta do coprocessador
wait_coprocessor:
    LDR R5, [R8, #PIO_READY_SIGNALS_OFFSET]
    TST R5, #0b10
    BEQ wait_coprocessor

    @ Zera o start
    BIC R4, R4, #1
    STR R4, [R8, #PIO_COPROCESSOR_INSTRUCTION_OFFSET]
    MOV R0, #1 @ Retorno de sucesso
    POP {R4-R8, LR} @ Restaura registradores e retorna para o antigo LR
    BX LR


@ Procedimentos de recebimento de dados
operate_buffer_receive:
    PUSH {R4-R8, LR} @ Salva os registradores que devem ser preservados e o Registrador de retorno (LR)

    @ Concatena os argumentos em uma única instrução
    MOV R4, #0
    LSL R4, R0, #7          @ Opcode[10:7]
    ORR R4, R4, R1, LSL #5  @ Size[6:5]
    ORR R4, R4, R2, LSL #1 	@ Position[4:1]
    ORR R4, R4, #1	        @ Start[0]

    @ Escreve nos PIOs de instrução do buffer
    LDR R8, =axi_lw_adrss
    LDR R8, [R8]
    STR R4, [R8, #PIO_COPROCESSOR_INSTRUCTION_OFFSET]


    @ Aguarda a resposta do buffer
wait_response_buffer_receive:
    LDR R5, [R8, #PIO_READY_SIGNALS_OFFSET]
    TST R5, #0b10
    BEQ wait_response_buffer_receive
    
    @ Zera o start
    BIC R4, R4, #1
    STR R4, [R8, #PIO_COPROCESSOR_INSTRUCTION_OFFSET]

    @ Retorna o pacote de 32 bits
    LDR R0, [R8, #PIO_DATA_OUT_OFFSET] 

    STRB R0, [R3, #3]
    LSR R0, R0, #8
    STRB R0, [R3, #2]
    LSR R0, R0, #8
    STRB R0, [R3, #1]
    LSR R0, R0, #8
    STRB R0, [R3, #0]

    LDR R0, [R8, #PIO_DATA_OUT_OFFSET]
    
    POP {R4-R8, LR} @ Restaura registradores e retorna para o antigo LR
    BX LR
    