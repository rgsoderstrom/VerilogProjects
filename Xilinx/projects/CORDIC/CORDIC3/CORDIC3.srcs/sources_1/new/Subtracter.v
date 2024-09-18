/*
	Subtracter.v
*/
	
`timescale 1ns / 1ps

module Subtracter #(parameter Width = 8)
                   (output reg [Width-1:0] out, 
                    input      [Width-1:0] a, 
                    input      [Width-1:0] b,
	  		        input Enable,
                    input Clock);
    
    always @ (posedge Clock)
    begin
	    if (Enable == 1)
		begin
		    out <= a - b;                           
		end
	end 	
endmodule
