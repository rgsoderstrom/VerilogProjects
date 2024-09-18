`timescale 1ns / 1ps

/*
	FifoController.v - controller for FIFO loopback test
*/

module FifoController (input  P2S_Empty,
   				       output reg P2S_Load,
				 
			      	   input Clk,
				       input Clear,

				       input  FIFO_Empty,
			     	   output reg FIFO_ReadCycle);

reg [1:0] state;

initial state = 0;

always @ (posedge Clk)
	begin
		if (Clear == 1'b1)
            begin
			    state = 0;
		    end
		  
		else
			case (state)
				0: if (FIFO_Empty == 0) state = 1; else state = 0;
				1: if (P2S_Empty) state = 2; else state = 1;				
				2: state = 3;
				3: state = 0;
				
				default: state <= 0;
		endcase
	end
	
always @ (*)
	begin
		FIFO_ReadCycle <= (state == 2);
		P2S_Load       <= (state == 3);
	end
	
endmodule
