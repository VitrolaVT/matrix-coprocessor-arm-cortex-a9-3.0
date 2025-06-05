`timescale 1ns / 1ps
module testAdd(); 
	reg rst;
	reg signed [39:0] m1, m2;
	wire signed [39:0] m_out;
	wire ovf;
	
	//instancia o módulo de soma
	add_M uut(.m1 (m1),
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
			
		//VALORES POSITIVOS SEM OVF
		//m1 tem os números = 10, 20, 30, 40, 50
		m1 = 40'b00001010_00010100_00011110_00101000_00110010;
		//m2 tem os números = 5, 15, 25, 35, 45
		m2 = 40'b00000101_00001111_00011001_00100011_00101101;
		//m_out deveria ser 40'b00001111_00100011_00110111_01001011_01011111 (15, 35, 55, 75, 95)
		
		#20
		
		//VALORES NEGATIVOS SEM OVF
		m1 = 40'b00001010_11101100_00011110_11011000_00110010; // [10, -20, 30, -40, 50]
		m2 = 40'b11111011_00001111_11100111_00100011_11010011; // [-5, 15, -25, 35, -45]
		//m_out deveria ser m_out = 40'b00000101_11111011_00000101_11111011_00000101 [5, -5, 5, -5, 5]
		
		#20
		
		//NEGATIVOS E OVF
		m1 = 40'b01100100_10011100_01111111_10000000_00110010; // [100, -100, 127, -128, 50]
		m2 = 40'b00011110_00011110_00000001_11111111_10011100; // [30, 30, 1, -1, -100]
		//m_out deveria ser m_out = 40'b10000010_10111010_10000000_01111111_11001110
		
		
	end	
endmodule