`timescale 1ns / 1ps

//
// Long counter for Mercury 2 tests
//

module counter (input clk,
                output reg[31:0] count);
    
initial count = 0;

always @ (posedge clk) 
    begin
        count <= count + 1'b1;
    end

endmodule
