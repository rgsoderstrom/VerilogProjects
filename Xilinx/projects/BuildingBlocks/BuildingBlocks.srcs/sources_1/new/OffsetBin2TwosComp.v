/*
   OffsetBin2TwosComp.v
*/

`timescale 1ns / 1ps

module OffsetBin2TwosComp #(parameter Width = 4)
                           (input  [Width-1:0] offsetBinary,
                            output [Width-1:0] twosCompl);

localparam MaxNeg = 1 << (Width - 1);
assign twosCompl = MaxNeg + offsetBinary;

endmodule
