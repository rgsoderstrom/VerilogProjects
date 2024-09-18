/* 
    SineFromTable.v
*/

`timescale 1ns / 1ps

module SineFromTable (input clk_in1,
                      output test_point1,
                      output test_point2,
                      output dac_csn,  // -- DAC SPI Chip Select
                      output dac_sdi,  // -- DAC SPI MOSI
                      output dac_ldac, // -- DAC SPI Latch enable
                      output dac_sck); // -- DAC SPI CLOCK

    reg  [15:0] frequency = 1; // 210;
    wire [15:0] phase;
    wire [15:0] sine;
    wire        sineTrigger;
    wire        sineReady;
    
  //wire        phaseCountEnable;
    wire        dac_busy;
    wire        dac_trigger;
    wire        Clock12MHz;  // actually 12.5 MHz

    assign test_point1 = (phase == 0); // dac_busy;
    assign test_point2 = dac_trigger;

  //  assign Clock10MHz = Clock50MHz;
        
//    ClockDivider #(.Divisor (4))
// 			   U1 (.FastClock (Clock50MHz),  
//                   .Clear (0), // active high
//                   .SlowClock (Clock12MHz),  
//				   .Pulse ()); // (phaseCountEnable));     // periodic pulse, FastClock width and SlowClock rate

  clk_wiz_0 U1
   (
        .clk_out1 (Clock12MHz),     // output clk_out1
        .reset(0), // input reset
        .locked(),       // output locked
        .clk_in1(clk_in1)      // input clk_in1
    );
    
    PhaseCounter #(.Width (16))
               U2 (.Clock (Clock12MHz),
                   .Clear (0),
                   .Enable (1), // (phaseCountEnable),
                   .Step (frequency), // frequency
                   .Phase (phase));

    SineTable U3 (.phase (phase),
                  .sine (sine),
                  .Trigger (sineTrigger),
                  .Done (sineReady),
                  .Zero (),
                  .Clock (Clock12MHz));

    SineFromTable_ctrl
              U4 (.Clock       (Clock12MHz),
                  .sineTrigger (sineTrigger),
                  .sineReady   (sineReady),
                  .dac_busy    (dac_busy),
                  .dac_trigger (dac_trigger));
    
    Mercury2_DAC
           //U5 (.dac_clk  (Clock10MHz),
             U5 (.clk_50MHZ  (clk_in1),
                 .trigger  (dac_trigger),
                 .channel  (0),
                 .Din      (sine [15:6]),
                 .Busy     (dac_busy),
                 .dac_csn  (dac_csn),
                 .dac_sdi  (dac_sdi),
                 .dac_ldac (dac_ldac),
                 .dac_sck  (dac_sck));    
endmodule




