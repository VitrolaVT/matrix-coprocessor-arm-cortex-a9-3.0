`timescale 1ns / 1ps
module testSub();
	reg rst;
	reg signed [39:0] m1, m2;
	wire signed [39:0] m_out;
	wire ovf;
	
	//instancia o módulo de subtração
	sub_M uut(.m1 (m1),
		  .m2 (m2),
		  .rst (rst),
		  .m_out (m_out),
		  .ovf (ovf)
	);
	
	
	//gera sinal de reset
	initial begin
		$display("Inicia reset");
		rst = 1'b1;
		#10
		rst = 1'b0;
	end
	
	//testa os stim
	initial begin
		$display("Testa valores");
		$monitor("tempo=%3d, rst=%b, m1=%40b, m2=%40b, m_out=%40b, ovf=%b", 
         $time, rst, m1, m2, m_out, ovf);
			
		#15 //espera reset ativar
			
		// VALORES POSITIVOS SEM OVF (SUBTRAÇÃO)
        // m1 tem os números = 50, 40, 30, 20, 10
        m1 = 40'b00110010_00101000_00011110_00010100_00001010;
        // m2 tem os números = 45, 35, 25, 15, 5
        m2 = 40'b00101101_00100011_00011001_00001111_00000101;
        // m_out deveria ser 40'b00000101_00000101_00000101_00000101_00000101 (5, 5, 5, 5, 5)

        #20;

        // VALORES NEGATIVOS SEM OVF (SUBTRAÇÃO)
        m1 = 40'b00110010_11011000_00011110_11101100_00001010; // [50, -40, 30, -20, 10]
        m2 = 40'b11010011_00100011_11100111_00001111_11111011; // [-45, 35, -25, 15, -5]
        // m_out deveria ser 40'b01011111_10110101_00110111_11011101_00001111 [95, -75, 55, -35, 15]

        #20;

        // NEGATIVOS E OVF (SUBTRAÇÃO)
        m1 = 40'b00110010_10000000_01111111_10011100_01100100; // [50, -128, 127, -100, 100]
        m2 = 40'b10011100_11111111_00000001_00011110_00011110; // [-100, -1, 1, 30, 30]
        // m_out deveria ser 40'b10001110_01111111_01111110_01111110_01000110 [150 (overflow), -127, 126, -130 (overflow), 70]
		
	end	
endmodule