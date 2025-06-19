//Módulo que calcula produto interno de linha de A e coluna de B
//Esse módulo é instanciado no módulo mult_M
module intProd_M(input signed [39:0] lin, col, //linha da matriz 1, coluna da matriz 2
				 input rst, //sinal de reset
				 output reg signed [7:0] n_out, //produto interno
				 output reg signed ovf); //overflow
	
	//Tem que aumentar o temp_n para 17bits
	reg [16:0] temp_n; //valor temporário do número para conter overflow
	reg overflow;
	
	always@(*) begin
		overflow = 0;

		if(rst) begin //se houver sinal de reset
			temp_n = 8'b0;			
		end
		
		else begin //calcula produto interno
			//temp_n recebe valor temporário do prod int, calculando linha(i) * coluna(j) do elemento a(i,j)
			temp_n = lin[7:0] * col[7:0] + lin[15:8] * col[15:8] + lin[23:16] * col[23:16] + lin[31:24] * col[31:24] + lin[39:32] * col[39:32];
			//overflow = (temp_n > 16'b0000000001111111 || temp_n < (-16'b0000000010000000)) ? 1'b1 : 1'b0; //se houve overflow, manda sinal
		end

		//verifica todos os casos de overflow
		
		if (temp_n[16] != temp_n[7]) begin
			overflow = 1;
		end

		//else if (temp_n[16:7] == 10'b1111111111) begin
		//	overflow = 0;
		//end

		//else if (temp_n[16:7] == 10'b0000000000) begin
		//	overflow = 0;
		//end

		else if ((temp_n[16] == temp_n[7]) && (temp_n[15:8] != 8'b11111111 && temp_n[15:8] != 8'b00000000)) begin
			overflow = 1;
		end

		ovf = overflow;
		n_out = temp_n[7:0]; //Apenas envia bits menos significativos (8bits), independente de overflow
		
	end
	
endmodule