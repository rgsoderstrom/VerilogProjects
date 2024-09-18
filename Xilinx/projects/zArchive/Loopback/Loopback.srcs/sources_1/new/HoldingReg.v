`timescale 1ns / 1ps

module HoldingReg (input [15:0] D,
                   input Load,
                   input Clr,
                   input Clk,
                   output reg [15:0] Q);
                   
    always @ (posedge Clk)   
     begin
        if (Clr == 1'b1)
            Q <= 0;
        
        else if (Load == 1'b1)
        begin
//            Q <= D;
            Q [15:12]  <= D [11:8];  // swap nybbles
            Q [11:8]   <= D [15:12];
            Q [7:4]    <= D [3:0];
            Q [3:0]    <= D [7:4];
        end
    end

                       
endmodule
