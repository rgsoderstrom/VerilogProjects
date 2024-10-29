
/*
	Testbench - for simple building blocks
*/	

/*
	Simulation system asserts hard "Clear" for first 100ns
*/	

`timescale 1ns / 1ps

module Testbench;

    reg clk = 0;
    reg clr = 0;

    reg Trigger = 0;
    wire Q;
    
    SyncOneShot U1 (.trigger (Trigger), // pos edge trigger
                    .clk (clk),
                    .clr (clr),  // async, active high
                    .Q (Q));  // pos pulse, one clock period long



    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");
        //$monitor ($time, " EventCounter.Count = %d, EventCounter.Zero = %d", U1.Count, U1.Zero);
        
        clk   = 1'b0;
     //   clr   = 1'b1; // clear is active high

        #20 clr = 0; 
    end

    //
    // clock period
    //
    always
        #10 clk <= ~clk; //toggle clk 
        
    //
    // test run
    //

    //integer i;
        
    initial
    begin
        #123 Trigger = 1; // between clock edges
        #50  Trigger = 0;
                        
        #200 $finish;
    end

endmodule
