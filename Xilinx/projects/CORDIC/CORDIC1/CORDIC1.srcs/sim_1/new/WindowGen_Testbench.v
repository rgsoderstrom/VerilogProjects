/*
    WindowGen_Testbench.v
*/    

/************************************************************
	Simulation system asserts hard "Clear" for first 100ns
************************************************************/	

`timescale 1ns / 1ps

module WindowGen_Testbench;

    reg  clk;
    reg  clr;
    reg  trigger = 0;
    wire [3:0] window;
                        
    WindowGenerator #(.Width (4), .Duration (12))
                  U1 (.Clock (clk),
                      .Clear (clr),
                      .Trigger (trigger),
                      .Step (1'b1),
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
        #5 clk = ~clk; //toggle clk 
        
    //
    // test run
    //
    initial
    begin
        #135 trigger = 1'b1;
        #10  trigger = 1'b0;
         
        #835 trigger = 1'b1;
        #10  trigger = 1'b0;
         
        #2000 $finish;                   
    end
        
endmodule
