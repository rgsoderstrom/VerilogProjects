/*
    CORDIC3_Top.v
        - top-level module to drive SonarDAC on real hardware
*/

`timescale 1ns / 1ps

module CORDIC3_Top (input  Clock50MHz,

                   // input PingTrigger, // for testbench only
                      
                    output test_point1,
                  //output test_point2,
                    output dac_csn,
                    output dac_sdi,
                    output dac_ldac,
                    output dac_sck);

	localparam DacWidth = 10;
	localparam CountsPerVolt = 1023 / 2.048; // DAC characteristic
	
	localparam RampDur   = 0.020; // ramp duration, seconds
	localparam BlankLvl  = 0.05 * CountsPerVolt;
	localparam RStart    = 0.20 * CountsPerVolt;  
	localparam RStop     = 1.75 * CountsPerVolt;	
	
	localparam RampRate  = (RStop - RStart) / RampDur; 
	
	
    reg [15:0] WindowDuration = 50000;
    reg [15:0] Frequency = 40800 / 190;
	
	reg [DacWidth-1:0] BlankingLevel		= BlankLvl;
	reg [DacWidth-1:0] RampStartingLevel    = RStart;
	reg [DacWidth-1:0] RampStoppingLevel    = RStop;
	reg [31:0]         RampRateClockDivisor = 50e6 / RampRate;	
 
	wire PingTrigger;    //      ----------- restore after TB
	assign test_point1 = PingTrigger;
	
	SonarDAC 
			U1 (.Clock50MHz  (Clock50MHz),                    
                .BeginSequence (PingTrigger),
                   
                // DAC0 ping parameters 
                .Frequency    (Frequency),                       
                .PingDuration (WindowDuration),

                // DAC1 TVG parameters 
				.BlankingLevel        (BlankingLevel),		
				.RampStartingLevel    (RampStartingLevel),   
				.RampStoppingLevel    (RampStoppingLevel),    
				.RampRateClockDivisor (RampRateClockDivisor),
                  
              //output test_point1,
              //output test_point2,
                .dac_csn  (dac_csn),
                .dac_sdi  (dac_sdi),
                .dac_ldac (dac_ldac),
                .dac_sck  (dac_sck));

	ClockDivider #(.Divisor (50_000_000 / 20))
 				  (.FastClock (Clock50MHz),  
                   .Clear     (1'b0),  
                   .SlowClock (),  
				   .Pulse     (PingTrigger));

endmodule				  