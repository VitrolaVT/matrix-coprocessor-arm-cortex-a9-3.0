module det5(
	 input signed [199:0] matrix, //uma matriz 4x4 com 8 bits cada elemento
    input rst,
    output reg signed [7:0] det,
    output reg ovf
);

	 //cofatores
    reg signed [7:0] cof1, cof2, cof3, cof4, cof5;

    //determinantes da 3x3 resultante
    wire signed [7:0] det1, det2, det3, det4, det5; //determinante da 3x3 resultante eliminando cada elemento da primeira linha
    wire ovf_det1, ovf_det2, ovf_det3, ovf_det4, ovf_det5; //respectivos overflows

    //flags
    reg flagOvf128;

    //regs temporários
    reg [10:0] temp_det; //grande o suficiente para conter uma soma de 4 números de 8 bits

    //circuito de cálculo de determinante temporário (após eliminação de linhas e colunas)
    
	  det4 matriz1(
			.m({matrix[191:160], matrix[151:120], matrix[111:80], matrix[71:40], matrix[31:0]}), .rst(rst), .det(det1), .ovf(ovf_det1)
	  );
	  det4 matriz2(
			.m({matrix[199:192], matrix[183:152], matrix[143:112], matrix[103:72], matrix[63:32], matrix[23:0]}), .rst(rst), .det(det2), .ovf(ovf_det2)
	  );
	  det4 matriz3(
			.m({matrix[199:184], matrix[175:144], matrix[135:104], matrix[95:64], matrix[56:24], matrix[15:0]}), .rst(rst), .det(det3), .ovf(ovf_det3)
	  );
	  det4 matriz4(
			.m({matrix[199:176], matrix[167:136], matrix[127:96], matrix[87:56], matrix[47:15], matrix[7:0]}), .rst(rst), .det(det4), .ovf(ovf_det4)
	  );
	  det5 matriz5(
			.m({matrix[199:168], matrix[159:128], matrix[119:88], matrix[79:48], matrix[39:8]}), .rst(rst), .det(det5), .ovf(ovf_det5)
	  );
  

    //circuito de cálculo dos cofatores
    always @(*) begin
        if (det2 == -128 || det4 == -128) begin //se o determinante 2 ou 4for -128, ao multiplicar por -1, resultará em overflow
            flagOvf128 = 1;
        end
        //simplificando o cálculo de cofator, cof = det(i,j) * (-1)^(i+j)
        cof1 = det1; //i = 1, j = 1
        cof2 = -det2;//i = 1, j = 2
        cof3 = det3; //i = 1, j = 3
        cof4 = -det4;//i = 1, j = 4
		  cof5 = det5; //i = 1, j = 5
    end

    //cálculo de determinante da matriz 4x4
    always @(*) begin
        if (ovf_det1 == 1 || ovf_det2 == 1 || ovf_det3 == 1 || ovf_det4 == 1 || ovf_det5 || flagOvf128) begin //verifica situações de overflow
            det = 8'b0;
            ovf = 1;
        end

        else begin //se não houve overflow antes, realiza a soma para o det final e verifica overflow
            temp_det = det1 + det2 + det3 + det4 + det5;
            ovf = (temp_det > 127 || temp_det < -128) ? 1 : 0;
            det = temp_det[7:0]; 
        end
    end

endmodule