@ Código Assembly ARMv7 para DE1-SoC
@ Comunicação com FPGA via PIOs usando mmap
@ - PIO1 (Output): 0x0000 (17 bits: bit 16 = start, bits [15:8] = num1, bits [7:0] = num2)
@ - PIO2 (Input): 0x0010 (9 bits: bit 8 = ready, bits [7:0] = resultado)

@ Constantes para syscalls
.equ SYSCALL_EXIT,   1
.equ SYSCALL_READ,   3
.equ SYSCALL_WRITE,  4
.equ SYSCALL_OPEN,   5
.equ SYSCALL_CLOSE,  6
.equ SYSCALL_MMAP,   192
.equ SYSCALL_MUNMAP, 91
.equ STDIN,          0
.equ STDOUT,         1

@ Constantes para mmap
.equ PROT_READ,      1
.equ PROT_WRITE,     2
.equ MAP_SHARED,     1
.equ O_RDWR,         2
.equ O_SYNC,         0x1000
.equ MAP_FAILED,     -1

@ Endereços físicos (DE1-SoC)
.equ FPGA_BRIDGE_BASE,  0xFF200  @ Endereço físico base do HPS-to-FPGA bridge
.equ PIO_OUTPUT_OFFSET, 0x0000      @ Offset do PIO de saída (HPS->FPGA)
.equ PIO_INPUT_OFFSET,  0x0010      @ Offset do PIO de entrada (FPGA->HPS)
.equ PAGE_SIZE,         0x100000    @ Tamanho da região a mapear (1MB)

.data
dev_mem:
    .asciz "/dev/mem"
menu_text:
    .asciz "\nMenu:\n1 - Somar dois numeros\n0 - Sair\nEscolha: "
num1_prompt:
    .asciz "\nDigite o primeiro numero (0-255): "
num2_prompt:
    .asciz "Digite o segundo numero (0-255): "
result_text:
    .asciz "\nResultado recebido da FPGA: "
error_text:
    .asciz "\nErro: Numero invalido! Deve ser entre 0 e 255\n"
mmap_error:
    .asciz "\nErro no mapeamento de memoria!\n"
timeout_msg:
    .asciz "\nErro: Timeout - FPGA não respondeu\n"
newline:
    .asciz "\n"
input_buffer:
    .space 16
result_buffer:
    .space 16

.text
.global _start

_start:
    @ Abre /dev/mem para acessar memória física
    ldr r0, =dev_mem
    mov r1, #2     @ O_RDWR 
    mov r7, #SYSCALL_OPEN
    swi 0
    cmp r0, #0
    blt mmap_fail
    mov r10, r0            @ Salva file descriptor em r10

    @ Mapeia a região da FPGA na memória virtual
    mov r0, #0             @ NULL = deixa o kernel escolher o endereço
    ldr r1, =PAGE_SIZE     @ Tamanho do mapeamento
    mov r2, #3
    mov r3, #MAP_SHARED
    mov r4, r10            @ File descriptor do /dev/mem
    ldr r5, =FPGA_BRIDGE_BASE @ Endereço físico base
    mov r7, #SYSCALL_MMAP
    swi 0
    cmp r0, #MAP_FAILED
    beq mmap_fail
    mov r8, r0             @ Endereço virtual mapeado em r8
    add r9, r8, #PIO_INPUT_OFFSET @ r9 = endereço do PIO de entrada

menu_loop:
    @ Exibe o menu
    ldr r1, =menu_text
    bl print_string

    @ Lê a escolha do usuário
    ldr r1, =input_buffer
    mov r2, #4
    bl read_input
    ldrb r0, [r1]
    cmp r0, #'1'
    beq op_soma
    cmp r0, #'0'
    beq exit_program
    b menu_loop

