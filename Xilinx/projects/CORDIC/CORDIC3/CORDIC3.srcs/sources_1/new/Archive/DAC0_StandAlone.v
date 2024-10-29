/*
    DAC0_StandAlone.v - stand-alone test of DAC0_DataGenerator on Mercury 2 Baseboard
*/

`timescale 1ns / 1ps

module DAC0_Standalone (input  Clock50MHz,
                        output test_point1,
                        output test_point2,
                        output dac_csn,
                        output dac_sdi,
                        output dac_ldac,
                        output dac_sck);

    wire pingTrigger;
    wire dacTrigger;
    wire dacBusy;
    wire [9:0] pingData;          
                 
    assign test_point1 = pingTrigger;
                     
    ClockDivider #(.Divisor (50_000_000 / 20))
 			   U1 (.FastClock (Clock50MHz),  
                   .Clear (0),      
                   .SlowClock (),  
				   .Pulse (pingTrigger));
   
    DAC0_DataGenerator U2 (.Clock50MHz (Clock50MHz),
                           .StartPing (pingTrigger),
                           .dac_busy (dacBusy),
                           .dac_trigger (dacTrigger),
                           .PingDone (test_point2),
                           .PingWords (pingData));

    Mercury2_DAC_Wrapper
                 U3 (.clk_50MHZ (Clock50MHz), 
                     .trigger (dacTrigger),   
                     .channel (0),   
                     .Din  (pingData), 
                     .Busy (dacBusy), 
                     .dac_csn  (dac_csn),
                     .dac_sdi  (dac_sdi), 
                     .dac_ldac (dac_ldac), 
                     .dac_sck  (dac_sck));    
endmodule
