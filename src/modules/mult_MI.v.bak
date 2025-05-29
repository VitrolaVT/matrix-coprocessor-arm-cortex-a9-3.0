module mult_MI(input signed [39:0] m_1,//linha da matriz
				 input signed [7:0] n,// número inteiro a multiplicar a matriz
				 input rst, //sinal de reset
				 output reg signed [39:0] m_out, //linha resultante da matriz
				 output reg signed ovf); //overflow
				 
	reg signed [74:0] temp_m; //array suficiente para conter bits de overflow (elementos de 8 bits, 5 no total)
	reg overflow;
				 
	always@(*) begin
		if (rst) begin
			ovf = 1'b0;
			temp_m = 75'b0;
		end
		else begin
			//multiplica cada número (5) pelo inteiro
			temp_m[74:60] = m_1[39:32] * n;
			temp_m[59:45] = m_1[31:24] * n;
			temp_m[44:30] = m_1[23:16] * n;
			temp_m[29:15] = m_1[15:8] * n;
			temp_m[14:0] = m_1[7:0] * n;
		end
		
		if (temp_m[16] != temp_m[7]) begin
			overflow = 1;
		end

		//else if (temp_m[16:7] == 10'b1111111111) begin
		//	overflow = 0;
		//end

		//else if (temp_m[16:7] == 10'b0000000000) begin
		//	overflow = 0;
		//end

		else if ((temp_m[16] == temp_m[7]) && (temp_m[15:8] != 8'b11111111 && temp_m[15:8] != 8'b00000000)) begin
			overflow = 1;
		end

		ovf = overflow;
		
		m_out = {temp_m[67:60], temp_m[52:45], temp_m[37:30], temp_m[22:15], temp_m[7:0]}; //Considera apenas do 8o bit a direita
	end
endmodule