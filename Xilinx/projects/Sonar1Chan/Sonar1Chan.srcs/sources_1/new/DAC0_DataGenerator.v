
/*
    DAC0_DataGenerator.v -
        - generate ping for SONAR transmitter 
*/

`timescale 1ns / 1ps

module DAC0_DataGenerator #(parameter Width = 10)  
                           (input wire Clock50MHz,
                            input wire StartPing,
                            input wire dac_busy,
                            input wire [15:0] Duration,   // in clocks, duration at max level
                            input wire [15:0] Frequency,  // (FreqInHz / 190), see CORDIC.vhd
                            output wire dac_trigger,
                            output wire PingDone,
                            output wire [Width-1:0] PingWords);
                            
    wire [11:0] cordicOut;
    wire [11:0] windowOut;
    wire [11:0] multiplierOut;
    wire [11:0] subtracterOut;
    wire [11:0] shiftAddOut;
  //wire  [9:0] dac_input;
    
    wire windowStart;
    wire windowDone;
    wire multSubEnable;
    wire shiftAddEnable;
    
    assign PingWords = shiftAddOut [11:2];

    Mercury2_CORDIC
        U1 (.clk_50MHz (Clock50MHz), .cor_en (1'b1), .phs_sft (Frequency), .outVal (cordicOut));

    WindowGenerator #(.Width (12))
                  U2 (.Clock50MHz (Clock50MHz),
                      .Clear      (1'b0),
                      .Trigger    (windowStart),
                      .Duration   (Duration),
                      .WindowDone (windowDone),
                      .Window     (windowOut));
        
    DAC0_Controller 
        U4 (.Clock50MHz  (Clock50MHz), 
            .dac_busy    (dac_busy), 
            .dac_trigger (dac_trigger), 
            .StartPing   (StartPing),
            .Done        (PingDone),
            .WindowStart    (windowStart), 
            .WindowDone     (windowDone),
            .MultSubEnable  (multSubEnable), 
            .ShiftAddEnable (shiftAddEnable)); 
           
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
