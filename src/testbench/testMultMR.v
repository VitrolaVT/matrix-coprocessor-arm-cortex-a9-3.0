`timescale 1ns / 1ps

module testMultMR();
    reg rst;
    reg signed [39:0] m_1; //40bits = 5 números de 8 bits
    reg signed [7:0] n; //numero real de 8 bits
    wire signed [39:0] m_out; // 40 bits = 5 números de 8 bits
    wire ovf;
    
    // Instância do módulo de multiplicação

    mult_MI uut(
        .m_1(m_1),
        .n(n),
        .rst(rst),
        .m_out(m_out),
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
        $monitor("tempo=%3d, rst=%b, lin=%40b, n=%8b, n_out=%40b, ovf=%b", 
                 $time, rst, m_1, n, m_out, ovf);
            
        #15; // Espera reset terminar
            
        // CASO 1: Valores pequenos positivos (sem overflow)
        // lin = [2,3,4,5,0] - apenas os 4 primeiros importam
        m_1 = 40'b00000010_00000011_00000100_00000101_00000000;
        // n = 3
        n = 8'b00000011;
        // m_out = [6, 9, 12, 15, 0]
        // Resultado esperado: 00000110_00001001_00001100_00001111_00000000

        #20;
        
        // CASO 2: Valores pequenos com negativos (sem overflow)
        // m_1 = [2,-3,4,-5,0]
        m_1 = 80'b00000010_11111101_00000100_11111011_00000000;
        // n = -3
        n = 8'b11111101;
        // m_out = [-6, 9, -12, 15, 0]
        // Resultado esperado: 11111010_00001001_11110100_00001111_00000000
        #20;
        
        // CASO 3: Valores próximos ao limite (com overflow)
        // m_1 = [10,11,12,13,0]
        m_1 = 80'b00001010_00001011_00001100_00001101_00000000;
        // n = 11
        n = 8'b00001011;
        // n_out = [110, 121, 132, 143, 0]
        // Resultado esperado: 01101110_01111001_10000100_10001111_00000000];
    end
endmodule