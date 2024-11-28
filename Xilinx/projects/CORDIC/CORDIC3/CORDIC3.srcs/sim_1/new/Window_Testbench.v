/*
    Window_Testbench.v - Window Generator test
*/    

/************************************************************
	Simulation system asserts hard "Clear" for first 100ns
************************************************************/	

`timescale 1ns / 1ps

module Window_Testbench;

    reg  clk;
    reg  clr;
    reg  trigger = 0;
    reg  [15:0] duration = 'd12_500;
    wire [11:0] window;
    wire        done;
                        
    WindowGenerator //#(.Width (12))      // bits. Default of 12 matches CORDIC                                                                      
                    U1 (.Clock50MHz (clk),
                        .Clear (clr),
                        .Trigger (trigger),
                        .Duration (duration),    // time at max level, clocks
                        .WindowDone (done),
                        .Window (window));

    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
//        $display ("U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input");
//        $monitor($time, ": DATA: %d, %d, %d, %d, %d", U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input); 

          clk = 1'b0;
          clr = 1'b1;
      #50 clr = 1'b0;
    end
    
    //
    // clock period
    //
    always
        #10 clk = ~clk; //toggle clk 
        
    //
    // test run
    //
    initial
    begin
        #135 trigger = 1'b1;
        #20  trigger = 1'b0;
         
//        #835 trigger = 1'b1;
//        #10  trigger = 1'b0;
         
        #3_000_000 $finish;                   
    end
        
endmodule
