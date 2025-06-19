#ifndef matrikslib_h
#define matrikslib_h

#include <stdint.h>

extern void start_program(void);

extern int operate_buffer_send(int opcode, int size, int position, int8_t* matriz);

extern int calculate_matriz(int opcode, int size, int position);

extern int operate_buffer_receive(int opcode, int size, int position, int8_t* matriz);

extern void exit_program(void);

#endif