/*
	UnsignedMult.v
	   - this version is not clocked
*/
	
`timescale 1ns / 1ps

module UnsignedMult #(parameter WidthA = 8,
                                WidthB = 8,
                                WidthOut = 16)
                     (output [WidthOut-1:0] out, 
                      input  [WidthA-1:0]  a, 
                      input  [WidthB-1:0]  b);
    
    wire [WidthA + WidthB-1 : 0] fullProduct;
    assign fullProduct = a * b;
    assign out = fullProduct [WidthA+WidthB-1 : WidthA+WidthB-WidthOut];
endmodule
