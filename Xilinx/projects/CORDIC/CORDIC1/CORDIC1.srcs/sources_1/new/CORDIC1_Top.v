/*
    CORDIC1_Top
*/    

/*
	Version 1 - all hardware runs all the time
*/

`timescale 1ns / 1ps
`default_nettype none

module CORDIC1_Top (input  wire Clock50MHz, 
                    output wire test_point1,
                    output wire test_point2,
                    output wire dac_csn,  // -- DAC SPI Chip Select
                    output wire dac_sdi,  // -- DAC SPI MOSI
                    output wire dac_ldac, // -- DAC SPI Latch enable
                    output wire dac_sck); // -- DAC SPI CLOCK

    localparam PRF = 20; // pulses per second
    
    reg         [15:0] Frequency = 16'd212; // = freq / 190
    wire        [11:0] cordicOut;
 	wire signed [15:0] signedCordicOut;
	
    wire signed [15:0] windowSamples;
    wire signed [15:0] windowedSine;
	
    wire  [9:0] dac_input;
	assign dac_input [8:0] =  windowedSine [10:2];
	assign dac_input [9]   = ~windowedSine [11]; 
    
    wire dac_busy;
    wire dac_trigger;
	wire windowStart;
    wire windowStep;
     
    assign test_point1 = windowStart; 
    assign test_point2 = dac_trigger; // dac_busy;   
    
    Mercury2_CORDIC
        U1 (.clk_50MHz (Clock50MHz), .cor_en (1'b1), .phs_sft (Frequency), .outVal (cordicOut));
		
	assign signedCordicOut [10:0] = cordicOut [10:0];
	wire sb = ~cordicOut [11]; // sign bit
	assign signedCordicOut [15:11] = {sb, sb, sb, sb, sb};

	wire signed [31:0] fullProduct = signedCordicOut * windowSamples;
	assign windowedSine = fullProduct >> 10;

  //Mercury2_DAC_Sim
	Mercury2_DAC
        U3 (.clk_50MHZ (Clock50MHz), .trigger  (dac_trigger), 
            .channel (1'b0), 
            .Din (dac_input), .Busy (dac_busy), 
            .dac_csn (dac_csn), .dac_sdi (dac_sdi), .dac_ldac (dac_ldac), .dac_sck  (dac_sck));
            
    CORDIC1_controller 
        U4 (.Clk50 (Clock50MHz), .dac_busy (dac_busy), .dac_trigger (dac_trigger)); 
           
    ClockDivider #(.Divisor (4)) 
 			   U5 (.FastClock (Clock50MHz),  
                   .Clear (1'b0),     // active high
                   .SlowClock (),  // (FastClock / Divisor), 50% duty cycle
				   .Pulse (windowStep));
           
    ClockDivider #(.InitialValue (50_000_000 / PRF - 1000),
	               .Divisor (50_000_000 / PRF)) 
 			   U6 (.FastClock (Clock50MHz),  
                   .Clear (1'b0),     // active high
                   .SlowClock (),  // (FastClock / Divisor), 50% duty cycle
				   .Pulse (windowStart));
           
    WindowGenerator #(.Width (16), .Duration (5_000))
                  U7 (.Clock   (Clock50MHz),
                      .Clear   (0),
                      .Trigger (windowStart),
                      .Step    (windowStep),
					  .Done    (),
                      .Window  (windowSamples));
endmodule
