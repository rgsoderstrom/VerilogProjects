/*
    CORDIC1_Controller.v
*/    

`timescale 1ns / 1ps

module CORDIC1_controller (input wire Clk50,
                           input wire dac_busy,
                           output reg dac_trigger);  

	localparam WaitForReady = 4'h0;
	localparam LoadDAC      = 4'h1;
	localparam LoadDelay    = 4'h2;
	localparam DecrDelay    = 4'h3;
	localparam TestDelay    = 4'h4;
	
	reg [3:0] State;
	reg [9:0] DelayCounter;
	
	localparam DelayCount = 50_000_000 / 200_000; // (Clocks per second) / (Samples per second) = clocks per sample

	initial
		State = WaitForReady;
		
	always @ (posedge Clk50)
		begin
			case (State)
				WaitForReady: if (dac_busy == 0) State <= LoadDAC;
				LoadDAC:      State <= LoadDelay;
				LoadDelay:    begin DelayCounter <= DelayCount; State<= DecrDelay; end
				DecrDelay:    begin DelayCounter <= DelayCounter - 1; State <= TestDelay; end
				TestDelay:    if (DelayCounter == 0) State <= WaitForReady; else State <= DecrDelay;
				default: State <= 7'h00;
			endcase
		end
	
	always @ (*)
		begin
			dac_trigger <= (State == LoadDAC);
		end
endmodule
