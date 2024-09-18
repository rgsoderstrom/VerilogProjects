
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
	
	reg [7:0] inputByte = 0;
    reg load = 0;
    reg getNext = 0;
    wire empty;
	wire [7:0] outputByte;
    
	Register #(.Width (8))
	       U1 (.Input (inputByte),
               .Clr (clr),   // sync, active high
               .Clk (clk),   // pos edge triggered
               .Load (load),
  			   .Empty (empty),     // ready to load,
               .Output (outputByte),
               .GetNext (getNext));
	
	
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
    // test run
    //
    
    initial
    begin
        #112 inputByte = 8'h12;
        #30  load = 1;
        #10  load = 0;
        
        #100 getNext = 1;
        #10  getNext = 0;
                    
        #20  inputByte = 8'h34;
        #30  load = 1;
        #10  load = 0;
        
        #100 getNext = 1;
        #10  getNext = 0;
                    
        #100 $finish;
    end

endmodule
