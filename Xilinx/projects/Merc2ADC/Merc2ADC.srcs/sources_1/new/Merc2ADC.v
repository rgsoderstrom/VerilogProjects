
/*
    Merc2ADC.v - top module for ADC tests
        - chan 0 & 1 - 3.5 mm stereo audio jack
        - chan 2 - teperature sensor
        - chan 3 - light sensor
        - chan 4 - potentiometer
*/
    
`timescale 1ns / 1ps
module Merc2ADC (output [11:0] SevenSeg,
                 input  [2:0]  Channel,  // top 3 slide switches
                 input  adc_miso,
                 output adc_mosi,
                 output adc_csn,
                 output adc_sck,
                 input  Clock50MHz);
        
    wire        adcTrigger; 
    wire [15:0] Value; // 7-seg in
    wire [9:0]  adcOut;
    
    MercuryADC ADC (.clock (Clock50MHz),
                    .trigger (adcTrigger),
                    .diffn (1), // 1 for single ended
                    .channel  (Channel),  
                    .Dout     (adcOut),
                    .OutVal   (adcValid), 
                    .adc_miso (adc_miso),
                    .adc_mosi (adc_mosi),
                    .adc_cs   (adc_csn),
                    .adc_clk  (adc_sck));
    
    SevenSegmentDriver SS (.SevenSeg   (SevenSeg),
                           .value      (Value),
                           .dots       (4'h0),
                           .load       (adcTrigger),
                           .brightness (4'h2),
                           .Clock50MHz (Clock50MHz));

    ClockDivider #(.Divisor (50_000_000 / 10_000))
 			   CD (.FastClock (Clock50MHz),  
                   .Clear     (),
                   .SlowClock (), 
	     		   .Pulse     (adcTrigger));

    assign Value = adcOut;
endmodule
