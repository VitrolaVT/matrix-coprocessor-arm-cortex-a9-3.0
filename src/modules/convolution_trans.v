module convolution_trans(
	input start, //Sinal de start do modulo
	input clk, rst, //Sinal de clock e reset respectivamante
	input [199:0] matrizA, //Matriz contendo o pixel e os valores em volta
	input [199:0] matrizB, //Matriz contendo o filtro
	output reg [7:0] sum_resultX, // Resultado do filtro no eixo X
	output reg [7:0] sum_resultY,  // Resultado do filtro no eixo Y
	output reg ready, //Sinal de termino do modulo
	output reg ovf //Registrador do overflow
);

	// Registradores intermediarios de 16 bits para acomodar os resultados da multiplicaçao 
	reg signed [15:0] reg00, reg01, reg02, reg03, reg04, reg05, reg06, reg07, reg08, reg09;
	reg signed [15:0] reg10, reg11, reg12, reg13, reg14, reg15, reg16, reg17, reg18, reg19;
	reg signed [15:0] reg20, reg21, reg22, reg23, reg24, reg25, reg26, reg27, reg28, reg29;
	reg signed [15:0] reg30, reg31, reg32, reg33, reg34, reg35, reg36, reg37, reg38, reg39;
	reg signed [15:0] reg40, reg41, reg42, reg43, reg44, reg45, reg46, reg47, reg48, reg49;

	// Registrador intermediário de 20 bits para acomodar a soma dos registradores de 16 bits
	reg signed [19:0] intermediate_reg_X; //Eixo X
	reg signed [19:0] intermediate_reg_Y; //Eixo Y
	
	// Maquina de estados simples para operar somas parcialmente 
	reg [1:0] state;
	parameter IDLE = 2'b00;
	parameter SUM = 2'b01;
	parameter DONE = 2'b10;

	// Contador para as somas parciais
	reg [4:0] counter;

	// Multiplicação combinatória
	always @(*) begin
		// Primeiros 25 registradores (multiplicação direta)
		reg00 = $signed(matrizA[199:192]) * $signed(matrizB[199:192]);
		reg01 = $signed(matrizA[191:184]) * $signed(matrizB[191:184]);
		reg02 = $signed(matrizA[183:176]) * $signed(matrizB[183:176]);
		reg03 = $signed(matrizA[175:168]) * $signed(matrizB[175:168]);
		reg04 = $signed(matrizA[167:160]) * $signed(matrizB[167:160]);
		reg05 = $signed(matrizA[159:152]) * $signed(matrizB[159:152]);
		reg06 = $signed(matrizA[151:144]) * $signed(matrizB[151:144]);
		reg07 = $signed(matrizA[143:136]) * $signed(matrizB[143:136]);
		reg08 = $signed(matrizA[135:128]) * $signed(matrizB[135:128]);
		reg09 = $signed(matrizA[127:120]) * $signed(matrizB[127:120]);
		reg10 = $signed(matrizA[119:112]) * $signed(matrizB[119:112]);
		reg11 = $signed(matrizA[111:104]) * $signed(matrizB[111:104]);
		reg12 = $signed(matrizA[103:96])  * $signed(matrizB[103:96]);
		reg13 = $signed(matrizA[95:88])   * $signed(matrizB[95:88]);
		reg14 = $signed(matrizA[87:80])   * $signed(matrizB[87:80]);
		reg15 = $signed(matrizA[79:72])   * $signed(matrizB[79:72]);
		reg16 = $signed(matrizA[71:64])   * $signed(matrizB[71:64]);
		reg17 = $signed(matrizA[63:56])   * $signed(matrizB[63:56]);
		reg18 = $signed(matrizA[55:48])   * $signed(matrizB[55:48]);
		reg19 = $signed(matrizA[47:40])   * $signed(matrizB[47:40]);
		reg20 = $signed(matrizA[39:32])   * $signed(matrizB[39:32]);
		reg21 = $signed(matrizA[31:24])   * $signed(matrizB[31:24]);
		reg22 = $signed(matrizA[23:16])   * $signed(matrizB[23:16]);
		reg23 = $signed(matrizA[15:8])    * $signed(matrizB[15:8]);
		reg24 = $signed(matrizA[7:0])     * $signed(matrizB[7:0]);

		// Últimos 25 registradores (multiplicação com transposta)
		reg25 = $signed(matrizA[199:192]) * $signed(matrizB[199:192]);
		reg26 = $signed(matrizA[191:184]) * $signed(matrizB[159:152]);
		reg27 = $signed(matrizA[183:176]) * $signed(matrizB[119:112]);
		reg28 = $signed(matrizA[175:168]) * $signed(matrizB[79:72]);
		reg29 = $signed(matrizA[167:160]) * $signed(matrizB[39:32]);
		
		reg30 = $signed(matrizA[159:152]) * $signed(matrizB[191:184]);
		reg31 = $signed(matrizA[151:144]) * $signed(matrizB[151:144]);
		reg32 = $signed(matrizA[143:136]) * $signed(matrizB[111:104]);
		reg33 = $signed(matrizA[135:128]) * $signed(matrizB[71:64]);
		reg34 = $signed(matrizA[127:120]) * $signed(matrizB[31:24]);
		
		reg35 = $signed(matrizA[119:112]) * $signed(matrizB[183:176]);
		reg36 = $signed(matrizA[111:104]) * $signed(matrizB[143:136]);
		reg37 = $signed(matrizA[103:96])  * $signed(matrizB[103:96]);
		reg38 = $signed(matrizA[95:88])   * $signed(matrizB[63:56]);
		reg39 = $signed(matrizA[87:80])   * $signed(matrizB[23:16]);
		
		reg40 = $signed(matrizA[79:72])   * $signed(matrizB[175:168]);
		reg41 = $signed(matrizA[71:64])   * $signed(matrizB[135:128]);
		reg42 = $signed(matrizA[63:56])   * $signed(matrizB[95:88]);
		reg43 = $signed(matrizA[55:48])   * $signed(matrizB[55:48]);
		reg44 = $signed(matrizA[47:40])   * $signed(matrizB[15:8]);
		
		reg45 = $signed(matrizA[39:32])   * $signed(matrizB[167:160]);
		reg46 = $signed(matrizA[31:24])   * $signed(matrizB[127:120]);
		reg47 = $signed(matrizA[23:16])   * $signed(matrizB[87:80]);
		reg48 = $signed(matrizA[15:8])    * $signed(matrizB[47:40]);
		reg49 = $signed(matrizA[7:0])     * $signed(matrizB[7:0]);
	end

	//Maquina de estados
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state = IDLE;
			intermediate_reg_X = 0;
			intermediate_reg_Y = 0;
			sum_resultX = 0;
			sum_resultY = 0;
			counter = 0;
		end 
		else begin
			case (state)
				IDLE: begin
					if (start) begin
						intermediate_reg_X = 0;
						intermediate_reg_Y = 0;
						counter = 0;
						ready = 0;
						state = SUM;
					end
					else begin
						state = IDLE;
					end
				end

				SUM: begin
					// Soma 3 registradores por ciclo de clock
					case (counter)
						0: begin
							intermediate_reg_X = reg00 + reg01 + reg02;
							intermediate_reg_Y = reg25 + reg26 + reg27;
						end

						1: begin
							intermediate_reg_X = intermediate_reg_X + reg03 + reg04;
							intermediate_reg_Y = intermediate_reg_Y + reg28 + reg29;
						end

						2: begin
							intermediate_reg_X = intermediate_reg_X + reg05 + reg06;
							intermediate_reg_Y = intermediate_reg_Y + reg30 + reg31;
						end

						3: begin
							intermediate_reg_X = intermediate_reg_X + reg07 + reg08;
							intermediate_reg_Y = intermediate_reg_Y + reg32 + reg33;
						end

						4: begin
							intermediate_reg_X = intermediate_reg_X + reg09 + reg10;
							intermediate_reg_Y = intermediate_reg_Y + reg34 + reg35;
						end

						5: begin
							intermediate_reg_X = intermediate_reg_X + reg11 + reg12;
							intermediate_reg_Y = intermediate_reg_Y + reg36 + reg37;
						end

						6: begin
							intermediate_reg_X = intermediate_reg_X + reg13 + reg14;
							intermediate_reg_Y = intermediate_reg_Y + reg38 + reg39;
						end

						7: begin
							intermediate_reg_X = intermediate_reg_X + reg15 + reg16;
							intermediate_reg_Y = intermediate_reg_Y + reg40 + reg41;
						end

						8: begin
							intermediate_reg_X = intermediate_reg_X + reg17 + reg18;
							intermediate_reg_Y = intermediate_reg_Y + reg42 + reg43;
						end
						
						9: begin
							intermediate_reg_X = intermediate_reg_X + reg19 + reg20;
							intermediate_reg_Y = intermediate_reg_Y + reg44 + reg45;
						end
						
						10: begin
							intermediate_reg_X = intermediate_reg_X + reg21 + reg22;
							intermediate_reg_Y = intermediate_reg_Y + reg46 + reg47;
						end
						
						11: begin
							intermediate_reg_X = intermediate_reg_X + reg23 + reg24;
							intermediate_reg_Y = intermediate_reg_Y + reg48 + reg49;
						end
						
						12: begin
							state = DONE;
						end
				
						default: begin
							state = DONE;
						end
					endcase
					
					counter = counter + 1;
					
				end
				
				DONE: begin
					if (intermediate_reg_X > 127 || intermediate_reg_X < -128) begin
						sum_resultX = 8'b11111111;
						ovf = 1;
					end
					else begin
						sum_resultX = intermediate_reg_X;
						ovf = 0;
					end
					
					if (intermediate_reg_Y > 127 || intermediate_reg_Y < -128) begin
						sum_resultY = 8'b11111111;
						ovf = 1;
					end
					else begin
						sum_resultY = intermediate_reg_Y;
						ovf = 0;
					end
					
					ready = 1;
					state = IDLE;
				end
	
				default: begin
					state = IDLE;
				end
				
			endcase
		end
	end
endmodule