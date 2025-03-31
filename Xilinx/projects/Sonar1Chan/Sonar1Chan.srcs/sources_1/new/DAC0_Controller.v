/*
    DAC0_Controller.v
        - controller for DAC Chan 0 ping generator
*/

`timescale 1ns / 1ps

module DAC0_Controller (input wire Clock50MHz,
                        input wire dac_busy,
                        input wire StartPing,
                        input wire WindowDone,
                        output reg WindowStart,
                        output reg dac_trigger,
                        output reg MultSubEnable,
                        output reg ShiftAddEnable,
                        output reg Done);
              
reg [7:0] State;

initial
    State = 7'h0;
    
always @ (posedge Clock50MHz)
	begin
        case (State)
		    8'h00: if (StartPing == 1) State <= 8'h10;
            
            8'h10: State <= 8'h20;    
            
            8'h20: begin if (dac_busy == 0) State <= 8'h30; end
            
            8'h30: State <= 8'h40;
            
            8'h40: State <= 8'h50;
            
            8'h50: begin if (WindowDone == 1) State <= 8'h60; else State <= 8'h20; end	    
            
            8'h60: State <= 8'h00;		    
            
        	default: State <= 7'h00;
		endcase
	end
	
always @ (*)
	begin
	    WindowStart    <= (State == 8'h10);
		dac_trigger    <= (State == 8'h30);
		MultSubEnable  <= (State == 8'h40);
		ShiftAddEnable <= (State == 8'h50);
		Done           <= (State == 8'h60);
	end                       
endmodule
