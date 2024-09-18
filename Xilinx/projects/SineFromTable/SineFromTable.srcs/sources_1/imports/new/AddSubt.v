/*
	AddSubt.v
*/
	
`timescale 1ns / 1ps

module AddSubt #(parameter Width = 8)
                (output reg [Width-1:0] out, 
                 input  [Width-1:0]  a, 
                 input  [Width-1:0]  b,
				 input  Enable,
				 input  SubtFlag,
                 input  Clock);
    
    initial
        out = 'h7fff; // makes plots of Testbench results look better
        
    always @ (posedge Clock)
    begin
	    if (Enable == 1)
		    if (SubtFlag == 1)
				out <= 16'hffff - a - b;
		    else
				out <= a + b;                           
	end 
	
endmodule
