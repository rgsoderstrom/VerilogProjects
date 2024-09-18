`timescale 1ns / 1ps

// JK flip flop

module JKFF #(parameter InitialQ = 0)
             (input J,
             input K,
             input Set,   // active high, synchronous
             input Clear, // ditto
             input Clk,   // pos edge
             output reg Q);
             
    reg [1:0] JK;
    
    initial
        Q <= InitialQ;
        
    always @ (posedge Clk)
    begin
        if (Set == 1)
            Q <= 1'b1;
            
        else if (Clear == 1)
            Q <= 1'b0;
            
        else begin
            case ({J, K})
                1: Q <= 1'b0;
                2: Q <= 1'b1;
                3: Q <= ~Q;
                default: ;
            endcase
        end
    end
                 
endmodule
