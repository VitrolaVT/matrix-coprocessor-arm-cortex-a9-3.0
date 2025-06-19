//Módulo de controle para leitura, decodificação, execução e escrita de dados
module control_unit(
	input clk, rst, //Sinais de clock e reset
	input [31:0] instruction, //Instruçao contendo 2 numeros de 8 bits, opcode, tamanho de matriz, posiçao de armazenamento e sinal de start
	output wire [31:0] package_data_out, //Pacote de dados de 32 bits do FPGA-HPS
	output reg ready, //Sinal de termino da operaçao do buffer e da operaçao do coprocessador, respectivamente
	output overflow_wire //Sinal de overflow
);	

	//Definição dos estados da máquina de estados
	localparam IDLE = 3'b000;
	localparam FETCH = 3'b001;
	localparam DECODE = 3'b010;
	localparam EXECUTE = 3'b011;
	localparam WRITEBACK = 3'b100;

	reg [2:0] state;
	reg overflow;
	assign overflow_wire = overflow;
		
	//Definição dos códigos de operação
	localparam SOMA = 4'b0000;
	localparam SUBTRACAO = 4'b0001;
	localparam MULT_MATRIZ = 4'b0010;
	localparam MULT_INT = 4'b0011;
	localparam DETERMINANTE = 4'b0100;
	localparam TRANSPOSTA = 4'b0101;
	localparam OPOSTA = 4'b0110;
	localparam STORE_MATRIX1 = 4'b0111;
	localparam STORE_MATRIX2 = 4'b1000;
	localparam LOAD_MATRIXR = 4'b1001;
	localparam CONVOLUTION_TRANS = 4'b1010;
	localparam CONVOLUTION_ROBERTS = 4'b1011;

	
	//Definição dos códigos das posições dos registradores de dados
	localparam OFFSET0 = 4'b0000;
	localparam OFFSET1 = 4'b0001;
	localparam OFFSET2 = 4'b0010;
	localparam OFFSET3 = 4'b0011;
	localparam OFFSET4 = 4'b0100;
	localparam OFFSET5 = 4'b0101;
	localparam OFFSET6 = 4'b0110;
	localparam OFFSET7 = 4'b0111;
	localparam OFFSET8 = 4'b1000;
	localparam OFFSET9 = 4'b1001;
	localparam OFFSET10 = 4'b1010;
	localparam OFFSET11 = 4'b1011;
	localparam OFFSET12 = 4'b1100;
	
	//Fios intermediários correspondentes às saídas dos módulos de operação
	//Soma
	wire [39:0] adder_result1, adder_result2, adder_result3, adder_result4, adder_result5; //Resultados da soma
	wire adder_ovf1, adder_ovf2, adder_ovf3, adder_ovf4, adder_ovf5; //Overflow da soma
	
	//Subtração
	wire [39:0] sub_result1, sub_result2, sub_result3, sub_result4, sub_result5; //Resultados da subtraçaõ
	wire sub_ovf1, sub_ovf2, sub_ovf3, sub_ovf4, sub_ovf5; //Overflow da subtraçaõ
	
	//Multiplicação entre matrizes
	wire [199:0] multMA_result; //Resultado da multiplicação entre matrizes
	wire multMA_ovf; //Overflow da multiplicação entre matrizes
	
	//Multiplicação por inteiro
	wire [39:0] multMI_result1, multMI_result2, multMI_result3, multMI_result4, multMI_result5; //Resultados da multiplicação por inteiro
	wire multMI_ovf1, multMI_ovf2, multMI_ovf3, multMI_ovf4, multMI_ovf5; //Overflow da multiplicação por inteiro
	
	//Determinante 2x2
	wire [7:0] det2x2_result; //Resultado da determinante 2x2
	wire det2x2_ovf; //Overflow da determinante 2x2
	
	//Determinante 3x3
	wire [7:0] det3x3_result; //Resultado da determinante 3x3
	wire det3x3_ovf; //Overflow da determinante 3x3
	
	//Determinante 4x4
	wire [7:0] det4x4_result; //Resultado da determinante 4x4
	wire det4x4_ovf; //Overflow da determinante 4x4
	
	//Determinante 5x5
	wire [7:0] det5x5_result; //Resultado da determinante 5x5
	wire det5x5_ovf; //Overflow da determinante 5x5
	
	//Transposta
	reg [39:0] trans_result1, trans_result2, trans_result3, trans_result4, trans_result5; //Resultados da Transposta
	
	//Oposta
	wire [39:0] opp_result1, opp_result2, opp_result3, opp_result4, opp_result5; //Resultados da oposta
	wire opp_ovf1, opp_ovf2, opp_ovf3, opp_ovf4, opp_ovf5; //Overflow da oposta caso exista elemento igual a -128
	
	//Colunas temporárias da multiplicaçao entre matrizes
	reg [39:0] m2_c0, m2_c1, m2_c2, m2_c3, m2_c4; //Primeira coluna até a última nessa ordem
		
	
	//Módulos responsáveis por operar os dados
	//Módulos de soma para cada linha
	add_M adderL1(matrix1_reg[199:160], matrix2_reg[199:160], rst, adder_result1, adder_ovf1);
	add_M adderL2(matrix1_reg[159:120], matrix2_reg[159:120], rst, adder_result2, adder_ovf2);
	add_M adderL3(matrix1_reg[119:80], matrix2_reg[119:80], rst, adder_result3, adder_ovf3);
	add_M adderL4(matrix1_reg[79:40], matrix2_reg[79:40], rst, adder_result4, adder_ovf4);
	add_M adderL5(matrix1_reg[39:0], matrix2_reg[39:0], rst, adder_result5, adder_ovf5);
	
	//Módulos de subtração para cada linha
	sub_M subtractorL1(matrix1_reg[199:160], matrix2_reg[199:160], rst, sub_result1, sub_ovf1);
	sub_M subtractorL2(matrix1_reg[159:120], matrix2_reg[159:120], rst, sub_result2, sub_ovf2);
	sub_M subtractorL3(matrix1_reg[119:80], matrix2_reg[119:80], rst, sub_result3, sub_ovf3);
	sub_M subtractorL4(matrix1_reg[79:40], matrix2_reg[79:40], rst, sub_result4, sub_ovf4);
	sub_M subtractorL5(matrix1_reg[39:0], matrix2_reg[39:0], rst, sub_result5, sub_ovf5);
	
	//Módulos de multiplicação entre matrizes para cada 2 linhas e 2 colunas 
	//Insere a matriz A inteira como input e a matriz B organizada em colunas
	mult_M multi_MA(matrix1_reg[199:0], {m2_c0, m2_c1, m2_c2, m2_c3, m2_c4}, rst, multMA_result, multMA_ovf);
	
	//Módulos de multiplicação por inteiro para cada linha
	mult_MI multi_MIL1(matrix1_reg[199:160], matrix2_reg[199:192], rst, multMI_result1, multMI_ovf1);
	mult_MI multi_MIL2(matrix1_reg[159:120], matrix2_reg[199:192], rst, multMI_result2, multMI_ovf2);
	mult_MI multi_MIL3(matrix1_reg[119:80], matrix2_reg[199:192], rst, multMI_result3, multMI_ovf3);
	mult_MI multi_MIL4(matrix1_reg[79:40], matrix2_reg[199:192], rst, multMI_result4, multMI_ovf4);
	mult_MI multi_MIL5(matrix1_reg[39:0], matrix2_reg[199:192], rst, multMI_result5, multMI_ovf5);
	
	//Módulo de determinante 2x2
	det2 determinant2x2(matrix1_reg[199:184], matrix1_reg[159:144], rst, det2x2_result, det2x2_ovf);
	
	//Modulo de determinante 3x3
	det3 determinant3x3({matrix1_reg[199:176], matrix1_reg[159:136], matrix1_reg[119:96]}, rst, det3x3_result, det3x3_ovf);
	
	//Modulo de determinante 4x4
	det4 determinant4x4({matrix1_reg[199:168], matrix1_reg[159:128], matrix1_reg[119:88], matrix1_reg[79:48]}, rst, det4x4_result, det4x4_ovf);
	
	//Modulo de determinante 5x5
	det5 determinant5x5({matrix1_reg[199:160], matrix1_reg[159:120], matrix1_reg[119:80], matrix1_reg[79:40], matrix1_reg[39:0]}, rst, det5x5_result, det5x5_ovf);
	
	//Modulos de oposta para cada linha
	opp_M oppL1(matrix1_reg[199:160], rst, opp_result1, opp_ovf1);
	opp_M oppL2(matrix1_reg[159:120], rst, opp_result2, opp_ovf2);
	opp_M oppL3(matrix1_reg[119:80], rst, opp_result3, opp_ovf3);
	opp_M oppL4(matrix1_reg[79:40], rst, opp_result4, opp_ovf4);
	opp_M oppL5(matrix1_reg[39:0], rst, opp_result5, opp_ovf5);
	
	//Modulo da operaçao de convoluçao que usa transposta(Sobel, Prewitt e Laplaciano)
	convolution_trans convolution_trans(
	.start(start_convo_trans),
	.clk(clk), 
	.rst(rst),
	.ready(ready_convo_trans),
	.matrizA(matrix1_reg),
	.matrizB(matrix2_reg),
	.sum_resultX(convo_trans_resultX),
	.sum_resultY(convo_trans_resultY),
	.ovf(convo_trans_ovf)
	);
	
	reg start_convo_trans; //Sinal de start do modulo de convulaçao
	wire ready_convo_trans; //Sinal de pronto do modulo de convulaçao
	wire [7:0] convo_trans_resultX; //Resultado do eixo X
	wire [7:0] convo_trans_resultY; //Resultado do eixo Y
	wire convo_trans_ovf; //Overflow da convulaçao
	
	//Modulo da operaçao de convoluçao para filtro Roberts)
	convolution_roberts convolution_roberts(
	.start(start_convo_ro),
	.clk(clk), 
	.rst(rst),
	.ready(ready_convo_ro),
	.matrizA({matrix1_reg[199:184], matrix1_reg[159:144]}),
	.matrizB({matrix2_reg[199:184], matrix2_reg[159:144]}),
	.sum_resultX(convo_ro_resultX),
	.sum_resultY(convo_ro_resultY),
	.ovf(convo_ro_ovf)
	);
	
	reg start_convo_ro; //Sinal de start do modulo de convulaçao
	wire ready_convo_ro; //Sinal de pronto do modulo de convulaçao
	wire [7:0] convo_ro_resultX; //Resultado do eixo X
	wire [7:0] convo_ro_resultY; //Resultado do eixo Y
	wire convo_ro_ovf; //Overflow da convulaçao
	
	//Transposiçao da matriz
	always @(*) begin
		trans_result1[39:32] = matrix1_reg[199:192];
		trans_result1[31:24] = matrix1_reg[159:152];
		trans_result1[23:16] = matrix1_reg[119:112];
		trans_result1[15:8] = matrix1_reg[79:72];
		trans_result1[7:0] = matrix1_reg[39:32];
		
		trans_result2[39:32] = matrix1_reg[191:184];
		trans_result2[31:24] = matrix1_reg[151:144];
		trans_result2[23:16] = matrix1_reg[111:104];
		trans_result2[15:8] = matrix1_reg[71:64];
		trans_result2[7:0] = matrix1_reg[31:24];
		
		trans_result3[39:32] = matrix1_reg[183:176];
		trans_result3[31:24] = matrix1_reg[143:136];
		trans_result3[23:16] = matrix1_reg[103:96];
		trans_result3[15:8] = matrix1_reg[63:56];
		trans_result3[7:0] = matrix1_reg[23:16];
		
		trans_result4[39:32] = matrix1_reg[175:168];
		trans_result4[31:24] = matrix1_reg[135:128];
		trans_result4[23:16] = matrix1_reg[95:88];
		trans_result4[15:8] = matrix1_reg[55:48];
		trans_result4[7:0] = matrix1_reg[15:8];
		
		trans_result5[39:32] = matrix1_reg[167:160];
		trans_result5[31:24] = matrix1_reg[127:120];
		trans_result5[23:16] = matrix1_reg[87:80];
		trans_result5[15:8] = matrix1_reg[47:40];
		trans_result5[7:0] = matrix1_reg[7:0];
	end
	
	//Cria colunas de m2
	always@(*) begin
		m2_c0 = {matrix2_reg[199:192], matrix2_reg[159:152], matrix2_reg[119:112], matrix2_reg[79:72], matrix2_reg[39:32]};
		m2_c1 = {matrix2_reg[191:184], matrix2_reg[151:144], matrix2_reg[111:104], matrix2_reg[71:64], matrix2_reg[31:24]};
		m2_c2 = {matrix2_reg[183:176], matrix2_reg[143:136], matrix2_reg[103:96], matrix2_reg[63:56], matrix2_reg[23:16]};
		m2_c3 = {matrix2_reg[175:168], matrix1_reg[135:128], matrix2_reg[95:88], matrix2_reg[55:48], matrix2_reg[15:8]};
		m2_c4 = {matrix2_reg[167:160], matrix2_reg[127:120], matrix2_reg[87:80], matrix2_reg[47:40], matrix2_reg[7:0]};
	end
	
	
	
	//Registradores intermediários
	reg [3:0] opcode_reg;
	reg [1:0] msize_reg;
	reg [3:0] position_reg;
	reg [199:0] matrix1_reg, matrix2_reg;
	reg [199:0] result_reg;
	reg [31:0] package_data_out_reg;
	reg operation_active;
	
	
	assign package_data_out = package_data_out_reg;
	
	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state = IDLE;
		end 
		else begin
			case (state)
				//Estado inicial IDLE, sendo um estado de espera para uma nova operação
				IDLE: begin
					if (instruction[0]) begin
						operation_active = 1;
						state = FETCH;
					end
					else begin
						state = IDLE;
					end
				end
				
				//Estado FETCH para receber as intruções
				FETCH: begin
					opcode_reg = instruction[10:7];
					msize_reg = instruction[6:5];
					position_reg = instruction[4:1];
					state = DECODE;
				end
				
				//Estado de decodificação do buffer
				DECODE: begin
					if (opcode_reg == CONVOLUTION_TRANS) begin
						start_convo_trans = 1;
					end
					else begin
						start_convo_trans = 0;
					end
					
					if (opcode_reg == CONVOLUTION_ROBERTS) begin
						start_convo_ro = 1;
					end
					else begin
						start_convo_ro = 0;
					end
					
					ready = 0;
					state = EXECUTE;
				end
				
				//Estado de execução da operação
				EXECUTE: begin
					case (opcode_reg)
						SOMA: begin 
							result_reg[199:160] = adder_result1;
							result_reg[159:120] = adder_result2;
							result_reg[119:80] = adder_result3;
							result_reg[79:40] = adder_result4;
							result_reg[39:0] = adder_result5;
							overflow = adder_ovf1 || adder_ovf2 || adder_ovf3 || adder_ovf4 || adder_ovf5;
						end
						
						SUBTRACAO: begin
							result_reg[199:160] = sub_result1;
							result_reg[159:120] = sub_result2;
							result_reg[119:80] = sub_result3;
							result_reg[79:40] = sub_result4;
							result_reg[39:0] = sub_result5;
							overflow = sub_ovf1 || sub_ovf2 || sub_ovf3 || sub_ovf4 || sub_ovf5;
						end
						
						MULT_MATRIZ: begin
							result_reg[199:0] = multMA_result;
							overflow = multMA_ovf;
						end
						
						MULT_INT: begin
							result_reg[199:160] = multMI_result1;
							result_reg[159:120] = multMI_result2;
							result_reg[119:80] = multMI_result3;
							result_reg[79:40] = multMI_result4;
							result_reg[39:0] = multMI_result5;
							overflow = multMI_ovf1 || multMI_ovf2 || multMI_ovf3 || multMI_ovf4 || multMI_ovf5;
						end
						
						DETERMINANTE: begin
							//Matriz 2x2
							if (msize_reg == 0) begin
								result_reg[199:192] = det2x2_result;
								overflow = det2x2_ovf;
							end
							//Matriz 3x3
							else if (msize_reg == 1) begin
								result_reg[199:192] = det3x3_result;
								overflow = det3x3_ovf;
							end
							//Matriz 4x4
							else if (msize_reg == 2) begin
								result_reg[199:192] = det4x4_result;
								overflow = det4x4_ovf;
							end
							//Matriz 5x5
							else begin
								result_reg[199:192] = det5x5_result;
								overflow = det5x5_ovf;
							end
						end
						
						TRANSPOSTA: begin
							result_reg[199:160] = trans_result1;
							result_reg[159:120] = trans_result2;
							result_reg[119:80] = trans_result3;
							result_reg[79:40] = trans_result4;
							result_reg[39:0] = trans_result5;
							overflow = 0;
						end
					
						OPOSTA: begin
							result_reg[199:160] = opp_result1;
							result_reg[159:120] = opp_result2;
							result_reg[119:80] = opp_result3;
							result_reg[79:40] = opp_result4;
							result_reg[39:0] = opp_result5;
							overflow = opp_ovf1 || opp_ovf2 || opp_ovf3 || opp_ovf4 || opp_ovf5;
						end
						
						STORE_MATRIX1: begin
							//Organizaçao e salvamento dos dados
							case (position_reg)
								OFFSET0: begin
									matrix1_reg[199:184] = instruction[26:11];
								end
								
								OFFSET1: begin
									matrix1_reg[183:168] = instruction[26:11];
								end
								
								OFFSET2: begin
									matrix1_reg[167:152] = instruction[26:11];
								end
								
								OFFSET3: begin
									matrix1_reg[151:136] = instruction[26:11];
								end
								
								OFFSET4: begin
									matrix1_reg[135:120] = instruction[26:11];
								end
								
								OFFSET5: begin
									matrix1_reg[119:104] = instruction[26:11];
								end
								
								OFFSET6: begin
									matrix1_reg[103:88] = instruction[26:11];
								end
								
								OFFSET7: begin
									matrix1_reg[87:72] = instruction[26:11];
								end
								
								OFFSET8: begin
									matrix1_reg[71:56] = instruction[26:11];
								end
								
								OFFSET9: begin
									matrix1_reg[55:40] = instruction[26:11];
								end
								
								OFFSET10: begin
									matrix1_reg[39:24] = instruction[26:11];
								end
								
								OFFSET11: begin
									matrix1_reg[23:8] = instruction[26:11];
								end
								
								OFFSET12: begin
									matrix1_reg[7:0] = instruction[26:19];
								end
								
								default: begin
									state = IDLE;
								end
								
							endcase
							
						end
						
						
						STORE_MATRIX2: begin
							//Organizaçao e salvamento dos dados
							case (position_reg)
								OFFSET0: begin
									matrix2_reg[199:184] = instruction[26:11];
								end
								
								OFFSET1: begin
									matrix2_reg[183:168] = instruction[26:11];
								end
								
								OFFSET2: begin
									matrix2_reg[167:152] = instruction[26:11];
								end
								
								OFFSET3: begin
									matrix2_reg[151:136] = instruction[26:11];
								end
								
								OFFSET4: begin
									matrix2_reg[135:120] = instruction[26:11];
								end
								
								OFFSET5: begin
									matrix2_reg[119:104] = instruction[26:11];
								end
								
								OFFSET6: begin
									matrix2_reg[103:88] = instruction[26:11];
								end
								
								OFFSET7: begin
									matrix2_reg[87:72] = instruction[26:11];
								end
								
								OFFSET8: begin
									matrix2_reg[71:56] = instruction[26:11];
								end
								
								OFFSET9: begin
									matrix2_reg[55:40] = instruction[26:11];
								end
								
								OFFSET10: begin
									matrix2_reg[39:24] = instruction[26:11];
								end
								
								OFFSET11: begin
									matrix2_reg[23:8] = instruction[26:11];
								end
								
								OFFSET12: begin
									matrix2_reg[7:0] = instruction[26:19];
								end
								
								default: begin
									state = IDLE;
								end
								
							endcase
	
						end
						
						LOAD_MATRIXR: begin
							//Organizaçao e salvamento dos dados
							case (position_reg)
								OFFSET0: begin
									package_data_out_reg = result_reg[199:168];
								end
								
								OFFSET1: begin
									package_data_out_reg = result_reg[167:136];
								end
								
								OFFSET2: begin
									package_data_out_reg = result_reg[135:104];
								end
								
								OFFSET3: begin
									package_data_out_reg = result_reg[103:72];
								end
								
								OFFSET4: begin
									package_data_out_reg = result_reg[71:40];
								end
								
								OFFSET5: begin
									package_data_out_reg = result_reg[39:8];
								end
								
								OFFSET6: begin
									package_data_out_reg[31:24] = result_reg[7:0];
									package_data_out_reg[23:0] = 0;
								end
								
								default: begin
									state = IDLE;
								end
								
							endcase
								
						end
						
						CONVOLUTION_TRANS: begin
							result_reg[199:192] = convo_trans_resultX;
							result_reg[191:184] = convo_trans_resultY;
							result_reg[183:0] = 0;
							overflow = convo_trans_ovf;
						end
						
						CONVOLUTION_ROBERTS: begin
							result_reg[199:192] = convo_ro_resultX;
							result_reg[191:184] = convo_ro_resultY;
							result_reg[183:0] = 0;
							overflow = convo_ro_ovf;
						end
						
						default: begin
							state = IDLE;
						end
					endcase
					
					if (opcode_reg == CONVOLUTION_TRANS && ready_convo_trans) begin
						state = WRITEBACK;
					end
					else if (opcode_reg == CONVOLUTION_TRANS && ready_convo_trans) begin
						state = EXECUTE;
					end
					
					
					else if (opcode_reg == CONVOLUTION_ROBERTS && ready_convo_ro) begin
						state = WRITEBACK;
					end
					else if (opcode_reg == CONVOLUTION_ROBERTS && ready_convo_ro) begin
						state = EXECUTE;
					end
					
					
					else begin
						state = WRITEBACK;
					end
					
				end
				
				//Estado de sáida dos dados para o buffer principal
				WRITEBACK: begin
					operation_active = 0;
					state = IDLE;
					ready = 1;
				end
				
				default: begin
					state = IDLE;
				end
			endcase
		end
	end
endmodule