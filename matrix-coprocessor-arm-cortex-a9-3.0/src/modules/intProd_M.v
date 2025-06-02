//Módulo que calcula produto interno de linha de A e coluna de B
//Esse módulo é instanciado no módulo mult_M
module intProd_M(input signed [39:0] lin, col, //linha da matriz 1, coluna da matriz 2
				 input rst, //sinal de reset
				 output reg signed [7:0] n_out, //produto interno
				 output reg signed ovf); //overflow
	
	//Tem que aumentar o temp_n para 11bits devido a soma de 5 números de 8 bits
	reg signed [10:0] temp_n; //valor temporário do número para conter overflow
	
	//Instâncias do módulo multiplicador para poupar uso de DSP nas multiplicações
	multiplier multM5(lin[7:0], col[7:0], rst, prod5, ovf5);
	multiplier multM4(lin[15:8], col[15:8], rst, prod4, ovf4);
	multiplier multM3(lin[23:16], col[23:16], rst, prod3, ovf3);
	multiplier multM2(lin[31:24], col[31:24], rst, prod2, ovf2);
	multiplier multM1(lin[39:32], col[39:32], rst, prod1, ovf1);
	
	//Fios das sáidas dos módulos
	wire [7:0] prod1, prod2, prod3, prod4, prod5;
	wire ovf1, ovf2, ovf3, ovf4, ovf5;
	wire ovfP;
	assign ovfP = (ovf1 || ovf2 || ovf3 || ovf4 || ovf5); 
	
	always@(*) begin
		if(rst) begin //se houver sinal de reset
			temp_n = 0;		
			ovf = 0;
		end
		
		else begin //calcula produto interno
			//debug
			$display("Produtos: %d, %d, %d, %d, %d", 
				prod1, prod2, prod3, prod4, prod5);
			//temp_n recebe valor temporário do prod int
			temp_n = $signed(prod1) + $signed(prod2) + $signed(prod3) + 
                     $signed(prod4) + $signed(prod5);
			$display("Produto interno: %d", temp_n);
			
			//Se houve overflow (maior que 127, menor que -128 ou algum ovf parcial), manda sinal
			ovf = (temp_n > 127 || temp_n <  -128 || ovfP);
		end

		n_out = temp_n[7:0]; //Apenas envia bits menos significativos (8bits), independente de overflow
		$display("Produto interno FINAL: %d", n_out);
		
	end
	
endmodule