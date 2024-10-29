
/*
	SonarDAC.v - combine Ping waveform generator and receiver TVG ramp generator
*/

`timescale 1ns / 1ps

module SonarDAC #(parameter DacWidth = 10)
                 (input Clock50MHz,
                    
                  input BeginSequence,
                     
                  // DAC0 ping parameters 
                  input [15:0] Frequency,                       
                  input [15:0] PingDuration,

                  // DAC1 TVG parameters 
				  input [DacWidth-1:0] BlankingLevel,        // = BlankingVoltage * CountsPerVolt;
				  input [DacWidth-1:0] RampStartingLevel,    // = InitialVoltage  * CountsPerVolt;                               
				  input [DacWidth-1:0] RampStoppingLevel,    // = FinalVoltage    * CountsPerVolt;                               
				  input [31:0]         RampRateClockDivisor, // = 50e6 / RampRate;
                    
                //output test_point1,
                //output test_point2,
                  output dac_csn,
                  output dac_sdi,
                  output dac_ldac,
                  output dac_sck);
					 

    wire startPing;
    wire pingDone;
	wire beginBlanking;
	wire inBlanking;
    wire beginRamp;
  //wire rampDone;
    wire dacBusy;
    wire trigger0, trigger1, dacTrigger;
    wire [DacWidth-1:0] DAC0;
    wire [DacWidth-1:0] DAC1;
    wire [DacWidth-1:0] Din;
    wire dacMuxSelect;
    
  //assign test_point1 = BeginSequence;
  //assign test_point1 = pingDone;
    
    assign Din = (dacMuxSelect == 0 ? DAC0 : DAC1);
    assign dacTrigger = trigger0 | trigger1;
    
    DAC0_DataGenerator U2 (.Clock50MHz  (Clock50MHz),
                           .StartPing   (startPing),
                           
                           .Frequency (Frequency),                      
                           .Duration  (PingDuration),
                           
                           .dac_trigger (trigger0),
						   .dac_busy    (dacBusy),
                           .PingDone    (pingDone),
                           .PingWords   (DAC0));
    
    DAC1_DataGenerator U3 (.Clock50MHz         (Clock50MHz),
						   .BlankingLevel      (BlankingLevel),        // = BlankingVoltage * CountsPerVolt;
						   .RampStartingLevel  (RampStartingLevel),    // = InitialVoltage  * CountsPerVolt;                               
						   .RampStoppingLevel  (RampStoppingLevel),    // = FinalVoltage    * CountsPerVolt;                               
						   .RampRateClkDivisor (RampRateClockDivisor), // = 50e6 / RampRate;                         
                           .BeginBlanking      (beginBlanking),
						   .InBlanking (inBlanking),
                           .BeginRamp  (beginRamp),                           
                           .DAC        (DAC1),
                           .dac_busy   (dacBusy),
                           .dacTrigger (trigger1));
    
    Mercury2_DAC_Wrapper
  //Mercury2_DAC_Wrapper_Sim
                 U4 (.clk_50MHZ (Clock50MHz), 
                     .trigger   (dacTrigger),   
                     .channel   (dacMuxSelect),   
                     .Din       (Din), 
                     .Busy      (dacBusy), 
                     .dac_csn   (dac_csn),
                     .dac_sdi   (dac_sdi), 
                     .dac_ldac  (dac_ldac), 
                     .dac_sck   (dac_sck)); 
					 
	reg [19:0] BC = 50_000_000 * 0.003; // blanking counts
	
	SonarDAC_Controller U5 (.Clock50MHz   (Clock50MHz),
	                       .BlankingCounts (BC),
						   .BeginSequence (BeginSequence),
						   .PingDone      (pingDone),
                           .BeginBlanking (beginBlanking),
                           .BeginPing     (startPing),
                           .InBlanking    (inBlanking),
                           .BeginRamp     (beginRamp),
                           .dacMuxSelect  (dacMuxSelect));    
endmodule