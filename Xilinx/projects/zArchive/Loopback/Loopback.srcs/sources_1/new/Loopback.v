`timescale 1ns / 1ps

module Loopback (input  DataIn,
                 output DataOut,
                 input  ShiftIn,
                 input  ShiftOut,
                 input  LoadHR,
                 input  LoadOut,
                 input  Clr,
                 input  CLK12MHZ);
                 
    wire SShiftIn, SLoadHR, SClr, SLoadOut, SShiftOut;
    wire [15:0] InputSRQ;
    wire [15:0] HoldingQ;
    
    wire Clear = !Clr; // make an active high signal
    
    SyncOneShot
            SyncOS1 (.trigger (ShiftIn),  .clk (CLK12MHZ), .clr (Clear), .Q (SShiftIn)),
            SyncOS2 (.trigger (LoadHR),   .clk (CLK12MHZ), .clr (Clear), .Q (SLoadHR)),
            SyncOS4 (.trigger (LoadOut),  .clk (CLK12MHZ), .clr (Clear), .Q (SLoadOut)),
            SyncOS5 (.trigger (ShiftOut), .clk (CLK12MHZ), .clr (Clear), .Q (SShiftOut));

    SerialToParallel 
            InputSR (.DataIn (DataIn), .Shift (SShiftIn), .Clr (Clear), .Clk (CLK12MHZ), .Q (InputSRQ));         
            
    HoldingReg
            Holding (.D (InputSRQ), .Load (SLoadHR), .Clr (Clear), .Clk (CLK12MHZ), .Q (HoldingQ));                  
                             
    ParallelToSerial 
            OutputSR (.D (HoldingQ), .Load (SLoadOut), .Shift (SShiftOut), .Clr (Clear), .Clk (CLK12MHZ), .Q (DataOut));                             
                 
endmodule
