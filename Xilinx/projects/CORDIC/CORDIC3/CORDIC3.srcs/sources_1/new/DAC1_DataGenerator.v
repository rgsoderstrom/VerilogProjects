
/*
    DAC1_DataGenerator.v -
        - generate TVG blanking and ramp for SONAR transmitter 
*/

`timescale 1ns / 1ps

module DAC1_DataGenerator #(parameter DacWidth = 10)
                           (input wire Clock50MHz,

                            // DAC output level to turn off AD605
							input wire [DacWidth-1:0] BlankingLevel, // = BlankingVoltage * CountsPerVolt;

                            // DAC output level at beginning and end of TVG ramp														
							input wire [DacWidth-1:0] RampStartingLevel,  // = InitialVoltage  * CountsPerVolt;                               
							input wire [DacWidth-1:0] RampStoppingLevel,  // = FinalVoltage    * CountsPerVolt;
							           
							// set ramp rate                    
							input wire [31:0] RampRateClkDivisor, // = 50e6 / RampRate;
                           
                            input  wire  BeginBlanking, // command to load BlankingLevel into DAC
                            input  wire  BeginRamp,     // command to start ramping up TVG
                            output wire InBlanking,
                            output wire [DacWidth-1:0] DAC,
                            input  wire                dac_busy,
                            output wire                dac_trigger);
                           
                             
    wire CountEnable;
    wire RampDone;

    wire LoadBlanking;
    wire LoadInitial;
  //wire InBlanking;
    
    wire [DacWidth-1:0] RampCount;  //
    assign DAC = RampCount;
    
    DAC1_Controller U1 (.Clock (Clock50MHz),
                        .BeginBlanking (BeginBlanking),
                        .BeginRamp     (BeginRamp),
                        .dac_busy      (dac_busy),
                        .CountEnable   (CountEnable),
						.RampDone      (RampDone),
                        .dac_trigger   (dac_trigger),
                        .InBlanking    (InBlanking),
                        .LoadBlanking  (LoadBlanking),
                        .LoadInitial   (LoadInitial));

//*********************************************************************

//    ClockDivider #(.Divisor (RampRateClkDivisor))
//        U2 (.FastClock (Clock50MHz),  
//            .Clear (1'b0),  
//            .SlowClock (), 
//		    .Pulse (CountEnable));
		    
    reg [31:0] Count;
    reg Clear = 0;   // remove this if Clear input added
           
    initial
        Count = 0;
                
	assign CountEnable = (Count == 0);
	
    always @ (posedge Clock50MHz) 
        begin
            if (Clear == 1'b1)
                Count <= 0;
            
            else if (Count >= RampRateClkDivisor - 1)
                Count <= 0;
                
            else
                Count <= Count + 1'b1;
        end
		    
//*********************************************************************		    
		    		   
    RampCounter #(.Width (DacWidth))
              U3 (.BlankingLevel (BlankingLevel),
                  .RampInitial   (RampStartingLevel),
                  .RampFinal     (RampStoppingLevel), 
                  .Clock        (Clock50MHz),
                  .Clear        (1'b0),
                  .LoadBlanking (LoadBlanking),
                  .LoadInitial  (LoadInitial),
                  .Enable       (CountEnable),
                  .RampDone     (RampDone),
                  .Ramp         (RampCount));
                             
endmodule
