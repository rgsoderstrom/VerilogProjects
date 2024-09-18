/*
    DAC1_StandAlone.v - stand-alone test of DAC1_DataGenerator on Mercury 2 Baseboard
*/

module DAC1_Standalone (input  Clock50MHz,
                        output test_point1,
                        output test_point2,
                        output dac_csn,
                        output dac_sdi,
                        output dac_ldac,
                        output dac_sck);
                                                
`timescale 1ns / 1ps

    wire pingTrigger;
    wire dacTrigger;
    wire dacBusy;
    wire [9:0] rampData;       
    
    reg [23:0] delayCounter = 0;  
    wire startRamp;
     
    assign startRamp = (delayCounter == 5 * 150_000);
                     
    assign test_point1 = pingTrigger;
    assign test_point2 = startRamp;
                     
    ClockDivider #(.Divisor (50_000_000 / 20))
 			   U1 (.FastClock (Clock50MHz),  
                   .Clear (0),      
                   .SlowClock (),  
				   .Pulse (pingTrigger));
   
    DAC1_DataGenerator U2 (.Clock50MHz (Clock50MHz),
                           .Blanking (pingTrigger),
                           .StartRamp (startRamp),
                           .dac_busy (dacBusy),
                           .DAC (rampData),
                           .Done (),
                           .dacTrigger (dacTrigger));
    
    Mercury2_DAC_Wrapper
  //Mercury2_DAC_Sim_Wrapper
                 U3 (.clk_50MHZ (Clock50MHz), 
                     .trigger (dacTrigger),   
                     .channel (0),   
                     .Din  (rampData), 
                     .Busy (dacBusy), 
                     .dac_csn  (dac_csn),
                     .dac_sdi  (dac_sdi), 
                     .dac_ldac (dac_ldac), 
                     .dac_sck  (dac_sck));    
    
    always @(posedge Clock50MHz)
    begin
        if (pingTrigger == 1)
            delayCounter <= 0;            
        else
            delayCounter <= delayCounter + 1;    
    end
    
endmodule


