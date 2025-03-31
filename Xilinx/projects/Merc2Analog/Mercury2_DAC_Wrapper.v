/*
    Mercury2_DAC_Wrapper - extend dac_busy to allow for analog settling time
	
*/     

`timescale 1ns / 1ps

module Mercury2_DAC_Wrapper #(ClockFreq = 50_000_000, // Hz
                              SettlingTime = 2e-6)  // seconds
                     (input wire  clk_50MHZ,                      
					  input wire  trigger,
					  input wire  channel,
                      input wire  [9:0] Din,					 
                      output wire Busy,
					  output wire dac_csn,
					  output wire dac_sdi,
					  output wire dac_ldac,
					  output wire dac_sck); 
                                          
    localparam DelayClocks = ClockFreq * SettlingTime;
	wire DacBusy;

	Mercury2_DAC DAC (.clk_50MHZ (clk_50MHZ), 
                      .trigger (trigger),   
                      .channel (channel),   
                      .Din  (Din), 
                      .Busy (DacBusy), 
                      .dac_csn  (dac_csn),
                      .dac_sdi  (dac_sdi), 
                      .dac_ldac (dac_ldac), 
                      .dac_sck  (dac_sck));
	
    reg [9:0] delayCounter; // count clocks to wait for DAC output to settle
    
    wire AnalogSettling = delayCounter != 0;
    assign Busy = DacBusy | AnalogSettling;
    
    initial
    begin
        delayCounter <= 0;
    end

    always @(posedge clk_50MHZ)
    begin
        if (trigger == 1)
            delayCounter <= DelayClocks;
            
        else if (DacBusy == 0)
            if (delayCounter != 0)
                delayCounter <= delayCounter - 1;
    end
                
endmodule
