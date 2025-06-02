module det4(
    input signed [127:0] matrix, //uma matriz 4x4 com 8 bits cada elemento
    input rst,
    output reg signed [7:0] det,
    output reg ovf
);

    //determinantes da 3x3 resultante
    wire signed [7:0] det1, det2, det3, det4; //determinante da 3x3 resultante eliminando cada elemento da primeira linha
    wire ovf_det1, ovf_det2, ovf_det3, ovf_det4; //respectivos overflows

    //temporarios para multiplicação intermediaria
    wire signed [7:0] n1, n2, n3, n4;
    wire ovf1, ovf2, ovf3, ovf4;

    //multiplicação intermediaria (elemento da matriz x o cofator)
    //o cofator é igual ao det(i,j) * (-1)^(i+j)
    //aqui a linha escolhida é sempre i = 1, portanto, (-1)^(1+j)
    multiplier m1(
        .a(matrix[127:120]),
        .b(det1),
        .rst(rst),
        .prod(n1),
        .ovf(ovf1)
    );
    
    multiplier m2(
        .a(matrix[119:112]),
        .b(-det2),
        .rst(rst),
        .prod(n2),
        .ovf(ovf2)
    );

    multiplier m3(
        .a(matrix[111:104]),
        .b(det3),
        .rst(rst),
        .prod(n3),
        .ovf(ovf3)
    );

    multiplier m4(
        .a(matrix[103:96]),
        .b(-det4),
        .rst(rst),
        .prod(n4),
        .ovf(ovf4)
    );

    //flags
    reg flagOvf128;

    //regs temporários
    reg signed [31:0] temp_det; //grande o suficiente

    //circuito de cálculo de determinante temporário (após eliminação de linhas e colunas)
	  det3 matriz1(
			.m({matrix[87:64], matrix[55:32], matrix[23:0]}), .rst(rst), .det(det1), .ovf(ovf_det1)
	  );
	  det3 matriz2(
			.m({matrix[95:88], matrix[79:56], matrix[47:24], matrix[15:0]}), .rst(rst), .det(det2), .ovf(ovf_det2)
	  );
	  det3 matriz3(
			.m({matrix[95:80], matrix[71:48], matrix[39:16], matrix[7:0]}), .rst(rst), .det(det3), .ovf(ovf_det3)
	  );
	  det3 matriz4(
			.m({matrix[95:72], matrix[63:40], matrix[31:8]}), .rst(rst), .det(det4), .ovf(ovf_det4)
	  );

    //cálculo de determinante da matriz 4x4
    always @(*) begin
        temp_det = n1 + n2 + n3 + n4; //realiza somatório do cofator(j) x elemento a(1,j)
        det = temp_det[7:0];

        ovf = (ovf_det1 || ovf_det2 || ovf_det3 || ovf_det4 || det2 == -128 || det4 == -128 || temp_det > 127 || temp_det < -128 ||
               ovf1 || ovf2 || ovf3 || ovf4);

    end

endmodule