module multiplier(
    input signed [7:0] a, b, //fatores da multiplicação, 8 bits cada
    input rst, //sinal de reset
    output reg signed [7:0] prod, //produto da multiplicação
    output reg ovf
);

    reg signed [15:0] temp_prod; //registrador que guarda o produto no caso de overflow
    reg bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7;
    reg signed [15:0] temp1, temp2, temp3, temp4, temp5, temp6, temp7;

    always @(*) begin
        //atribui todos os bits para multiplicação
        bit7 = b[7];
        bit6 = b[6];
        bit5 = b[5];
        bit4 = b[4];
        bit3 = b[3];
        bit2 = b[2];
        bit1 = b[1];
        bit0 = b[0];

        //atribui 0 para todos os bits temporários
        {temp1, temp2, temp3, temp4, temp5, temp6, temp7} = 112'b0;

        //caso de reset
        if (rst) begin
            temp_prod = 16'b0;
            ovf = 0;
        end

        //se reset estiver off, multiplica
        else begin
            //algoritmo de multiplicação usando o shift
            temp1 = (bit0 == 1) ? a : 16'b0; //se aquele bit não for nulo, faz um shift a esquerda
            temp2 = (bit1 == 1) ? a << ((bit1 == 1)) : 16'b0;
            temp3 = (bit2 == 1) ? a << ((bit2 == 1) + 1) : 16'b0;
            temp4 = (bit3 == 1) ? a << ((bit3 == 1) + 2) : 16'b0;
            temp5 = (bit4 == 1) ? a << ((bit4 == 1) + 3) : 16'b0;
            temp6 = (bit5 == 1) ? a << ((bit5 == 1) + 4) : 16'b0;
            temp7 = (bit6 == 1) ? a << ((bit6 == 1) + 5) : 16'b0;

            temp_prod = temp1 + temp2 + temp3 + temp4 + temp5 + temp6 + temp7; //como no algoritmo trad de multiplicação, soma todas as linhas
        end
        
        ovf = (temp_prod > 127 || prod < -128);
        prod = temp_prod[7:0];

    end

endmodule