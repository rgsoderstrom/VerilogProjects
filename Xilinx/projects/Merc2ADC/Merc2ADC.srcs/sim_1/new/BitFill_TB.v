`timescale 1ns / 1ps

module BitFill_TB;

    wire [15:0] Value; // 7-seg in
    reg  [9:0]  adcOut = 10'h234;

    assign Value = adcOut;
    

endmodule
