/*
	ShiftAdd.v
*/
	
`timescale 1ns / 1ps

module ShiftAddr #(parameter Width = 8)
                  (output reg [Width-1:0] out, 
                   input      [Width-1:0] a, 
                   input      [Width-1:0] b,
	  		       input Enable,
                   input Clock);
    
    wire [Width-1:0] bb;
    assign bb = b >> 1;
    
    always @ (posedge Clock)
    begin
	    if (Enable == 1)
		begin
		    out <= a + bb;                           
		end
	end 	
endmodule
