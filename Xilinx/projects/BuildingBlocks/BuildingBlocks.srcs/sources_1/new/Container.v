`timescale 1ns / 1ps

//
// Container - for unit tests of building blocks
//

module Container (input [3:0] A,
                  input [3:0] B,
                  input [3:0] C,
                  input [3:0] D,
                  input [3:0] E,
                  input [3:0] F,
                  input Load,
                  input Shift1,
                  input Shift2,
                  input Clear,  
                  input Clk,
                  output [11:0] G,
                  output [11:0] H);
                  
    wire bit;
    wire SShift1, SShift2, SLoad;
    
    SyncOneShot
        SyncOS1 (.trigger (Shift1), .clk (Clk), .clr (Clear), .Q (SShift1)),
        SyncOS2 (.trigger (Shift2), .clk (Clk), .clr (Clear), .Q (SShift2)),
        SyncOS3 (.trigger (Load),   .clk (Clk), .clr (Clear), .Q (SLoad));
        
    SerializerPtoS #(.Width5 (4), .Width6 (4))
        PtoS (.Input1 (A), .Input2 (B), .Input3 (C), .Input4 (D), .Input5 (E), .Input6 (F),
              .Clr (Clear), .Clk (Clk), .Load (SLoad), .Shift (SShift1), .OutputBit (bit));
              
    SerializerStoP  #(.Width (12))
        StoP (.DataIn (bit), .Shift (SShift2), .Clr (Clear), .Clk (Clk),
              .Q1 (G), .Q2 (H));          
endmodule
