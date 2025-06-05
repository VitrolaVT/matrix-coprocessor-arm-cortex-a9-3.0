module testOppM();
    reg signed [39:0] m_1;//linha da matriz
    reg rst; //sinal de reset
    wire ovf; //sinal de overflow
    wire signed [39:0] m_out; //matriz inversa


opp_M uut(
    .m_1 (m_1),
    .rst (rst),
    .m_out (m_out),
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
        $monitor("tempo=%3d, rst=%b, m_1=%40b, m_out=%40b, ovf=%b", 
                 $time, rst, m_1, m_out, ovf);
        
        #15
        //Teste com números positivos
        //m_1 = [1, 3, 2, 5, 0]
        m_1 = 40'b00000001_00000011_00000010_00000101_00000000;
        //m_out = [-1, -3, -2, -5, 0]
        //m_out = 11111111_11111101_11111110_11111011_00000000

        #20
        //Teste com números negativos
        //m_1 = [-1, -3, -2, -5, 0]
        m_1 = 40'b11111111_11111101_11111110_11111011_00000000;
        //m_out = [1, 3, 2, 5, 0]
        //m_out = 00000001_00000011_00000010_00000101_00000000

	#20
        //Teste com overflow(-128)
        //m_1 = [-128, 0, 0, 0, 0]
        m_1 = 40'b10000000_00000000_00000000_00000000_00000000;
        //m_out = [-128, 0, 0, 0, 0]
        //m_out = 10000000_00000000_00000000_00000000_00000000

    end

endmodule