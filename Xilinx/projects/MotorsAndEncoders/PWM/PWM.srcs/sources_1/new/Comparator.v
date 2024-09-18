`timescale 1ns / 1ps

module Comparator #(parameter Width = 4) 
                   (input [Width-1:0] A,
                    input [Width-1:0] B,
                    output Less,
                    output Greater,
                    output Equal);
                   
   assign Less    = (A < B);
   assign Greater = (A > B);
   assign Equal   = (A == B);
endmodule