op_soma:
    @ Pede o primeiro número
    ldr r1, =num1_prompt
    bl print_string
    ldr r1, =input_buffer
    mov r2, #16
    bl read_input
    bl ascii_to_int
    cmp r0, #0
    blt invalid_input
    cmp r0, #255
    bgt invalid_input
    mov r4, r0              @ Armazena num1 em r4

    @ Pede o segundo número
    ldr r1, =num2_prompt
    bl print_string
    ldr r1, =input_buffer
    mov r2, #16
    bl read_input
    bl ascii_to_int
    cmp r0, #0
    blt invalid_input
    cmp r0, #255
    bgt invalid_input
    mov r5, r0              @ Armazena num2 em r5

    @ Prepara os dados para a FPGA (17 bits):
    @ - bits [15:8] = num1
    @ - bits [7:0] = num2
    @ - bit 16 = start (1)
    lsl r4, r4, #8          @ Desloca num1 para bits [15:8]
    orr r4, r4, r5          @ Combina com num2 nos bits [7:0]
    orr r4, r4, #(1 << 16)  @ Ativa bit de start

    @ Envia para a FPGA
    str r4, [r8, #PIO_OUTPUT_OFFSET]
    
    @ Reseta o bit de start
    bic r4, r4, #(1 << 16)
    str r4, [r8, #PIO_OUTPUT_OFFSET]

    @ Aguarda o resultado com timeout
    mov r11, #0             @ Contador de timeout
    ldr r12, =1000000       @ Valor limite de timeout

wait_ready:
    ldr r6, [r9]            @ Lê o PIO de entrada
    tst r6, #(1 << 8)       @ Testa o bit 8 (ready)
    bne result_ready

    add r11, r11, #1
    cmp r11, r12            @ Compara com o limite
    bge timeout
    b wait_ready


result_ready:
    @ Obtém o resultado (bits [7:0])
    and r0, r6, #0xFF

    @ Exibe o resultado
    ldr r1, =result_text
    bl print_string
    ldr r1, =result_buffer
    bl int_to_ascii
    ldr r1, =result_buffer
    bl print_string
    ldr r1, =newline
    bl print_string

    b menu_loop

invalid_input:
    ldr r1, =error_text
    bl print_string
    b menu_loop

timeout:
    ldr r1, =timeout_msg
    bl print_string
    b menu_loop

mmap_fail:
    ldr r1, =mmap_error
    bl print_string
    mov r7, #SYSCALL_EXIT
    mov r0, #1
    swi 0

exit_program:
    @ Desmapeia a memória
    mov r0, r8
    ldr r1, =PAGE_SIZE
    mov r7, #SYSCALL_MUNMAP
    swi 0

    @ Fecha /dev/mem
    mov r0, r10
    mov r7, #SYSCALL_CLOSE
    swi 0

    @ Sai do programa
    mov r7, #SYSCALL_EXIT
    mov r0, #0
    swi 0

@ =============================================
@ Função: print_string
@ Imprime uma string terminada em null
@ Entrada: r1 = endereço da string
@ =============================================
print_string:
    push {r0, r2, r7, lr}
    mov r0, #STDOUT
    mov r2, #0
count_length:
    ldrb r3, [r1, r2]
    cmp r3, #0
    addne r2, r2, #1
    bne count_length
    mov r7, #SYSCALL_WRITE
    swi 0
    pop {r0, r2, r7, pc}

@ =============================================
@ Função: read_input
@ Lê entrada do teclado
@ Entrada: r1 = buffer, r2 = tamanho máximo
@ =============================================
read_input:
    push {r0, r7, lr}
    mov r0, #STDIN
    mov r7, #SYSCALL_READ
    swi 0
    pop {r0, r7, pc}

@ =============================================
@ Função: ascii_to_int
@ Converte string ASCII para inteiro
@ Entrada: r1 = string ASCII
@ Saída: r0 = valor inteiro (0-255)
@ =============================================
ascii_to_int:
    push {r1-r4, lr}
    mov r0, #0
    mov r2, #0
    mov r4, #10
convert_loop:
    ldrb r3, [r1, r2]
    cmp r3, #0xA        @ Newline
    beq convert_done
    cmp r3, #0xD        @ Carriage return
    beq convert_done
    cmp r3, #0          @ Null terminator
    beq convert_done
    sub r3, r3, #'0'
    cmp r3, #9          @ Verifica se é dígito válido
    bhi invalid_input_pop
    mul r0, r4, r0
    add r0, r0, r3
    add r2, r2, #1
    b convert_loop
convert_done:
    pop {r1-r4, pc}

invalid_input_pop:
    pop {r1-r4, lr}
    ldr r1, =error_text
    bl print_string
    mov r0, #-1         @ Retorna valor inválido
    bx lr

@ =============================================
@ Função: int_to_ascii
@ Converte inteiro para string ASCII
@ Entrada: r0 = número, r1 = buffer
@ =============================================
int_to_ascii:
    push {r0-r5, lr}
    mov r2, r1          @ Salva início do buffer
    mov r3, #0          @ Contador de dígitos
    mov r4, #10

    @ Caso especial para zero
    cmp r0, #0
    bne convert_loop2
    mov r5, #'0'
    strb r5, [r2]
    mov r5, #0
    strb r5, [r2, #1]
    b conversion_done2

convert_loop2:
    mov r1, r4
    bl divide
    add r5, r1, #'0'
    strb r5, [r2, r3]
    add r3, r3, #1
    cmp r0, #0
    bne convert_loop2

    @ Adiciona terminador nulo
    mov r5, #0
    strb r5, [r2, r3]

    @ Inverte a string no buffer
    sub r3, r3, #1      @ r3 = índice do último caractere
    mov r1, #0          @ r1 = índice do primeiro caractere
reverse_loop:
    cmp r1, r3
    bge conversion_done2
    ldrb r5, [r2, r1]
    ldrb r0, [r2, r3]
    strb r0, [r2, r1]
    strb r5, [r2, r3]
    add r1, r1, #1
    sub r3, r3, #1
    b reverse_loop

conversion_done2:
    pop {r0-r5, pc}

@ =============================================
@ Função: divide
@ Divide um número por 10
@ Entrada: r0 = dividendo
@ Saída: r0 = quociente, r1 = resto
@ =============================================
divide:
    push {r2}
    mov r1, #0
    mov r2, #10
divide_loop:
    cmp r0, r2
    blt divide_done
    sub r0, r0, r2
    add r1, r1, #1
    b divide_loop
divide_done:
    mov r2, r0
    mov r0, r1
    mov r1, r2
    pop {r2}
    bx lr

.end