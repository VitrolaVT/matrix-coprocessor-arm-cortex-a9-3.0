module testDet3();
    reg clk;
    reg signed [71:0] matrix; //uma matriz 3x3 com 8 bits cada elemento
    reg rst;
    wire signed [7:0] det;
    wire ovf;

    det3 uut(
        .m(matrix),
        .rst(rst),
        .det(det),
        .ovf(ovf)
    );

    // Gera sinal de clock
    initial begin
        $display("Inicia clock");
        clk = 1'b0;
        forever #1 clk = ~clk;
    end
    
    // Gera sinal de reset
    initial begin
        $display("Inicia reset");
        rst = 1'b1;
        #10 rst = 1'b0;
    end
    
    // Testa os estímulos
    initial begin
        $display("Testa valores");
        $monitor("tempo=%3d, rst=%b, matriz=%72b, det=%8b(%3d), ovf=%b", 
                 $time, rst, matrix, det, det, ovf);
            
        #15; // Espera reset terminar

        matrix = 72'b00000001_00000010_00000010_00000000_00000100_00000001_00000011_00000101_00000001;
        //matrix = 1, 2, 2 | 0, 4, 1 | 3, 5, 1
        //resultado esperado det == -19
	//binário: 11101101
	
	#15
   	matrix = 72'b00000001_00000010_00000011_00000000_00000001_00000001_00000010_00000010_00000001;
    	//matrix = 1, 2, 3 | 0, 1, 1 | 2, 2, 1
    	//resultado esperado det: -3
    	//binário: 11111101
 	
	#20
	$finish;
    end
endmodule