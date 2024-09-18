`timescale 1ns / 1ps

module ParallelToSerial (input [15:0] D,
                         input Load,
                         input Shift,
                         input Clr,
                         input Clk,
                         output Q);

    reg [15:0] data;
    
    assign Q = data [15];
                             
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
        begin
            data <= 0;
        end
        
        else if (Load == 1'b1)
        begin
            data <= D;
        end
        
        else if (Shift == 1'b1)
        begin
            data [15 : 1] <= data [14 : 0];
            data [0] <= 1'b0;        
        end
    end
                         
endmodule
