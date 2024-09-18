
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	



`timescale 1ns / 1ps

module Sequencer_Testbench;

reg  clk;
reg  clearBar;
wire PWM1;
wire PWM2;
wire Dir1;
wire Dir2;

Sequencer #(.ClockDiv2 (12))
        U1 (.Clock50MHz (clk),
            .ClearBar (clearBar),   // active low
            .PWM1 (PWM1),
            .Dir1 (Dir1),
            .PWM2 (PWM2),
            .Dir2 (Dir2));
    
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        
        $monitor ($time, " seconds %d,  level1 = %d, load1 = %d, level2 = %d, load2 = %d", 
                    U1.seconds, U1.Level1, U1.Load1, U1.Level2, U1.Load2);
        
          clk = 1'b0;
          clearBar = 1'b0;
      #20 clearBar = 1'b1;
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
  
        #40000 $finish;
               
    end

endmodule
