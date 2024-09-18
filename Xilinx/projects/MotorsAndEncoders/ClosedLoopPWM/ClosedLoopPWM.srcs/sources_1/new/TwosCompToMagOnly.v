/*
    TwosCompToMagOnly
*/

`timescale 1ns / 1ps

module TwosCompToMagOnly #(parameter InputWidth = 8)
                          (input       [InputWidth-1:0] TwosCompIn,
                           output wire [InputWidth-2:0] Magnitude);

localparam mask = (1 << InputWidth - 1) - 1;
                           
assign Magnitude = (TwosCompIn [InputWidth-1] == 1'b1) ?
                   (TwosCompIn [InputWidth-2:0] ^ mask) + 1 :
                    TwosCompIn [InputWidth-2:0]; 
                           
endmodule
