module det2 (input signed [15:0] l1, l2, //duas linhas de 16bits cada, havendo 2 números por linha
				 input rst, //sinal de reset
				 output reg signed [7:0] det, //determinante resultante da matriz
				 output reg signed ovf //overflow 
);

   reg signed [16:0] temp_det; // array suficiente para o resultado

	always @(*) begin
		 if (rst) begin //se houver sinal de reset
			  temp_det = 0;
			  ovf = 0;
		 end

		 else begin //calcula determinante 2x2
			  //temp_det recebe valor temporário da determinante 2x2
			  temp_det = (l1[15:8] * l2[7:0]) - (l2[15:8] * l1[7:0]);
			  
			  //se houve overflow (maior que 127 ou menor que -128), manda sinal
			  ovf = (temp_det > 127 || temp_det <  -128);
		 end

		 det = temp_det[7:0];
end

endmodule