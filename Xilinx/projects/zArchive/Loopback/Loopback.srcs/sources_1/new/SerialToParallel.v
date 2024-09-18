`timescale 1ns / 1ps

module SerialToParallel (input DataIn,
                         input Shift,
                         input Clr,
                         input Clk,
                         output reg [15:0] Q);
                         
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
            Q <= 0;
        
        else if (Shift == 1'b1)
        begin
            Q [15 : 1] <= Q [14 : 0];
            Q [0] <= DataIn;        
        end
    end
                         
endmodule
