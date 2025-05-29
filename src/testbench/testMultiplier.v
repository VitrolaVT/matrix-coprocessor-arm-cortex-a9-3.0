`timescale 1ns / 1ps

module testMultiplier();
    reg rst;
    reg signed [7:0] a, b;  // 80 bits = 10 números de 8 bits
    wire signed [7:0] prod;    // 32 bits = 4 números de 8 bits
    wire ovf;
    
    // Instância do módulo de multiplicação

    multiplier uut(
        .a(a),
        .b(b),
        .rst(rst),
        .prod(prod),
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
        $monitor("tempo=%3d, rst=%b, a=%08b(%3d), b=%08b(%3d), prod=%08b(%3d), ovf=%b", 
                 $time, rst, a, a, b, b, prod, prod, ovf);
            
        #15; // Espera reset terminar
            
        // CASO 1: Valores pequenos positivos (sem overflow)
        a = 8'b11110001; //-15
        b = 8'b00000010; //2
        // prod esperado: -30
        // Resultado esperado: 11100010

        #20
        a = 8'b10000000; //(-128)
        b = 8'b11111111; //(-1)
        //vai dar overflow pois o prod esperado seria 128, que excede

        #20
        a = 8'b00000100; //4
        b = 8'b00000100; ///4
        //não dá overflow, prod esperado: 00010000 (16)

	#20
        a = 8'b00101000; //40
        b = 8'b11111101; ///-3
        //não dá overflow, prod esperado: 10001000 (-120)

	#20
        a = 8'b11101001; //-23
        b = 8'b00000010; ///2
        //não dá overflow, prod esperado: 11010010 (-46)

	#20
        a = 8'b01100100; //100
        b = 8'b00000010; ///2
        //vai dar overflow pois o prod esperado seria 200, que excede

	#20
        a = 8'b11111011; //-5
        b = 8'b11111101; //-3
        //não dá overflow, prod esperado: 00001111 (15)

	#20
        a = 8'b00101000; //40
        b = 8'b00101000; //40
        //vai dar overflow pois o prod esperado seria 160, que excede
	
	#20
        a = 8'b11000000; //-64
        b = 8'b00000010; //2
        //não dá overflow, prod esperado: 10000000 (-128)

	#20
        a = 8'b01000000; //64
        b = 8'b11111110; //-2
        //não dá overflow, prod esperado: 10000000 (-128)
	
	#20
        a = 8'b10000000; //-128
        b = 8'b11111110; //-2
        //vai dar overflow pois o prod esperado seria 256, que excede

	$finish;
    end
endmodule