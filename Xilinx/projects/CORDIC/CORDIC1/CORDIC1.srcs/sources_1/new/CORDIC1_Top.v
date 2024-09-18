/*
    CORDIC1_Top
*/    

`timescale 1ns / 1ps

module CORDIC1_Top (input  Clock50MHz, 
                    output test_point1,
                    output test_point2,
                    output dac_csn,  // -- DAC SPI Chip Select
                    output dac_sdi,  // -- DAC SPI MOSI
                    output dac_ldac, // -- DAC SPI Latch enable
                    output dac_sck); // -- DAC SPI CLOCK

    localparam PRF = 20; // pulses per second
    
    reg  [15:0] freq = 16'd215; // = freq / 190
    wire [11:0] cordicOut;
    wire [11:0] windowOut;
    wire [11:0] multiplierOut;
    wire [11:0] subtracterOut;
    wire [11:0] shiftAddOut;
    wire  [9:0] dac_input;
    
    wire dac_busy;
    wire dac_trigger;
    wire windowStart;
  //wire windowStep;
    wire multSubEnable;
    wire shiftAddEnable;
     
    assign test_point1 = windowStart; // dac_busy;
    assign test_point2 = dac_trigger;    
    assign dac_input   = shiftAddOut [11:2];
    
    Mercury2_CORDIC
        U1 (.clk_50MHz (Clock50MHz), .cor_en (1'b1), .phs_sft (freq), .outVal (cordicOut));

  //Mercury2_DAC_Sim
    Mercury2_DAC
        U3 (.clk_50MHZ (Clock50MHz), .trigger  (dac_trigger), 
            .channel (1'b0), 
            .Din (dac_input), .Busy (dac_busy), 
            .dac_csn (dac_csn), .dac_sdi (dac_sdi), .dac_ldac (dac_ldac), .dac_sck  (dac_sck));
            
    CORDIC1_controller 
        U4 (.Clk50 (Clock50MHz), .dac_busy (dac_busy), .dac_trigger (dac_trigger), 
            .WindowStep (), // (windowStep), 
            .MultSubEnable (multSubEnable), .ShiftAddEnable (shiftAddEnable)); 
           
    ClockDivider #(.Divisor (50_000_000 / PRF)) 
 			   U5 (.FastClock (Clock50MHz),  
                   .Clear (1'b0),     // active high
                   .SlowClock (),  // (FastClock / Divisor), 50% duty cycle
				   .Pulse (windowStart));
           
    WindowGenerator #(.Width (12), .Duration (15_000))
                  U6 (.Clock   (Clock50MHz),
                      .Clear   (0),
                      .Trigger (windowStart),
                      .Step    (1), // (windowStep),
                      .Window  (windowOut));
                      
    UnsignedMult #(.WidthA (12), .WidthB (12), .WidthOut (12))
               U7 (.out    (multiplierOut), 
                   .a      (cordicOut), 
                   .b      (windowOut), 
				   .Enable (multSubEnable),
                   .Clock  (Clock50MHz));

    Subtracter #(.Width (12))
             U8 (.out (subtracterOut), 
                 .a (12'd4095), 
                 .b (windowOut),
	  		     .Enable (multSubEnable),
                 .Clock (Clock50MHz));
                 
    ShiftAddr #(.Width (12))
            U9 (.out    (shiftAddOut), 
                .a      (multiplierOut), 
                .b      (subtracterOut),
	  		    .Enable (shiftAddEnable),
                .Clock  (Clock50MHz));
endmodule
