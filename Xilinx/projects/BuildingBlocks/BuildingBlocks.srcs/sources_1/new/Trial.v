
/*
    Trial.v 
        - small module for testing Verilog constructs
        - instantiated by Testbench.v
*/

`timescale 1ns / 1ps

module Trial #(parameter Width = 10)
              (//input  Clock,
               //input  Clear,
               input  [Width:0]   WriteAddr,  // extra bit
               input  [Width-1:0] ReadAddr,
               output [15:0]      Remaining);
               
    assign Remaining = WriteAddr > ReadAddr ? WriteAddr - ReadAddr : 0;             
    
    
endmodule
