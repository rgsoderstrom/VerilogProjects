/*
	UnsignedMult.v
*/
	
`timescale 1ns / 1ps

module UnsignedMult #(parameter WidthA = 8,
                                WidthB = 8,
                                WidthOut = 16)
                     (output wire [WidthOut-1:0] out, 
                      input wire  [WidthA-1:0]  a, 
                      input wire  [WidthB-1:0]  b,
					  input wire  Enable,
                      input wire  Clock);
    
    reg [WidthA + WidthB-1 : 0] fullProduct;
    assign out = fullProduct [WidthA+WidthB-1 -: WidthOut];
//  assign out = fullProduct [WidthA+WidthB-1 : WidthA+WidthB-WidthOut];
    
    always @ (posedge Clock)
    begin
	    if (Enable == 1)
		begin
		    fullProduct <= a * b;                           
		end
	end 	
endmodule
