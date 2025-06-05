//O módulo mult_M encontra 4 números por vez, recebendo duas linhas de M1 e duas colunas de M2
module mult_M(input signed [199:0] lin, col, // linhas da matriz 1, colunas da matriz 2
		input rst, //sinal de reset
		output signed [199:0] n_out, // resultado da mult
		output signed ovf); // overflow
		
		wire signed [7:0] n_11, n_12, n_13, n_14, n_15, 
						  n_21, n_22, n_23, n_24, n_25,
						  n_31, n_32, n_33, n_34, n_35,
						  n_41, n_42, n_43, n_44, n_45,
						  n_51, n_52, n_53, n_54, n_55; // valores parciais dos produtos internos
		wire ovf1, ovf2, ovf3, ovf4, ovf5, 
			 ovf6, ovf7, ovf8, ovf9, ovf10, 
			 ovf11, ovf12, ovf13, ovf14, ovf15, 
			 ovf16, ovf17, ovf18, ovf19, ovf20, 
			 ovf21, ovf22, ovf23, ovf24, ovf25;
		
		// calculo dos produtos internos
		// primeira linha da matriz resultante (n_1x)
		intProd_M intprod1  (lin[199:160], col[199:160], rst, n_11, ovf1);   // Elemento (1,1)
		intProd_M intprod2  (lin[199:160], col[159:120], rst, n_12, ovf2);   // Elemento (1,2)
		intProd_M intprod3  (lin[199:160], col[119:80],  rst, n_13, ovf3);   // Elemento (1,3)
		intProd_M intprod4  (lin[199:160], col[79:40],   rst, n_14, ovf4);   // Elemento (1,4)
		intProd_M intprod5  (lin[199:160], col[39:0],    rst, n_15, ovf5);   // Elemento (1,5)

		// segunda linha da matriz resultante (n_2x)
		intProd_M intprod6  (lin[159:120], col[199:160], rst, n_21, ovf6);   // Elemento (2,1)
		intProd_M intprod7  (lin[159:120], col[159:120], rst, n_22, ovf7);   // Elemento (2,2)
		intProd_M intprod8  (lin[159:120], col[119:80],  rst, n_23, ovf8);   // Elemento (2,3)
		intProd_M intprod9  (lin[159:120], col[79:40],   rst, n_24, ovf9);   // Elemento (2,4)
		intProd_M intprod10 (lin[159:120], col[39:0],    rst, n_25, ovf10);  // Elemento (2,5)

		// terceira linha da matriz resultante (n_3x)
		intProd_M intprod11 (lin[119:80],  col[199:160], rst, n_31, ovf11);  // Elemento (3,1)
		intProd_M intprod12 (lin[119:80],  col[159:120], rst, n_32, ovf12);  // Elemento (3,2)
		intProd_M intprod13 (lin[119:80],  col[119:80],  rst, n_33, ovf13);  // Elemento (3,3)
		intProd_M intprod14 (lin[119:80],  col[79:40],   rst, n_34, ovf14);  // Elemento (3,4)
		intProd_M intprod15 (lin[119:80],  col[39:0],    rst, n_35, ovf15);  // Elemento (3,5)

		// quarta linha da matriz resultante (n_4x)
		intProd_M intprod16 (lin[79:40],   col[199:160], rst, n_41, ovf16);  // Elemento (4,1)
		intProd_M intprod17 (lin[79:40],   col[159:120], rst, n_42, ovf17);  // Elemento (4,2)
		intProd_M intprod18 (lin[79:40],   col[119:80],  rst, n_43, ovf18);  // Elemento (4,3)
		intProd_M intprod19 (lin[79:40],   col[79:40],   rst, n_44, ovf19);  // Elemento (4,4)
		intProd_M intprod20 (lin[79:40],   col[39:0],    rst, n_45, ovf20);  // Elemento (4,5)

		// Quinta linha da matriz resultante (n_5x)
		intProd_M intprod21 (lin[39:0],    col[199:160], rst, n_51, ovf21);  // Elemento (5,1)
		intProd_M intprod22 (lin[39:0],    col[159:120], rst, n_52, ovf22);  // Elemento (5,2)
		intProd_M intprod23 (lin[39:0],    col[119:80],  rst, n_53, ovf23);  // Elemento (5,3)
		intProd_M intprod24 (lin[39:0],    col[79:40],   rst, n_54, ovf24);  // Elemento (5,4)
		intProd_M intprod25 (lin[39:0],    col[39:0],    rst, n_55, ovf25);  // Elemento (5,5)
		
		
		// sinal de overflow geral (porta OR de todos os overflows individuais)
		assign ovf = ovf1 || ovf2 || ovf3 || ovf4 || ovf5 || 
					ovf6 || ovf7 || ovf8 || ovf9 || ovf10 ||
					ovf11 || ovf12 || ovf13 || ovf14 || ovf15 || 
					ovf16 || ovf17 || ovf18 || ovf19 || ovf20 ||
					ovf21 || ovf22 || ovf23 || ovf24 || ovf25;

		// concatenação de todos os 25 resultados em um unico array
		assign n_out = {n_11, n_12, n_13, n_14, n_15,
						n_21, n_22, n_23, n_24, n_25,
						n_31, n_32, n_33, n_34, n_35,
						n_41, n_42, n_43, n_44, n_45,
						n_51, n_52, n_53, n_54, n_55};

		
endmodule