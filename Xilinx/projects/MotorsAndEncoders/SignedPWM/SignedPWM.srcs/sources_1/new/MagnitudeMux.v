`timescale 1ns / 1ps

module MagnitudeMux #(parameter Width = 4)
                     (input [Width-1:0]  in,
                      input sel,
                      output reg [Width-1:0] out);
  
always @ (*)
    if (sel)
        out = in;
    else
        out = 0;
        
endmodule
