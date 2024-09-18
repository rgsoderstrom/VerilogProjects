/*
    CORDIC3_Top.v
        - top-level architecture
*/

`timescale 1ns / 1ps

module CORDIC3_Top (input  Clock50MHz,
                    output test_point1,
                  //output test_point2,
                    output dac_csn,
                    output dac_sdi,
                    output dac_ldac,
                    output dac_sck);

    wire PingTrigger;
    wire startPing;
    wire pingDone;
	wire zeroRamp;
	wire inBlanking;
    wire startRamp;
    wire rampDone;
    wire dacBusy;
    wire trigger0, trigger1, dacTrigger;
    wire [9:0] DAC0;
    wire [9:0] DAC1;
    wire [9:0] Din;
   wire dacMuxSelect;
    
    reg [19:0] BlankingDelayCntr; 
    reg [7:0] State;
    
    localparam BlankingCounts = 50_000_000 * 0.001;
  //localparam BlankingCounts = 5
    
  //assign test_point1 = PingTrigger;
    assign test_point1 = pingDone;
    
    assign Din = (dacMuxSelect == 0 ? DAC0 : DAC1);
    assign dacTrigger = trigger0 | trigger1;
    
    ClockDivider #(.Divisor (50_000_000 / 20)) // (clock freq) / PRF
 			   U1 (.FastClock (Clock50MHz),  
                   .Clear (1'b0),      
                   .SlowClock (),  
				   .Pulse (PingTrigger));
   
    DAC0_DataGenerator U2 (.Clock50MHz  (Clock50MHz),
                           .StartPing   (startPing),
                           .dac_busy    (dacBusy),
                           .dac_trigger (trigger0),
                           .PingDone    (pingDone),
                           .PingWords   (DAC0));
    
    DAC1_DataGenerator U3 (.Clock50MHz (Clock50MHz),
                           .Blanking   (zeroRamp),
                           .InBlanking (inBlanking),
                           .StartRamp  (startRamp),
                           .dac_busy   (dacBusy),
                           .DAC        (DAC1),
                           .Done       (rampDone),
                           .dacTrigger (trigger1));
    
    Mercury2_DAC_Wrapper
  //Mercury2_DAC_Sim_Wrapper
                 U4 (.clk_50MHZ (Clock50MHz), 
                     .trigger   (dacTrigger),   
                     .channel   (dacMuxSelect),   
                     .Din       (Din), 
                     .Busy      (dacBusy), 
                     .dac_csn   (dac_csn),
                     .dac_sdi   (dac_sdi), 
                     .dac_ldac  (dac_ldac), 
                     .dac_sck   (dac_sck)); 
					 
	CORDIC3_Controller U5 (.Clock50MHz    (Clock50MHz),
						   .PingTrigger   (PingTrigger),
						   .PingDone      (pingDone),
						   .RampDone      (rampDone),
						   .BeginSending  (startPing),
                           .BeginBlanking (zeroRamp),
                           .InBlanking    (inBlanking),
                           .StartRamp     (startRamp),
                           .dacMuxSelect  (dacMuxSelect));
    
endmodule
