
/*
    CORDIC4_Top.v - this is a container for module development
                  - will be run only in a test bench 
*/

`default_nettype none
`timescale 1ns / 1ps

module CORDIC4_Top (input  Clock50MHz);
    
    //********************************************
    
    // frequencies.    
    reg  [15:0] mixerFreq  = 40280 / 190; // = 16'd212; // = freq / 190
    reg  [15:0] signalFreq = 50350 / 190;

    //********************************************
    
    // signal oscillator. Unsigned right out of CORDIC. Converted to signed for subsequent operations
    wire        [11:0] unsigned_Signal;
    wire signed [11:0] signed_Signal;
    
    assign signed_Signal [10:0] = unsigned_Signal [10:0];
    assign signed_Signal [11]   = unsigned_Signal [11] ^ 1'b1;    
    
    //********************************************
    
    // local oscillators.
    wire        [11:0] unsigned_LocalOscI;
    wire        [11:0] unsigned_LocalOscQ;    
    wire signed [11:0] signed_LocalOscI;
    wire signed [11:0] signed_LocalOscQ;
    
    assign signed_LocalOscI [10:0] = unsigned_LocalOscI [10:0];
    assign signed_LocalOscI [11]   = unsigned_LocalOscI [11] ^ 1'b1;    
    assign signed_LocalOscQ [10:0] = unsigned_LocalOscQ [10:0];
    assign signed_LocalOscQ [11]   = unsigned_LocalOscQ [11] ^ 1'b1;
    
    // delay the startup of the in-phase CORDIC to produce a sin wave
    reg  [15:0] iDelay = 16'd313;
    
    always @ (posedge Clock50MHz)
        if (iDelay != 0)
            iDelay <= iDelay - 1;
            
    wire iEnable = (iDelay == 0);
    
    //********************************************
    
    Mercury2_CORDIC
        LocalOscI (.clk_50MHz (Clock50MHz), .cor_en (iEnable), .phs_sft (mixerFreq),  .outVal (unsigned_LocalOscI)),
        LocalOscQ (.clk_50MHz (Clock50MHz), .cor_en (1'b1),    .phs_sft (mixerFreq),  .outVal (unsigned_LocalOscQ)),
        Signal    (.clk_50MHz (Clock50MHz), .cor_en (1'b1),    .phs_sft (signalFreq), .outVal (unsigned_Signal));

    //********************************************

    // multiplier outputs    
    wire signed [23:0] MixedI_full;
    wire signed [23:0] MixedQ_full;
    assign MixedI_full = signed_LocalOscI * signed_Signal;
    assign MixedQ_full = signed_LocalOscQ * signed_Signal;
    
    wire signed [11:0] MixedI = MixedI_full [23:12]; 
    wire signed [11:0] MixedQ = MixedQ_full [23:12]; 
        
    //********************************************

    localparam FixedPoint_One = (1 << 12);

    wire signed [11:0] h0  =  0.016344994571662934 * FixedPoint_One;
    wire signed [11:0] h1  =  0.03153993235313417  * FixedPoint_One;
    wire signed [11:0] h2  =  0.01812600557315812  * FixedPoint_One;
    wire signed [11:0] h3  = -0.03679867254082173  * FixedPoint_One;



        
endmodule


