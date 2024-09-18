/*
	Mux2
		- 2:1 multiplexer
*/

`timescale 1ns / 1ps

module Mux2 #(parameter Width = 8)
 			 (input  [Width-1:0] in0,  
              input  [Width-1:0] in1,
			  input              select,
	          output [Width-1:0] out);
	        //output reg [Width-1:0] out);
			
//    always @ (*)
//        out = (select == 0 ? in0 : in1);
    
    assign out = (select == 0 ? in0 : in1);
        
endmodule
