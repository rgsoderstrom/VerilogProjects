/*
   TwosComp2OffsetBin.v
*/

`timescale 1ns / 1ps

module TwosComp2OffsetBin #(parameter Width = 4)
                           (input  [Width-1:0] twosCompl,
                            output [Width-1:0] offsetBinary);

localparam LargePos = 1 << (Width - 1); // one more than the largest positive number 
assign offsetBinary = twosCompl + LargePos;

endmodule
