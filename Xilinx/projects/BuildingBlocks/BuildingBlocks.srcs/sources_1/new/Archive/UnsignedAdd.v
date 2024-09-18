/*
	UnsignedAdd.v
*/
	
`timescale 1ns / 1ps

module UnsignedAdd #(parameter Width = 8)
                    (output reg [Width-1:0] out, 
                     input  [Width-1:0]  a, 
                     input  [Width-1:0]  b,
					 input  Enable,
                     input  Clock);
    
    always @ (posedge Clock)
    begin
	    if (Enable == 1)
            out <= a + b;                           
	end 
	
endmodule
