/*
    SineLatch
*/

`timescale 1ns / 1ps

module SineLatch (input Clock,
                  input Load,
                  input     [11:0] In,
                  output reg [9:0] Out,
                  output reg [1:0] unused);

    always @ (posedge Clock)
    begin
        if (Load == 1)
        begin
            Out    = In [11:2];
            unused = In [1:0];
        end
    end
    
endmodule
