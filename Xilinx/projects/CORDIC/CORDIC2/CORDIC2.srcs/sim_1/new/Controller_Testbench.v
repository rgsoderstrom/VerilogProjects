/*
    RampGen_Testbench.v
*/    

/************************************************************
	Simulation system asserts hard "Clear" for first 100ns
************************************************************/	

`timescale 1ns / 1ps

module Controller_Testbench;

    reg  clk;

    wire dac_busy;
    wire dac_trigger;
    wire dac_channel;
    wire dac_mux_sel;
    
    CORDIC2_controller #(.Delay (8))
                       U1 (.Clock50MHz (clk),
                           .dac_busy (dac_busy),
                           .WindowStep (),
                           .MultSubEnable (),
                           .ShiftAddEnable (),
                           .dacChannel (dac_channel),
                           .dacMuxSelect (dac_mux_sel),
                           .dac_trigger (dac_trigger));                                                     

    Mercury2_DAC_Sim U2 (.clk_50MHZ (clk),
                         .trigger (dac_trigger),
                         .channel (dac_channel),
                         .Din (0),
                         .Busy (dac_busy), // -- busy signal during conversion process
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
//          clr = 1'b1;
//      #50 clr = 1'b0;
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
//        #135 trigger = 1'b1;
//        #10  trigger = 1'b0;
         
       // #835 trigger = 1'b1;
      //  #10  trigger = 1'b0;
         
       #1000 $finish;                   
    end
        

endmodule

