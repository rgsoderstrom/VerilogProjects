/*
	ClockDivider
		- (Slow Clock frequency) = (Fast Clock frequency) / (2 ^ Log2Divisor)
*/

`timescale 1ns / 1ps

module ClockDivider #(parameter Divisor = 4) // default reduces Mercury 2's 50MHz clock to 12.5MHz
 					 (input  FastClock,  
                      input  Clear,      // active high
                      output SlowClock,  // (FastClock / Divisor), 50% duty cycle
					  output Pulse);     // single pulse at SlowClock rate
                     
    reg [31:0] Count;
       
    initial
        Count = 0; // Divisor - 1000;
                
    assign SlowClock = (Count < Divisor / 2);
	assign Pulse     = (Count == 0);
	
    always @ (posedge FastClock) 
        begin
            if (Clear == 1'b1)
                Count <= 0;
            
            else if (Count == Divisor - 1)
                Count <= 0;
                
            else
                Count <= Count + 1'b1;
        end
                         
endmodule
