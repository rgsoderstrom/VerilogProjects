/*
    CORDIC3_Ctrl_Testbench
*/

`timescale 1ns / 1ps

module CORDIC3_Ctrl_Testbench;

    reg  clk;
    reg  pingTrigger = 0;
    reg  pingDone = 0; 
    reg  rampDone = 0;
    reg  inBlanking = 0;
    
    wire beginSending;
    wire beginBlanking;
    wire startRamp;
    wire muxSelect;
    
    CORDIC3_Controller U1 (.Clock50MHz    (clk),
						   .PingTrigger   (pingTrigger),
						   .PingDone      (pingDone),
						   .RampDone      (rampDone),
						   .InBlanking    (inBlanking),
						   .BeginSending  (beginSending),
                           .BeginBlanking (beginBlanking),
                           .StartRamp     (startRamp),
                           .dacMuxSelect  (muxSelect));
    
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
//        $display ("U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input");
//        $monitor($time, ": DATA: %d, %d, %d, %d, %d", U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input); 

          clk = 1'b0;
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
        #132 pingTrigger = 1;
        #20  pingTrigger = 0;
        
        #200 inBlanking = 1;
        #20  inBlanking = 0;

        #200 pingDone = 1;
        #20  pingDone = 0;

        #1000 rampDone = 1;
        #20  rampDone = 0;


//        #200 pingTrigger = 1;
//        #20  pingTrigger = 0;
        
//        #200 inBlanking = 1;
//        #20  inBlanking = 0;

//        #200 pingDone = 1;
//        #20  pingDone = 0;

//        #1000 rampDone = 1;
//        #20  rampDone = 0;





        #2000 $finish;
    end
    
endmodule
