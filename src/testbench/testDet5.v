module testDet5();
    reg signed [199:0] matrix; //uma matriz 4x4 com 8 bits cada elemento
    reg rst;
    wire signed [7:0] det;
    wire ovf;

    det5 uut(
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

        matrix = 200'b00000010_00000011_00000010_00000101_00000110_00000011_00000010_00000010_00000001_00000100_00000011_00000001_00000011_00000010_00000001_00000001_00000001_00000000_00000110_00000101_00000010_00000001_00000010_00000001_00000011;
        //matriz é 2_3_2_5_6_3_2_2_1_4_3_1_3_2_1_1_1_0_6_5_2_1_2_1_3
        //det é -90, há overflow geral 

        #15; 
        matrix = 200'b00000001_00000001_00000001_00000001_00000001_00000001_00000001_00000001_00000000_00000001_00000001_00000010_00000001_00000001_00000001_00000000_00000000_00000001_00000001_00000001_00000001_00000001_00000000_00000001_00000001_;
        //matriz é 1_1_1_1_1_1_1_1_0_1_1_2_1_1_1_0_0_1_1_1_1_1_0_1_1
	//det é -1
    end
endmodule