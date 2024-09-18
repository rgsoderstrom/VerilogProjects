/*
    CORDIC1_Controller.v
*/    

`timescale 1ns / 1ps

module CORDIC1_controller (input  Clk50,
                           input  dac_busy,
                           output reg WindowStep,
                           output reg MultSubEnable,
                           output reg ShiftAddEnable,
                           output reg dac_trigger);                                                     
reg [6:0] State;
reg [7:0] DelayCounter;

initial
    State = 7'h0;
    
always @ (posedge Clk50)
	begin
        case (State)
		    7'h00: if (dac_busy == 0) State <= 7'h7;

		    7'h07: begin DelayCounter <= 8'd112; State <= 7'h08; end  
            7'h08: begin DelayCounter <= DelayCounter - 1; State <= 7'h09; end
            7'h09: if (DelayCounter == 0) State <= 7'h10; else State <= 7'h08;
            		    
            7'h10: State <= 7'h20;            
            7'h20: State <= 7'h30;
            7'h30: State <= 7'h40;
            7'h40: State <= 7'h00;
        	default: State <= 7'h00;
		endcase
	end
	
always @ (*)
	begin
		dac_trigger    <= (State == 7'h10);
		WindowStep     <= (State == 7'h20);
		MultSubEnable  <= (State == 7'h30);
		ShiftAddEnable <= (State == 7'h40);
	end
endmodule
