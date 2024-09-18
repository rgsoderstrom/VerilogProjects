/*
	EventCountDown
*/

`timescale 1ns / 1ps

module EventCountDown #(parameter Width = 8) 
 					   (input [Width-1:0] LoadValue, // count down from this
					    input             Load,
						input             Enable,  // events ignored if (enable == 0)
					    input             Event,   // level sensitive, should be high for only one clock period
                        input             Clear,   // active high
						input             Clock,
						output            AtZero); // true when counter has reached zero
                     
    reg [Width - 1:0] Count;
    
    //******************************************************
    
    initial
        Count = 0;
                
    //******************************************************
    
	assign AtZero = (Count == 0);
	
    //******************************************************
    
    always @ (posedge Clock) 
        begin
            if (Clear == 1'b1)
                Count <= 0;
				
			else if (Load == 1'b1)
				Count <= LoadValue;

            else if (Count > 0 && Enable == 1 && Event == 1)
                Count <= Count - 1'b1;
        end
                         
endmodule
