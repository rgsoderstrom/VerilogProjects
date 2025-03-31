/*
	ClockDivider
*/

`timescale 1ns / 1ps
`default_nettype none

module ClockDivider #(parameter Divisor = 4)
 					 (input  wire FastClock,  
                      input  wire Clear,      // active high
                      output wire SlowClock,  // (FastClock / Divisor), 50% duty cycle
					  output wire Pulse);     // single pulse at SlowClock rate
                     
    reg [31:0] Count;
    reg [31:0] Div = Divisor;
       
    initial
        Count = 0;
                
    assign SlowClock = (Count < Div / 2);
	assign Pulse     = (Count == 0);
	
    always @ (posedge FastClock) 
        begin
            if (Clear == 1'b1)
                Count <= 0;
            
            else if (Count == Div - 1)
                Count <= 0;
                
            else
                Count <= Count + 1'b1;
        end
                         
endmodule
