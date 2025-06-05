module convolution_roberts(
	input start, //Sinal de start do modulo
	input clk, rst, //Sinal de clock e reset respectivamante
	input [31:0] matrizA, //Matriz contendo o pixel e os valores em volta
	input [31:0] matrizB, //Matriz contendo o filtro
	output reg [7:0] sum_resultX, // Resultado do filtro no eixo X
	output reg [7:0] sum_resultY,  // Resultado do filtro no eixo Y
	output reg ready, //Sinal de termino do modulo
	output reg ovf //Registrador do overflow
);

	// Registradores intermediarios de 16 bits para acomodar os resultados da multiplicaçao 
	reg signed [15:0] reg00, reg01, reg02, reg03;
	reg signed [15:0] reg04, reg05, reg06, reg07;
	
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
		// Primeiros 4 registradores (multiplicação direta)
		reg00 = $signed(matrizA[31:24]) * $signed(matrizB[31:24]);
		reg01 = $signed(matrizA[23:16]) * $signed(matrizB[23:16]);
		reg02 = $signed(matrizA[15:8]) * $signed(matrizB[15:8]);
		reg03 = $signed(matrizA[7:0]) * $signed(matrizB[7:0]);

		// Últimos 4 registradores (multiplicação para o eixo Y do Roberts)
		reg04 = $signed(matrizA[199:192]) * $signed(matrizB[23:16]);
		reg05 = $signed(matrizA[191:184]) * $signed(matrizB[31:24]);
		reg06 = $signed(matrizA[183:176]) * $signed(matrizB[7:0]);
		reg07 = $signed(matrizA[175:168]) * $signed(matrizB[15:8]);
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
							intermediate_reg_Y = reg04 + reg05 + reg06;
						end

						1: begin
							intermediate_reg_X = intermediate_reg_X + reg03;
							intermediate_reg_Y = intermediate_reg_Y + reg07;
						end
						
						3: begin
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