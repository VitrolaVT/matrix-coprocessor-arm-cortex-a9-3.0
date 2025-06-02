module mult_MI(input signed [39:0] m_1,//linha da matriz
				 input signed [7:0] n,// número inteiro a multiplicar a matriz
				 input rst, //sinal de reset
				 output reg signed [39:0] m_out, //linha resultante da matriz
				 output reg signed ovf); //overflow
				 
	reg signed [39:0] temp_m; //array temporario
	
	//Fios dos modulos de multiplicaçao 
	wire [7:0] prod1, prod2, prod3, prod4, prod5;
	wire ovf1, ovf2, ovf3, ovf4, ovf5;
	
	//Instancias dos modulos de multiplicaçao
	multiplier mult1(m_1[39:32], n, rst, prod1, ovf1);
	multiplier mult2(m_1[31:24], n, rst, prod2, ovf2);
	multiplier mult3(m_1[23:16] , n, rst, prod3, ovf3);
	multiplier mult4(m_1[15:8], n, rst, prod4, ovf4);
	multiplier mult5(m_1[7:0], n, rst, prod5, ovf5);

	always@(*) begin
		if (rst) begin
			ovf = 0;
			temp_m = 0;
		end
		else begin
			//Concatena os valores
			temp_m = {prod1, prod2, prod3, prod4, prod5};
			
			//Captura o overflow geral
			ovf = (ovf1 || ovf2 || ovf3 || ovf4 || ovf5);
					 
		end
		
		m_out = temp_m;
	end
endmodule