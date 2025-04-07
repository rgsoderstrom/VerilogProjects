
/*
    DAC0_DataGenerator.v -
        - generate ping for SONAR transmitter 
*/

// only tested with default parameters

`timescale 1ns / 1ps

module DAC0_DataGenerator #(parameter Width = 16,        // 16 bits per fixed point number
                                      FractionBits = 10) // 10 fraction bits, 1_5_10 format
                           (input wire Clock50MHz,
                            input wire StartPing,
                            input wire dac_busy,
                            input wire [15:0] Duration,   // in clocks, duration at max level
                            input wire [15:0] Frequency,  // (FreqInHz / 190), see CORDIC.vhd
                            output wire dac_trigger,
                            output wire PingDone,
                            output wire [9:0] PingWords); //width determined by DAC hardware

    wire        [11:0]      cordicOut;
    wire signed [Width-1:0] signedCordicOut;
	
    wire                    windowStart;
    wire                    windowStep;
    wire                    windowDone;
    wire signed [Width-1:0] windowSamples;
    wire signed [Width-1:0] windowedSine;
	
	reg signed [2*Width-1:0] fullProduct; // = signedCordicOut * windowSamples;
	assign                   windowedSine = fullProduct >> FractionBits;
	
	// note hard-coded bit numbers
	assign signedCordicOut [10:0] = cordicOut [10:0];
	wire sb = ~cordicOut [11]; // sign bit
	assign signedCordicOut [15:11] = {sb, sb, sb, sb, sb};
	
	assign PingWords [8:0] =  windowedSine [10:2]; 
	assign PingWords [9]   = ~windowedSine [11]; 
	    
		
		
    wire EnableMultiply;
    wire EnableCordic;

    ClockDivider #(.Divisor (4)) 
 			   U1 (.FastClock (Clock50MHz),  
                   .Clear (1'b0),     // active high
                   .SlowClock (),  // (FastClock / Divisor), 50% duty cycle
				   .Pulse (windowStep));		   
		   
    WindowGenerator 
                  U2 (.Clock50MHz (Clock50MHz),
                      .Clear      (1'b0),
                      .Trigger    (windowStart),
                      .Duration   (Duration),
                      .Step       (windowStep),
                      .Done       (windowDone),
                      .Window     (windowSamples));

    Mercury2_CORDIC
        U3 (.clk_50MHz (Clock50MHz), .cor_en (EnableCordic), .phs_sft (Frequency), .outVal (cordicOut));

    DAC0_Controller 
        U4 (.Clock50MHz   (Clock50MHz), 
            .dac_busy     (dac_busy), 
            .StartPing    (StartPing),
            .WindowDone   (windowDone),
            .Done         (PingDone),
            .WindowStart  (windowStart), 
            .dac_trigger  (dac_trigger), 
            .EnableCordic (EnableCordic),
            .MultEnable   (EnableMultiply)); 
			
			
			
			
			

	always @ (posedge Clock50MHz)
	begin
		if (EnableMultiply == 1'b1)
			fullProduct <= signedCordicOut * windowSamples;
	end
	
endmodule
