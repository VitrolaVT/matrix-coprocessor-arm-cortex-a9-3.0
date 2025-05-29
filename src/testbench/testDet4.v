module testDet4();
    reg signed [127:0] matrix; //uma matriz 4x4 com 8 bits cada elemento
    reg rst;
    wire signed [7:0] det;
    wire ovf;

    det4 uut(
        .matrix(matrix),
        .rst(rst),
        .det(det),
        .ovf(ovf)
    );

    
    // Gera sinal de reset
    initial begin
        $display("Inicia reset");
        rst = 1'b1;
        #10 rst = 1'b0;
    end
    
    // Testa os estímulos
    initial begin
        $display("Testa valores");
        $monitor("tempo=%3d, rst=%b, matriz=%128b, det=%8b(%3d), ovf=%b", 
                 $time, rst, matrix, det, det, ovf);
            
        #15; // Espera reset terminar

        matrix = 128'b00000010_00000011_00000010_00000001_00000001_00000010_00000010_00000001_00000000_00000100_00000001_00000010_00000011_00000101_00000001_00000001;
        //matriz é 2_3_2_1_1_2_2_1_0_4_1_2_3_5_1_1
	//resultado esperado det == 1

        #20
        matrix = 128'b00000010_00000011_00000100_00000011_00000001_00000110_00000100_00000101_00000011_00000000_00001001_00001000_00000001_00000010_00000001_00000001;
        //matriz é 2_3_4_3_1_6_4_5_3_0_9_8_1_2_1_1
        //resultado esperado det == 37 >não há overflow geral< e >HÁ overflow intermediário<
    end
endmodule