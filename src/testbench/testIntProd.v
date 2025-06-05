`timescale 1ns / 1ps

module testIntProd();
    reg rst;
    reg signed [39:0] lin, col;  // 80 bits = 10 números de 8 bits
    wire signed [7:0] prod;    // 32 bits = 4 números de 8 bits
    wire ovf;
    
    // Instância do módulo de multiplicação

    intProd_M uut(
        .lin(lin),
        .col(col),
        .rst(rst),
        .n_out(prod),
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
        $monitor("tempo=%3d, rst=%b, prod=%40b(%3d), ovf=%b", 
                 $time, rst, prod, prod, ovf);
            
        #15; // Espera reset terminar
            
        // CASO 1: Valores pequenos positivos (sem overflow)
        lin = 40'b00000001_00000010_00000011_00000010_00000101; //1, 2, 3, 2, 5
        col = 40'b00000010_00000011_00000010_00000001_00000001; //2, 3, 2, 1, 1
        // prod esperado: 21

        #20
        lin = 40'b11111111_11111111_11111111_11111111_11111111; //-1, -1, -1, -1, -1
        col = 40'b00000010_00000011_11111110_00000001_11111110; //2, 3, -2, 1, -2
        // prod esperado: -2

        #20
        lin = 40'b11111111_11111111_11111111_11111111_11111111; //vai dar overflow
        col = 40'b10000010_10000011_11111110_10000001_01111110;

	$finish;
    end
endmodule