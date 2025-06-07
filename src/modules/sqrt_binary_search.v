module sqrt_binary_search (
	input clk, rst, //Sinais do clock e de reset respectivamente
	input start, //Sinal para começar a calcular a raiz quadrada
	input [7:0] sum_resultX, //Resultado do filtro no eixo X
	input [7:0] sum_resultY,  //Resultado do filtro no eixo Y
	output reg ready, //Sinal de término de cálculo do módulo(raiz quadrada)
	output reg [7:0] root //Raiz quadrada
);
	
	//Registradores intermediários para aplicar o algoritmo de busca binária
	reg [16:0] low, high, mid;
	reg [33:0] square;  // Precisa de 34 bits para guardar mid*mid
	
	//Máquina de estados para aplicar o algoritmo
	reg [1:0] state;
	localparam IDLE  = 2'b00;
	localparam BINARY_SEARCH  = 2'b01;
	localparam DONE  = 2'b10;
	
	
	//Registradores para pegar a soma das potências dos resultados dos filtros
	reg [15:0] pow_X;
	reg [15:0] pow_Y;
	reg [16:0] sum_pow;
	
	//Lógica combinatória
	always @(*) begin
		pow_X = sum_resultX * sum_resultX;
		pow_Y = sum_resultY * sum_resultY;
		sum_pow = pow_X + pow_Y;
		square = mid * mid;
	end
	
	//Máquina de estados
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			low = 0;
			high = 0;
			mid = 0;   
			square = 0; 
			root = 0;
			ready = 0; 
			state  <= IDLE;
		end 
		else begin
			case (state)
				IDLE: begin
					if (start) begin
						low = 0;
						high = sum_pow;
						ready = 0;
						state = BINARY_SEARCH;
					end
					
					else begin
						state = IDLE;
					end
				
				end
				
				BINARY_SEARCH: begin
					if (low <= high) begin
						mid = (low + high) >> 1; //mid = (low + high)/2
						
						if (square == sum_pow) begin
							state = DONE;
						end
						
						else if (square < sum_pow) begin
							low = mid + 1;
						end
						
						else begin
							high = mid - 1;
						end
					end
					
					else begin
						state = DONE;
					end
				end
				
				DONE: begin
					if (square == sum_pow) begin
						root = (mid > 255) ? 8'b11111111 : mid[7:0];
					end
					else begin
						root = (high > 255) ? 8'b11111111 : high[7:0];
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
