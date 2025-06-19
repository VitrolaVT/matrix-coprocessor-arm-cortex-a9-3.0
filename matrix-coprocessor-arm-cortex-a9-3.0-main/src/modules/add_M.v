//Este módulo soma duas linhas, considerando cada uma com 40 bits
module add_M(input signed [39:0] m1, m2, //linhas da matriz 1 e 2
				 input rst, //sinal de reset
				 output reg signed [39:0] m_out, //linha final
				 output reg signed ovf); //overflow
				 
	reg signed [44:0] temp_m; //registrador com valor temporário do cálculo
	
	always@(*) begin
		if(rst) begin //se houver sinal de reset
			ovf = 1'b0; 
			temp_m = 45'b0;			
		end
		else begin //nõ
			temp_m[44:36] = {m1[39], m1[39:32]} + {m2[39], m2[39:32]}; //primeira soma
			temp_m[35:27] = {m1[31], m1[31:24]} + {m2[31], m2[31:24]}; //segunda soma
			temp_m[26:18] = {m1[23], m1[23:16]} + {m2[23], m2[23:16]}; //terceira soma
			temp_m[17:9]  = {m1[15], m1[15:8]}  + {m2[15], m2[15:8]};  //quarta soma
			temp_m[8:0]   = {m1[7], m1[7:0]}   + {m2[7], m2[7:0]};   //quinta soma

			ovf <= (temp_m[44] != temp_m[43]) ||  // Overflow no elemento 0
          (temp_m[35] != temp_m[34]) ||  // Overflow no elemento 1
          (temp_m[26] != temp_m[25]) ||  // Overflow no elemento 2
          (temp_m[17] != temp_m[16]) ||  // Overflow no elemento 3
          (temp_m[8]  != temp_m[7]);     // Overflow no elemento 4
		end
		
		m_out = {temp_m[43:36], temp_m[34:27], temp_m[25:18], temp_m[16:9], temp_m[7:0]}; //manda linha para saída
		
	end
	

endmodule