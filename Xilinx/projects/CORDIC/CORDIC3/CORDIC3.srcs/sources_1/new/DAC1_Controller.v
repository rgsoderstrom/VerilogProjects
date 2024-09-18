/*
    DAC1_Controller.v
        - controller for DAC Chan 1 ramp generator
*/

`timescale 1ns / 1ps

module DAC1_Controller (input  Clock,
                        input  BeginBlanking,
                        input  StartRamp,
                        input  dac_busy,
                        input  CountEnable,
                        input  RampDone,
                        output reg dac_trigger,
                        output reg LoadBlanking,
                        output reg InBlanking,
                        output reg LoadInitial);
reg [7:0] State;

initial
    State = 7'h0;
    
always @ (posedge Clock)
	begin
        case (State)
		    8'h00: if (BeginBlanking == 1)  State <= 8'h10; 
		           else if (StartRamp == 1) State <= 8'h40;
            
            8'h10: State <= 8'h20;    
            
            8'h20: begin if (dac_busy == 0) State <= 8'h30; end
            
            8'h30: State <= 8'h35;
            
            8'h35: State <= 8'h00;
            
            8'h40: State <= 8'h50;
            
            8'h50: begin if (dac_busy == 0) State <= 8'h60; end	    
            
            8'h60: if (RampDone == 1) State <= 8'h00; else State <= 8'h70;
            
            8'h70: if (CountEnable == 1) State <= 8'h50;		    
            
        	default: State <= 7'h00;
		endcase
	end
	
always @ (*)
	begin
	    LoadBlanking <= (State == 8'h10);
	    InBlanking   <= (State == 8'h35);
		dac_trigger  <= (State == 8'h30 || State == 8'h60);
		LoadInitial  <= (State == 8'h40);
	end                       
endmodule
