
/*
    FixedPoint.v - Two's complement add & mul 
*/

`timescale 1ns / 1ps

module FixedPoint #(parameter TotalWidth = 32,  // includes sign, int and fraction
                    parameter FractBits  = 24)
                   (input wire Clock,
                    input wire Enable,
                    input wire Clear,
                    
                    input wire signed [TotalWidth-1:0] a,
                    input wire signed [TotalWidth-1:0] b,
                    
                    output wire signed [TotalWidth-1:0] Sum,
                    output wire signed [TotalWidth-1:0] Diff,
                    output wire signed [TotalWidth-1:0] Prod);

    reg signed [TotalWidth:0]     fullSum;
    reg signed [TotalWidth:0]     fullDiff;
    reg signed [2*TotalWidth-1:0] fullProd;
                    
    assign Sum  = fullSum  [TotalWidth-1:0];
    assign Diff = fullDiff [TotalWidth-1:0];
    assign Prod = fullProd >> FractBits; 
    
    always @(posedge Clock) begin
        if (Clear == 1) begin
            fullSum  <= 0;
            fullDiff <= 0;
            fullProd <= 0;
        end 
        else if (Enable == 1) begin
            fullSum  <= a + b;
            fullDiff <= a - b;
            fullProd <= a * b;
        end
     end
                            
endmodule
