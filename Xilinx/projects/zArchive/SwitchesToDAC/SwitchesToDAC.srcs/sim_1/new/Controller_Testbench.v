
/*
    Controller_Testbench.v
*/

/*
	Simulation system asserts hard "Clear" for first 100ns
*/	
    
`timescale 1ns / 1ps

module Controller_Testbench;

    reg Clock = 0;
    wire trigger;
    wire busy;
    wire load;
    wire chan;
    
    SwToDAC_controller U1 (.Clk50    (Clock),
                           .dac_busy (busy),
                           .channel (chan),
                           .load        (load),     // load switch latch
                           .dac_trigger (trigger)); // trigger DAC
    
    Mercury2_DAC_Sim U2 (.clk_50MHZ (Clock),   // -- 50MHz onboard oscillator
                         .trigger   (trigger), // -- assert to write Din to DAC
                         .channel (chan),      // -- 0 = DAC0/A, 1 = DAC1/B
                         .Din (),              // -- data for DAC
                         .Busy (busy));        // -- busy signal during conversion process
    

    //
    // clock period
    //
    always
        #5 Clock = ~Clock;  
        
    initial
    begin
        
        #112   // wait for "clear" to go away
        
        #200 $finish;

    end    
    
endmodule
