/*
    PowerOnReset.v - provide a single pulse after power-up or ClearBar
*/

`timescale 1ns / 1ps

module PowerOnReset #(parameter Count = 150_000_000)
                     (input  wire Clock50MHz,
                      input  wire ClearBar,  // external pin pulled up to +5V
                      output wire Clear);

	reg [31:0] ResetCounter;

	initial
	   ResetCounter = Count;
	
    assign Clear = (ResetCounter == 32'h00000001);
	   
	always @ (posedge Clock50MHz)
	   if (ClearBar == 0)
	       ResetCounter <= Count;
	   else if (ResetCounter != 32'b0)
	       ResetCounter <= ResetCounter - 1;		
endmodule
