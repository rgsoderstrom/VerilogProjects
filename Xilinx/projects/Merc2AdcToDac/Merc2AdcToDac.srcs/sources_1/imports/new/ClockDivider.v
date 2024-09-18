/*
	ClockDivider
		- (Slow Clock frequency) = (Fast Clock frequency) / Divisor
*/

`timescale 1ns / 1ps

module ClockDivider #(parameter Divisor = 4) // default reduces Mercury 2's 50MHz clock to 12.5MHz
 					 (input  FastClock,  
                      input  Clear,      // active high
                      output SlowClock,  // (FastClock / Divisor), 50% duty cycle
					  output Pulse);     // periodic pulse, FastClock width and SlowClock rate
                     
    reg [31:0] Count;
       
    initial
        Count = 0;
                
    assign SlowClock = (Count < Divisor / 2);
	assign Pulse     = (Count == Divisor - 1); // keeps "Pulse" low when "Clear" asserted
	
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
