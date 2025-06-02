module trans_M(input signed [39:0] linha,//linha da matriz
				 input rst, //sinal de reset
				 output reg signed [39:0] m_out); //coluna da matriz resultante
				 
		reg signed [39:0] temp_m;
				 
		always@(*) begin
			if(rst) begin
				m_out = 40'b0; //caso haja reset, zera a coluna matriz resultante
			end
			else begin
				temp_m[39:32] = linha[39:32]; //elemento 1 da linha 1 se torna elemento 1 da coluna 1
				temp_m[31:24] = linha[31:24]; //elemento 2 da linha 1 se torna elemento 2 da coluna 1
				temp_m[23:16] = linha[23:16]; //elemento 3 da linha 1 se torna elemento 3 da coluna 1
				temp_m[15:8] = linha[15:8];   //elemento 4 da linha 1 se torna elemento 4 da coluna 1
				temp_m[7:0] = linha[7:0];     //elemento 5 da linha 1 se torna elemento 5 da coluna 1
			end 
			
			m_out = temp_m;

		end
	
endmodule