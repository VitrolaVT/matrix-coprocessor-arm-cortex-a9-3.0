module multiplier(
    input signed [7:0] a, b, //fatores da multiplicação, 8 bits cada
    input rst, //sinal de reset
    output reg signed [7:0] prod, //produto da multiplicação
    output reg ovf
);

    reg signed [15:0] temp_prod; //registrador que guarda o produto no caso de overflow
    reg bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7;
    reg signed [15:0] temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8;
	 reg [7:0] a_twocomp, b_twocomp; //complemento a 2 de a e b para multiplicação bit a bit

    always @(*) begin
		  //verifica se a e b são negativos para transformar em positivo para multiplicação
		  a_twocomp = (a[7] == 1) ? -a: a;
		  b_twocomp = (b[7] == 1) ? -b: b;
		 
        //atribui todos os bits para multiplicação
        bit7 = b_twocomp[7];
        bit6 = b_twocomp[6];
        bit5 = b_twocomp[5];
        bit4 = b_twocomp[4];
        bit3 = b_twocomp[3];
        bit2 = b_twocomp[2];
        bit1 = b_twocomp[1];
        bit0 = b_twocomp[0];
		 
		  
        //caso de reset
        if (rst) begin
            temp_prod = 16'b0;
            ovf = 0;
				temp1 = 0;
				temp2 = 0;
				temp3 = 0;
				temp4 = 0;
				temp5 = 0;
				temp6 = 0;
				temp7 = 0;
				temp8 = 0;
				a_twocomp = 0;
				b_twocomp = 0;
        end

        //se reset estiver off, multiplica
        else begin
            //algoritmo de multiplicação usando o shift,
				//se aquele bit não for nulo, faz um shift a esquerda
            temp1 = (bit0 == 1) ? a_twocomp : 16'b0; 
            temp2 = (bit1 == 1) ? a_twocomp <<< 1 : 16'b0;
            temp3 = (bit2 == 1) ? a_twocomp <<< 2 : 16'b0;
            temp4 = (bit3 == 1) ? a_twocomp <<< 3 : 16'b0;
            temp5 = (bit4 == 1) ? a_twocomp <<< 4 : 16'b0;
            temp6 = (bit5 == 1) ? a_twocomp <<< 5 : 16'b0;
            temp7 = (bit6 == 1) ? a_twocomp <<< 6 : 16'b0;
				temp8 = (bit7 == 1) ? a_twocomp <<< 7 : 16'b0;
				
				//como no algoritmo tradicional de multiplicação, soma todas as linhas
            temp_prod = temp1 + temp2 + temp3 + temp4 + temp5 + temp6 + temp7 + temp8;
				
				//Caso pelo menos um operando for negativo, transforma o resultado em negativo
				temp_prod = (a[7] ^ b[7]) ? -temp_prod : temp_prod;
				
				//se houve overflow (maior que 127 ou menor que -128), manda sinal
				ovf = (temp_prod > 127 || temp_prod < -128);
        end
        
        prod = temp_prod[7:0];

    end

endmodule