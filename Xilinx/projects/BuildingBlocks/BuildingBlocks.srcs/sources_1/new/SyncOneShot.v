`timescale 1ns / 1ps

//
// SyncOneShot - synchronous one-shot
//

module SyncOneShot (input  wire trigger, // low->high triggers, not required to be sync to clk
                    input  wire clk,
                    input  wire clr,  // async, active high
                    output wire Q);  // pos pulse, one clock period long

	wire A, B, Bbar;
 
    FDC u1 (.D (trigger), .C (clk), .Q (A), .CLR (clr));
    FDC u2 (.D (A), .C (clk), .Q (B), .CLR (clr));
	not (Bbar, B);
	and (Q, A, Bbar);
	
endmodule


