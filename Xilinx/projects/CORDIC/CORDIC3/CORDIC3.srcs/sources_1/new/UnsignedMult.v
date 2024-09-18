/*
	UnsignedMult.v
*/
	
`timescale 1ns / 1ps

module UnsignedMult #(parameter WidthA = 8,
                                WidthB = 8,
                                WidthOut = 16)
                     (output [WidthOut-1:0] out, 
                      input  [WidthA-1:0]  a, 
                      input  [WidthB-1:0]  b,
					  input  Enable,
                      input  Clock);
    
    reg [WidthA + WidthB-1 : 0] fullProduct;
    assign out = fullProduct [WidthA+WidthB-1 : WidthA+WidthB-WidthOut];
    
    always @ (posedge Clock)
    begin
	    if (Enable == 1)
		begin
		    fullProduct <= a * b;                           
		end
	end 	
endmodule
