
/*
    Testbench_PulseGen
*/

/*
	Simulation system asserts hard "Clear" for first 100ns
*/	
    
`timescale 1ns / 1ps

module Testbench_PulseGen;

    reg  clk;
    reg  clr;
    reg  fastUD = 0;
    wire latchCount, enableUD;

    CLPWM_PulseGen #(.ClockFreq (941))
                 U1 (.Clock (clk), 
                     .Clear (clr),
                    // .FastUD     (fastUD),
                     .LatchCount (latchCount),
                     .EnableUD   (enableUD));


    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");
        clk = 1'b0;
        clr = 1'b1;
        
        #150 clr = 0;  // clear is active high
        
      //  #1600 fastUD = 1;
    end
    
    //
    // clock period
    //
    always
        #5 clk = ~clk; //toggle clk 
        

    //
    // test run
    //
    initial
        #2000 $finish;
            
endmodule
