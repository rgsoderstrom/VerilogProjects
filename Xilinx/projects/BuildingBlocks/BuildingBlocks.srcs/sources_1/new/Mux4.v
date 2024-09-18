/*
	Mux4
		- 4:1 multiplexer
*/

`timescale 1ns / 1ps

module Mux4 #(parameter Width = 8)
 			 (input  [Width-1:0] in0,  
              input  [Width-1:0] in1,
              input  [Width-1:0] in2,
              input  [Width-1:0] in3,
			  input  [1:0]       select,
	          output [Width-1:0] out);
    
    assign out = (select [1] == 0 ? (select [0] == 0 ? in0 : in1) : (select [0] == 0 ? in2 : in3));
        
endmodule
