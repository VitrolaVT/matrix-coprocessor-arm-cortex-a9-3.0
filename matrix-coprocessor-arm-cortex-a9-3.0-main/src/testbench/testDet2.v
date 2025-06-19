module testDet2();
    reg rst; //Sinal de reset
    reg signed [15:0] l1, l2; //Linhas 1 e 2
    wire signed [7:0] det; // Determinante

    det2 uut(
        .l1 (l1),
        .l2 (l2),
        .rst (rst), 
        .det (det)
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
        $monitor("tempo=%3d, rst=%b, l1=%16b, l2=%16b, det=%8b", 
            $time, rst, l1, l2, det);

   	 #15
   	 //Testa uma matriz com números positivos
     	 l1 = 16'b00000010_00000011; // [2, 3]
    	 l2 = 16'b00000100_00000010; // [4, 2]
    	 //Determinante: (2*2) - (3*4) = 4 - 12 = -8  binário: 11111000
	 
 	 #15
	 //Testa uma matriz com números negativos
    	 l1 = 16'b11111100_11111110; // [-4, -2]
    	 l2 = 16'b11111101_11111111; // [-3, -1]
    	 //Determinante: (-4)*(-1) - (-2)*(-3) = 4 - 6 = -2  binário: 11111110
	
	 #15
   	 //Testa uma matriz com números mistos
    	 l1 = 16'b11111100_00000011; // [-4, 3]
    	 l2 = 16'b00000010_11111110; // [2, -2]
    	 //Determinante: (-4)*(-2) - (3*2) = 8 - 6 = 2  binário: 00000010

	 #15
   	 //Testa uma matriz com diagonal nula
    	 l1 = 16'b00000000_00000001; // [0, 1]
    	 l2 = 16'b00000010_00000000; // [2, 0]
    	 //Determinante: (0*0) - (1*2) = 0 - 2 = -2  binário: 11111110

end

endmodule