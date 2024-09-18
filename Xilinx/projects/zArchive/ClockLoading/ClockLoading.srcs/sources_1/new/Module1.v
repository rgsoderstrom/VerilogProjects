
/*
    Module1.v 
*/

`timescale 1ns / 1ps

module Module1 (output select3, // select digit 3
                output select2,
                output select1,
                output select0,
                input  [3:0] brightness,
                input  Clock);
                           
	wire [15:0] freeCounter;
	wire [1:0] selectCounter     = freeCounter [15:14];
	wire [3:0] brightnessCounter = freeCounter [13:10];
	wire       decodeEnable;// = brightnessCounter < brightness;

    FreeCounter #(.Width (16)) 
              U3 (.Clk (Clock),
                  .Clr (0),
                  .FCValue (freeCounter));
                  
    Decoder2to4 U5 (.select (selectCounter),  
	   	       	    .enable (decodeEnable),
			        .Out0 (select0),
			        .Out1 (select1),
				    .Out2 (select2),
			        .Out3 (select3));

    Comparator #(.Width (4)) 
             U6 (.A (brightnessCounter),
                 .B (brightness),                 
                 .Less (decodeEnable),
                 .Greater (),
                 .Equal ());                    
endmodule





