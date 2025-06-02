//Módulo de controle para leitura, decodificação, execução e escrita de dados
module control_unit(
	input clk, rst, start, //Sinal de clock, reset e início de uma nova operação
	input clk_button, //Sinal de clock vindo do botão para depuração
	output reg ready, //Sinal para indicar que o resultado final está pronto
	output overflow_wire, //Sinal de overflow da operação
	output [2:0] state_output, //Estado atual
	output [2:0] op_code_o
	
	
);
	
	assign op_code_o = opcode_reg;
	
	//Definição dos estados da máquina de estados
	localparam IDLE = 3'b000;
	localparam FETCH1 = 3'b001;
	localparam FETCH2 = 3'b010;
	localparam FETCH3_DECODE = 3'b011;
	localparam EXECUTE = 3'b100;
	localparam WRITEBACK = 3'b101;
	localparam CLN = 3'b110;

	reg [2:0] state;
	assign state_output = state;
	reg overflow;
	assign overflow_wire = overflow;
	
	//Definição dos códigos de operação
	localparam SOMA = 3'b000;
	localparam SUBTRACAO = 3'b001;
	localparam MULT_MATRIZ = 3'b010;
	localparam MULT_INT = 3'b011;
	localparam DETERMINANTE = 3'b100;
	localparam TRANSPOSTA = 3'b101;
	localparam OPOSTA = 3'b110;

	
	//Instância da ferramenta de memória
	memory Memory(
		.clock(clk),
		.data(result_wire),
		.address(adrss),
		.wren(wren),
		.q(load)
	);

	//Registradores para endereço e ativação de escrita na memória
	reg [1:0] adrss;
	reg wren;
	reg [1:0] counter;
	wire [199:0] result_wire;
	reg counter1, counter2;
	
	assign result_wire = result_reg;
	
	//Fios para capturar os outputs dos módulos instanciados
	wire [199:0] load; //q output da memória
	//Soma
	wire [39:0] adder_result1, adder_result2, adder_result3, adder_result4, adder_result5; //Resultados da soma
	wire adder_ovf1, adder_ovf2, adder_ovf3, adder_ovf4, adder_ovf5; //Overflow da soma
	
	//Subtração
	wire [39:0] sub_result1, sub_result2, sub_result3, sub_result4, sub_result5; //Resultados da subtraçaõ
	wire sub_ovf1, sub_ovf2, sub_ovf3, sub_ovf4, sub_ovf5; //Overflow da subtraçaõ
	
	//Multiplicação entre matrizes
	wire [31:0] multMA_result1, multMA_result2, multMA_result3, multMA_result4, multMA_result5,
	multMI_result6, multMI_result7, multMI_result8, multMI_result9; //Resultados da multiplicação entre matrizes
	
	//Fios necessários para concatenacao
	wire [31:0] multMA_slice1, multMA_slice2, multMA_slice3, multMA_slice4, multMA_slice5,
	multMA_slice6, multMA_slice7, multMA_slice8, multMA_slice9;
	//assign multMA_slice1 = multMA_result1;
	//assign multMA_slice2 = multMA_result2;
	//assign multMA_slice3 = multMA_result3;
	//assign multMA_slice4 = multMA_result4;
	//assign multMA_slice5 = multMA_result5;
	//assign multMA_slice6 = multMA_result6;
	//assign multMA_slice7 = multMA_result7;
	//assign multMA_slice8 = multMA_result8;
	//assign multMA_slice9 = multMA_result9;
	
	wire multMA_ovf1, multMA_ovf2, multMA_ovf3, multMA_ovf4, multMA_ovf5,
	multMA_ovf6, multMA_ovf7, multMA_ovf8, multMA_ovf9; //Overflow da multiplicação entre matrizes
	
	//Multiplicação por inteiro
	wire [39:0] multMI_result1, multMI_result2, multMI_result3, multMI_result4, multMI_result5; //Resultados da multiplicação por inteiro
	wire multMI_ovf1, multMI_ovf2, multMI_ovf3, multMI_ovf4, multMI_ovf5; //Overflow da multiplicação por inteiro
	
	//Determinante 2x2
	wire [7:0] det2x2_result; //Resultado da determinante 2x2
	wire det2x2_ovf; //Overflow da determinante 2x2
	
	//Determinante 3x3
	wire [7:0] det3x3_result; //Resultado da determinante 3x3
	wire det3x3_ovf; //Overflow da determinante 3x3
	
	//Transposta
	reg [39:0] trans_result1, trans_result2, trans_result3, trans_result4, trans_result5; //Resultados da Transposta
	
	//Oposta
	wire [39:0] opp_result1, opp_result2, opp_result3, opp_result4, opp_result5; //Resultados da oposta
	wire opp_ovf1, opp_ovf2, opp_ovf3, opp_ovf4, opp_ovf5; //Overflow da oposta caso exista elemento igual a -128
	
	
	//Colunas temporárias da multplicaçao entre matrizes
	reg [39:0] m2_c0, m2_c1, m2_c2, m2_c3, m2_c4; //Primeira coluna até a última nessa ordem
	
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
	
	//Módulos de multiplicação entre matrizes para cada 2 linhas e 2 colunas					//Linha(h) x Coluna(c)
	//mult_M multi_MAL1(matrix1_reg[199:120], {m2_c0,m2_c1}, rst, multMA_result1, multMA_ovf1); //l1, l2 x c1, c2
	//mult_M multi_MAL2(matrix1_reg[199:120], {m2_c2,m2_c3}, rst, multMA_result2, multMA_ovf2); //l1, l2 x c3 c4
	//mult_M multi_MAL3(matrix1_reg[199:120], {m2_c4, 40'b0}, rst, multMA_result3, multMA_ovf3); //l1, l2 x c5
	//mult_M multi_MAL4(matrix1_reg[119:40], {m2_c0,m2_c1}, rst, multMA_result4, multMA_ovf4); //l3, l4 x c1, c2
	//mult_M multi_MAL5(matrix1_reg[119:40], {m2_c2,m2_c3}, rst, multMA_result5, multMA_ovf5); //l3, l4 x c3, c4
	//mult_M multi_MAL6(matrix1_reg[119:40], {m2_c4, 40'b0}, rst, multMA_result6, multMA_ovf6); //l3, l4 x c5
	//mult_M multi_MAL7({matrix1_reg[39:0], 40'b0}, {m2_c0,m2_c1}, rst, multMA_result7, multMA_ovf7); //l5 x c1, c2
	//mult_M multi_MAL8({matrix1_reg[39:0], 40'b0}, {m2_c2,m2_c3}, rst, multMA_result8, multMA_ovf8); //l5 x c3, c4
	//mult_M multi_MAL9({matrix1_reg[39:0], 40'b0}, {m2_c4, 40'b0}, rst, multMA_result9, multMA_ovf9); //l5 x c5
	
	
	//Módulos de multiplicação por inteiro para cada linha
	mult_MI multi_MIL1(matrix1_reg[199:160], matrix2_reg[7:0], rst, multMI_result1, multMI_ovf1);
	mult_MI multi_MIL2(matrix1_reg[159:120], matrix2_reg[7:0], rst, multMI_result2, multMI_ovf2);
	mult_MI multi_MIL3(matrix1_reg[119:80], matrix2_reg[7:0], rst, multMI_result3, multMI_ovf3);
	mult_MI multi_MIL4(matrix1_reg[79:40], matrix2_reg[7:0], rst, multMI_result4, multMI_ovf4);
	mult_MI multi_MIL5(matrix1_reg[39:0], matrix2_reg[7:0], rst, multMI_result5, multMI_ovf5);
	
	//Módulo de determinante 2x2
	det2 determinant2x2(matrix1_reg[199:184], matrix1_reg[159:144], rst, det2x2_result, det2x2_ovf);
	
	//Modulo de determinante 3x3
	det3 determinant3x3({matrix1_reg[199:176], matrix1_reg[159:136], matrix1_reg[119:96]}, rst, det3x3_result, det3x3_ovf);
	
	
	//Modulos de oposta para cada linha
	opp_M oppL1(matrix1_reg[199:160], rst, opp_result1, opp_ovf1);
	opp_M oppL2(matrix1_reg[159:120], rst, opp_result2, opp_ovf2);
	opp_M oppL3(matrix1_reg[119:80], rst, opp_result3, opp_ovf3);
	opp_M oppL4(matrix1_reg[79:40], rst, opp_result4, opp_ovf4);
	opp_M oppL5(matrix1_reg[39:0], rst, opp_result5, opp_ovf5);
	
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
		trans_result4[15:8] = matrix1_reg[55:38];
		trans_result4[7:0] = matrix1_reg[15:8];
		
		trans_result5[39:32] = matrix1_reg[167:160];
		trans_result5[31:24] = matrix1_reg[127:120];
		trans_result5[23:16] = matrix1_reg[87:80];
		trans_result5[15:8] = matrix1_reg[37:30];
		trans_result5[7:0] = matrix1_reg[7:0];
	end
	
	//Cria colunas de m2
	always@(*) begin
		m2_c0 = {matrix2_reg[199:192], matrix2_reg[159:152], matrix2_reg[119:112], matrix2_reg[79:72], matrix2_reg[39:32]};
		m2_c1 = {matrix2_reg[191:184], matrix2_reg[151:144], matrix2_reg[111:104], matrix2_reg[71:64], matrix2_reg[31:24]};
		m2_c2 = {matrix2_reg[183:176], matrix2_reg[143:136], matrix2_reg[103:96], matrix2_reg[63:56], matrix2_reg[23:16]};
		m2_c3 = {matrix2_reg[175:168], matrix1_reg[135:128], matrix2_reg[95:88], matrix2_reg[55:38], matrix2_reg[15:8]};
		m2_c4 = {matrix2_reg[167:160], matrix2_reg[127:120], matrix2_reg[87:80], matrix2_reg[37:30], matrix2_reg[7:0]};
	end
	
	//Registradores intermediários
	reg [1:0] msize_reg;
	reg [2:0] opcode_reg;
	reg [199:0] matrix1_reg, matrix2_reg;
	reg [199:0] result_reg;
	reg operation_active;

	always @(posedge clk_button or posedge rst) begin
		if (rst) begin
			state = IDLE;
			msize_reg = 0;
			opcode_reg = 0;
			matrix1_reg = 0;
			matrix2_reg = 0;
			result_reg = 0;
			overflow = 0;
			ready = 0;
			adrss = 0;
			wren = 0;
			operation_active = 0;
			counter = 0;
		end 
		else begin
			case (state)
				//Estado inicial IDLE para receber trocar o endereço antes do FETCH
				IDLE: begin
					adrss = 2'b00;
					if (start && !operation_active) begin
						operation_active = 1;
						wren = 0;
						ready = 0;
						state = FETCH1;
						counter = 0;
						counter1 = 0;
						counter2 = 0;
					end
					else begin
						state = IDLE;
					end
				end
				
				//Estado FETCH inicial para receber as intruções
				FETCH1: begin
					if (counter1) begin
						msize_reg = load[7:0];
						opcode_reg = load[15:8];
						adrss <= 2'b01;
						state = FETCH2;
					end
					else begin
						counter1 = counter1 + 1;
					end
				end
				
				//Estado FETCH para receber matriz 1
				FETCH2: begin
					counter1 = 0;
					
					if (counter2) begin
						matrix1_reg = load[199:0];
						adrss <= 2'b10;
						state = FETCH3_DECODE;
					end
					else begin
						counter2 = counter2 + 1;
					end
				end
				
				//Estado FETCH para receber matriz 2 com a decodificação
				FETCH3_DECODE: begin
					counter2 = 0;
					matrix2_reg = load[199:0];
					adrss <= 2'b11;
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
							result_reg[199:160] = {multMA_slice1[31:16], multMA_slice2[31:16], multMA_slice3[31:24]};
							result_reg[159:120] = {multMA_slice1[15:0], multMA_slice2[15:0], multMA_slice3[15:8]};
							result_reg[119:80] = {multMA_slice4[31:16], multMA_slice5[31:16], multMA_slice6[31:24]};
							result_reg[79:40] = {multMA_slice4[15:0], multMA_slice5[15:0], multMA_slice6[15:8]};
							result_reg[39:0] = {multMA_slice7[31:16], multMA_slice8[31:16], multMA_slice9[31:24]};
							overflow = multMA_ovf1 || multMA_ovf2 || multMA_ovf3 ||
										  multMA_ovf4 || multMA_ovf5 || multMA_ovf6 ||
										  multMA_ovf7 || multMA_ovf8 || multMA_ovf9;
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
							if (msize_reg == 0) begin
								result_reg = det2x2_result;
								overflow = det2x2_ovf;
							end
							else if (msize_reg == 1) begin
								result_reg = det3x3_result;
								overflow = det3x3_ovf;
							end
							else if (msize_reg == 2) begin
								result_reg = 2;
							end
							else begin
								result_reg = 3;
							end
						end
						
						TRANSPOSTA: begin
							result_reg[199:160] = trans_result1;
							result_reg[159:120] = trans_result2;
							result_reg[119:80] = trans_result3;
							result_reg[79:40] = trans_result4;
							result_reg[39:0] = trans_result5;
						end
					
						OPOSTA: begin
							result_reg[199:160] = opp_result1;
							result_reg[159:120] = opp_result2;
							result_reg[119:80] = opp_result3;
							result_reg[79:40] = opp_result4;
							result_reg[39:0] = opp_result5;
							overflow = opp_ovf1 || opp_ovf2 || opp_ovf3 || opp_ovf4 || opp_ovf5;
						end
					
						default: begin
							result_reg = 0;
						end
						
					endcase
					state = WRITEBACK;
				end
				
				//Estado de escrita do resultado na memória
				WRITEBACK: begin
					wren = 1;
					counter = counter + 1;
					if (counter == 3) begin
						operation_active = 0;
						ready = 1;
						state = CLN;
						wren = 0;
					end
					else begin
						state = WRITEBACK;
					end
				end
				
				CLN: begin
					adrss = 0;
					overflow = 0;
					opcode_reg = 0;
					result_reg = 0;
					matrix1_reg = 0;
					matrix2_reg = 0;
					state = IDLE;					
				end
				
				default: begin
					if (start && !operation_active) begin
						operation_active = 1;
						adrss = 0;
						wren = 0;
						ready = 0;
						state = FETCH1;
						counter = 0;
						counter1 = 0;
						counter2 = 0;
					end
					else begin
						state = IDLE;
					end
				end
			endcase
		end
	end
endmodule
