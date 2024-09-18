
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	



/*
	Testbench - for simple building blocks
*/	

`timescale 1ns / 1ps

module Testbench;

	reg clk;
	reg clr;
	
	wire slow;
	wire pulse;
  
    wire Zero;
   
   
    ClockDivider #(.Divisor (3))
 			   U1 (.FastClock (clk),  
                   .Clear (clr),       // active high
                   .SlowClock (slow),  // FastClock / (2 ^ Log2Divisor), 50% duty cycle
				   .Pulse (pulse));    // single pulse at SlowClock rate
     

    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");
        //$monitor ($time, " EventCounter.Count = %d, EventCounter.Zero = %d", U1.Count, U1.Zero);
        
        clk   = 1'b0;
        clr   = 1'b1; // clear is active high

        #20 clr = 0; 
    end

    //
    // clock period
    //
    always
        #5 clk <= ~clk; //toggle clk 
        

    //
    // the Event that is being counted
    //        
         
    //
    // test run
    //
    
    initial
    begin
        #500 $finish;
    end

endmodule
