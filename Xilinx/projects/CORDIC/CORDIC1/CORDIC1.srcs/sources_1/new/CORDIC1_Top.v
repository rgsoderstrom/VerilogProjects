/*
    CORDIC1_Top
*/    

/*
	Version 1 - all hardware runs all the time
*/

`timescale 1ns / 1ps
`default_nettype none

module CORDIC1_Top (input  wire Clock50MHz, 
                    output wire test_point1, // IO [20]
                    output wire test_point2, // IO [21]
                    output wire dac_csn,  // -- DAC SPI Chip Select
                    output wire dac_sdi,  // -- DAC SPI MOSI
                    output wire dac_ldac, // -- DAC SPI Latch enable
                    output wire dac_sck); // -- DAC SPI CLOCK

    localparam PRF = 50; // pulses per second
    
    reg         [15:0] Frequency = 16'd212; // = freq / 190
    wire        [11:0] cordicOut;
// 	wire signed [15:0] signedCordicOut;
 	reg  signed [15:0] signedCordicOut;
	
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
        CORDIC (.clk_50MHz (Clock50MHz), .cor_en (1'b1), .phs_sft (Frequency), .outVal (cordicOut));
		
		
		
		
	// assign signedCordicOut [10:0] = cordicOut [10:0];
	// wire sb = ~cordicOut [11]; // sign bit
	// assign signedCordicOut [15:11] = {sb, sb, sb, sb, sb};

	wire sb = ~cordicOut [11]; // sign bit;
	
	always @ (posedge Clock50MHz) begin
		signedCordicOut [10:0] <= cordicOut [10:0];
		signedCordicOut [15:11] <= {sb, sb, sb, sb, sb};
	end



	// wire signed [31:0] fullProduct = signedCordicOut * windowSamples;
	// assign windowedSine = fullProduct >> 10;

	reg signed [31:0] r1;
	reg signed [31:0] r2;

	reg signed [31:0] fullProduct;// = signedCordicOut * windowSamples;
	assign windowedSine = fullProduct >> 10;

	always @ (posedge Clock50MHz) begin
	//	fullProduct <= signedCordicOut * windowSamples;
		r1 <= signedCordicOut * windowSamples;
		r2 <= r1;
		fullProduct <= r2;
	end



  //Mercury2_DAC_Sim
	Mercury2_DAC
       DAC (.clk_50MHZ (Clock50MHz), .trigger  (dac_trigger), 
            .channel (1'b0), 
            .Din (dac_input), .Busy (dac_busy), 
            .dac_csn (dac_csn), .dac_sdi (dac_sdi), .dac_ldac (dac_ldac), .dac_sck  (dac_sck));
            
    CORDIC1_controller 
       Ctrl (.Clk50 (Clock50MHz), .dac_busy (dac_busy), .dac_trigger (dac_trigger)); 
           
    ClockDivider #(.Divisor (4)) 
		WinStepClkDiv (.FastClock (Clock50MHz),  
					   .Clear (1'b0),     // active high
					   .SlowClock (),  // (FastClock / Divisor), 50% duty cycle
					   .Pulse (windowStep));
           
    ClockDivider #(.InitialValue (50_000_000 / PRF - 1000),
	               .Divisor (50_000_000 / PRF)) 
 	   PRF_ClkDiv (.FastClock (Clock50MHz),  
                   .Clear (1'b0),     // active high
                   .SlowClock (),  // (FastClock / Divisor), 50% duty cycle
				   .Pulse (windowStart));
           
    WindowGenerator #(.Width (16), .Duration (50_000))
           WindowGen (.Clock   (Clock50MHz),
                      .Clear   (1'b0),
                      .Trigger (windowStart),
                      .Step    (windowStep),
					  .Done    (),
                      .Window  (windowSamples));
endmodule
