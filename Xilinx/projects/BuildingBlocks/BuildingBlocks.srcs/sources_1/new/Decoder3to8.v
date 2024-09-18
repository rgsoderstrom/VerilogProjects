/*
	Decoder3to8
*/


`timescale 1ns / 1ps

module Decoder3to8 (input [2:0] select,  
					input  enable,
					output Out0,
					output Out1,
					output Out2,
					output Out3,
					output Out4,
					output Out5,
					output Out6,
					output Out7);
			    
    assign Out0 = (enable == 1 && select == 0);
    assign Out1 = (enable == 1 && select == 1);
    assign Out2 = (enable == 1 && select == 2);
    assign Out3 = (enable == 1 && select == 3);
    assign Out4 = (enable == 1 && select == 4);
    assign Out5 = (enable == 1 && select == 5);
    assign Out6 = (enable == 1 && select == 6);
    assign Out7 = (enable == 1 && select == 7);
        
endmodule
	