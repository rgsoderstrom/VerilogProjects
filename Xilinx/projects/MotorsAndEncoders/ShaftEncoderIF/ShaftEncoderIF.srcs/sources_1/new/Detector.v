
//
// Detector.v
//

`timescale 1ns / 1ps

module Detector (input PA,
                 input PB,
                 input clk,
                 input clr,
                 output Change,
                 output Direction);
    
    wire A1, A0;
    wire B1, B0;
    wire CA, CB;
    
    wire A0bar, B1bar;
    wire P, Q;
        
    FDC u1 (.D (PA), .C (clk), .Q (A1), .CLR (clr));
    FDC u2 (.D (PB), .C (clk), .Q (B1), .CLR (clr));

    FDC u3 (.D (A1), .C (clk), .Q (A0), .CLR (clr));
    FDC u4 (.D (B1), .C (clk), .Q (B0), .CLR (clr));

    xor u5 (CA, A1, A0);
    xor u6 (CB, B1, B0);
    
    or u7 (Change, CA, CB);

    not u8 (A0bar, A0);
    not u9 (B1bar, B1);

    and u10 (P, A0bar, B1);
    and u11 (Q, A0, B1bar);
    
    // "or" gate changed to "nor" so counts go up when phase A leading
    nor u12 (Direction, P, Q); // (Direction == 1) => count up      

endmodule


