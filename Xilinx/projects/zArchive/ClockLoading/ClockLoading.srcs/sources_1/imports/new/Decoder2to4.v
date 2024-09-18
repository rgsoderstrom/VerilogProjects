/*
	Decoder2to4
*/


`timescale 1ns / 1ps

module Decoder2to4 (input [1:0] select,  
					input  enable,
					output Out0,
					output Out1,
					output Out2,
					output Out3);
			    
    assign Out0 = (enable == 1 && select == 0);
    assign Out1 = (enable == 1 && select == 1);
    assign Out2 = (enable == 1 && select == 2);
    assign Out3 = (enable == 1 && select == 3);
        
endmodule
	