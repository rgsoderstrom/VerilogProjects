
/*
	AbsoluteValue.v - 2's complement to magnitude
*/


//`timescale 1ns / 1ps

//module AbsoluteValue #(parameter InputWidth = 8)
//                      (input wire [InputWidth-1 : 0] SignedInput,  
//	                   output reg [InputWidth-2 : 0] MagnitudeOutput);

//assign signBit = SignedInput [InputWidth - 1];
//assign magBits = SignedInput [InputWidth - 2 : 0];

//always @(*)
//    MagnitudeOutput = (signBit == 0 ? magBits : ~magBits + 1);

//endmodule	
