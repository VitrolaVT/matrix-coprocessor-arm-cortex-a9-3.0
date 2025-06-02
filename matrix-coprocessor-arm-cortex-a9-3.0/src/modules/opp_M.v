module opp_M(input signed [39:0] m_1, //linha da matriz
				 input rst, //sinal de reset
				 output reg signed [39:0] m_out, //linha resultante da matriz
				 output reg signed ovf); //overflow 
				
	reg signed [39:0] temp_m;
	reg overflow;
	
	always@(*) begin
		if (rst) begin
			temp_m = 40'b0;
			overflow = 0;
		end

		else begin
			//multiplica cada número (5) por -1, obtendo o oposto
			temp_m[39:32] = m_1[39:32] * (- 8'b1);
			temp_m[31:24] = m_1[31:24] * (- 8'b1);
			temp_m[23:16] = m_1[23:16] * (- 8'b1);
			temp_m[15:8] = m_1[15:8] * (- 8'b1);
			temp_m[7:0] = m_1[7:0] * (- 8'b1);
			
			//overflow sinalizado cada qualquer elemento seja -128(10000000 em binário)
			overflow = (m_1[39:32] == 8'b10000000) ||
						  (m_1[31:24] == 8'b10000000) ||
						  (m_1[23:16] == 8'b10000000) ||
						  (m_1[15:8]  == 8'b10000000) ||
						  (m_1[7:0]   == 8'b10000000);
			
		end
		
		ovf = overflow;
			
		m_out = {temp_m[39:32], temp_m[31:24], temp_m[23:16], temp_m[15:8], temp_m[7:0]};
	end
endmodule