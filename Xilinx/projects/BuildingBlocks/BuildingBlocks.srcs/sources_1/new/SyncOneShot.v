`timescale 1ns / 1ps

//
// SyncOneShot - synchronous one-shot
//

module SyncOneShot (input trigger, // pos edge trigger
                    input clk,
                    input clr,  // async, active high
                    output Q);  // pos pulse, one clock period long

	wire A, B, Bbar;
 
    FDC u1 (.D (trigger), .C (clk), .Q (A), .CLR (clr));
    FDC u2 (.D (A), .C (clk), .Q (B), .CLR (clr));
	not (Bbar, B);
	and (Q, A, Bbar);
	
endmodule


