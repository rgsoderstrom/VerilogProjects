/*
    DAC0_Testbench
*/

/************************************************************
	Simulation system asserts hard "Clear" for first 100ns
************************************************************/	

`timescale 1ns / 1ps

module DAC0_Testbench;

    reg  clk;    
    reg  PingTrigger;
    
    wire dacTrigger;
    wire dacBusy;
    wire [9:0] PingData;
    wire Done;
    
    DAC0_DataGenerator #(.RampIncr (1), .WindowDuration (2048))
                       DG (.Clock50MHz (clk),
                           .StartPing (PingTrigger),
                           .dac_busy (dacBusy),
                           .dac_trigger (dacTrigger),
                           .PingDone (Done),
                           .PingWords (PingData));

    Mercury2_DAC_Wrapper
                     DS (.clk_50MHZ (clk),        // -- 50MHz onboard oscillator
                         .trigger (dacTrigger),   // -- assert to write Din to DAC
                         .channel (1'b0), // -- 0 = DAC0/A, 1 = DAC1/B
                         .Din (PingData), // -- data for DAC
                         .Busy (dacBusy), // -- busy signal during conversion process
                         .dac_csn (),
                         .dac_sdi (), 
                         .dac_ldac (), 
                         .dac_sck ());
    

    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
//        $display ("U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input");
//        $monitor($time, ": DATA: %d, %d, %d, %d, %d", U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input); 

        clk = 1'b0;
        PingTrigger = 0;
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
        #123
            PingTrigger = 1;
        
        #20
            PingTrigger = 0;
            
//        #60000
//            PingTrigger = 1;
        
//        #20
//            PingTrigger = 0;

//        #10000 
//            $finish;
                   
    end
        
endmodule