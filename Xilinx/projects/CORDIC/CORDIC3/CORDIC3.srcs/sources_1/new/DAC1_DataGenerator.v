
/*
    DAC1_DataGenerator.v -
        - generate TVG blanking and ramp for SONAR transmitter 
*/

`timescale 1ns / 1ps

module DAC1_DataGenerator (input Clock50MHz,
                           input Blanking,
                           input StartRamp,
                           input dac_busy,
                           output [9:0] DAC,
                           output InBlanking,
                           output Done,
                           output dacTrigger);
                           
    localparam BlankingVoltage = 0.025; // disable TVG amp
    
    localparam InitialVoltage  = 0.125; // minimum gain, for SONAR tests
  //localparam InitialVoltage  = 0.5; // for A/D tests with signal generator

    localparam FinalVoltage    = 1.325; // for maximum gain
  //localparam FinalVoltage    = 0.5;   // for A/D tests with signal generator

    localparam RiseTime        = 0.008; // seconds
    localparam CountsPerVolt   = 1023 / 2.048; // DAC hardware characteristic

    localparam BlankingCounts = BlankingVoltage * CountsPerVolt;
    localparam InitialCounts  = InitialVoltage  * CountsPerVolt;                               
    localparam FinalCounts    = FinalVoltage    * CountsPerVolt;                               
    localparam RampRate       = (FinalCounts - InitialCounts) / RiseTime; // counts per second
    localparam ClockDivisor   = 50e6 / RampRate;
                                     
    wire CountEnable;
    wire RampDone;

    wire LoadBlanking;
    wire LoadInitial;
    
    wire [9:0] RampCount;
    assign DAC = RampCount;
    assign Done = RampDone;
    
    DAC1_Controller U1 (.Clock (Clock50MHz),
                        .BeginBlanking (Blanking),
                        .StartRamp     (StartRamp),
                        .dac_busy      (dac_busy),
                        .CountEnable   (CountEnable),
                        .InBlanking    (InBlanking),
                        .RampDone      (RampDone),
                        .dac_trigger   (dacTrigger),
                        .LoadBlanking  (LoadBlanking),
                        .LoadInitial   (LoadInitial));

    ClockDivider #(.Divisor (ClockDivisor))
        U2 (.FastClock (Clock50MHz),  
            .Clear (0),  
            .SlowClock (), 
		    .Pulse (CountEnable));

    RampCounter #(.BlankingLevel (BlankingCounts),
                  .RampInitial (InitialCounts),
                  .RampFinal (FinalCounts)) 
              U3 (.Clock (Clock50MHz),
                  .Clear (0),
                  .LoadBlanking (LoadBlanking),
                  .LoadInitial  (LoadInitial),
                  .Enable (CountEnable),
                  .RampDone (RampDone),
                  .Ramp (RampCount));
                             
endmodule
