

/*
	Simulation system asserts hard "Clear" for first 100ns
*/	



/*
	Testbench - for simple building blocks
*/	

`timescale 1ns / 1ps

module Testbench;

    localparam CounterBits = 8;   
  
	reg clk;
	reg clr;
	
	wire slow;
	wire pulse;
  
    reg [CounterBits-1:0] startingValue;
    reg load = 0;
    reg enable = 0;
    
    wire Zero;
    
    EventCountDown #(.Width (CounterBits)) 
            U1 (.InitialValue (startingValue),
				.Load (load),
				.Enable (enable),
				.Event (trigger),  // level sensitive, should be high for only one clock period
                .Clear (clr),      // active high
				.Clock (clk),
				.Zero (Zero));  // true when counter has reached zero

    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");
        $monitor ($time, " EventCounter.Count = %d, EventCounter.Zero = %d", U1.Count, U1.Zero);
        
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
    reg [2:0] triggerTimer;
    
    assign trigger = (triggerTimer == 0);
    
    initial
        triggerTimer = 0;
    
    always @ (posedge clk)
        triggerTimer <= triggerTimer - 1;
         
    //
    // test run
    //
    
    initial
    begin
        startingValue <= 8;

        #50  load <= 1;
        #10  load <= 0;
                     
        #150  enable = 1;   
        #2000 $finish;
    end

endmodule
