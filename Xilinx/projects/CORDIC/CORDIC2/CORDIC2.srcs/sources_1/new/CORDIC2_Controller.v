/*
    CORDIC2_Controller.v
*/    

`timescale 1ns / 1ps

module CORDIC2_controller #(parameter Delay = 8'd112)
                           (input  Clock50MHz,
                           input  dac_busy,
                           output reg WindowStep,
                           output reg MultSubEnable,
                           output reg ShiftAddEnable,
                           output reg dacChannel,
                           output reg dacMuxSelect,
                           output reg dac_trigger);                                                     
reg [6:0] State;
reg [7:0] DelayCounter;

initial
    begin
      State = 7'h0;
      dacChannel = 0;
      dacMuxSelect = 0;
    end
  
always @ (posedge Clock50MHz)
	begin
        case (State)
		    7'h00: if (dac_busy == 0) State <= 7'h7; // wait for digital part to finish

		    7'h07: begin 
		              DelayCounter <= Delay; // 8'd112; // then wait for analog outputs to settle
		              dacChannel <= 0;
		              dacMuxSelect <= 0;
		              State <= 7'h08; 
		           end  
		    
            7'h08: begin DelayCounter <= DelayCounter - 1; State <= 7'h09; end
            7'h09: if (DelayCounter == 0) State <= 7'h10; else State <= 7'h08;
            		    
            7'h10: State <= 7'h20;            
            7'h20: State <= 7'h30;
            7'h30: State <= 7'h40;
            7'h40: State <= 7'h50;
            7'h50: if (dac_busy == 0) State <= 7'h60;
            
            7'h60: begin 
		              dacChannel <= 1;
		              dacMuxSelect <= 1;
                      State <= 7'h70;
                   end
                   
            7'h70: State <= 7'h00;
        	default: State <= 7'h00;
		endcase
	end
	
always @ (*)
	begin
	//	dac_trigger    <= (State == 7'h70); // || State == 7'h70);
	    dac_trigger    <= (State == 7'h10 || State == 7'h70);
		WindowStep     <= (State == 7'h20);
		MultSubEnable  <= (State == 7'h30);
		ShiftAddEnable <= (State == 7'h40);
	end
endmodule
