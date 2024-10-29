/*
    DAC1_Testbench
*/

/************************************************************
	Simulation system asserts hard "Clear" for first 100ns
************************************************************/	

`timescale 1ns / 1ps

module DAC1_Testbench;

    localparam BlankingVoltage = 0.025; // disable TVG amp    
    localparam InitialVoltage  = 0.125; // minimum gain, for SONAR tests
    localparam FinalVoltage    = 1.325; // for maximum gain

    localparam RiseTime        = 0.015; // seconds
    localparam CountsPerVolt   = 1023 / 2.048; // (MaxCounts / MaxVolts), DAC hardware characteristic

    localparam FC = FinalVoltage   * CountsPerVolt; 
    localparam IC = InitialVoltage * CountsPerVolt; 
    
    reg [9:0]  BlankingCounts = BlankingVoltage * CountsPerVolt;
    reg [9:0]  RampStartingLevel  = IC;                               
    reg [9:0]  RampStoppingLevel  = FC;     
                              
    localparam RampRate       = (FC - IC) / RiseTime; // counts per second
    reg [31:0] ClockDivisor   = 50e6 / RampRate;


    reg  clk;    
    
    wire dacTrigger;
    wire dacBusy;
    wire [9:0] GainWord; // controls AD605 TVG
    
    reg beginBlanking = 0;
    reg beginRamp = 0;
    
    DAC1_DataGenerator 
                 DataGen (.Clock50MHz (clk),
				 
						  .BlankingLevel      (BlankingCounts),
				          .RampStartingLevel  (RampStartingLevel), 
				          .RampStoppingLevel  (RampStoppingLevel),   
				          .RampRateClkDivisor (ClockDivisor),
				 
                          .BeginBlanking (beginBlanking),
                          .BeginRamp     (beginRamp),
                          .dac_busy      (dacBusy),
                          .DAC           (GainWord),
                          .dacTrigger    (dacTrigger));

    Mercury2_DAC_Wrapper_Sim
                    DAC (.clk_50MHZ (clk),        // -- 50MHz onboard oscillator
                         .trigger (dacTrigger),   // -- assert to write Din to DAC
                         .channel (1'b0), // -- 0 = DAC0/A, 1 = DAC1/B
                         .Din (GainWord), // -- data for DAC
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
            beginBlanking = 1;
        
        #20
            beginBlanking = 0;
            
        #1000
            beginRamp = 1;
        
        #20
            beginRamp = 0;


        #20_000_000      
            ClockDivisor = ClockDivisor / 2;  
            beginBlanking = 1;
        
        #20
            beginBlanking = 0;
            
        #1000
            beginRamp = 1;
        
        #20
            beginRamp = 0;
        
       #20_000_000
            $finish;
                   
    end
        
endmodule
