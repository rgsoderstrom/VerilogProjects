/*
    SineFromTable_ctrl.v
*/    

// Delay Added

`timescale 1ns / 1ps

module SineFromTable_ctrl (input      Clock,
                           input      dac_busy,
                           output reg sineTrigger,
                           input      sineReady,
                           output reg dac_trigger); // trigger DAC
                                                      
reg [1:0] State;

initial
    State = 0;
    
always @ (posedge Clock)
	begin
        case (State)
            'h0: if (dac_busy == 0) State <= 'h1;
            'h1: State <= 'h2;
            'h2: if (sineReady == 1) State <= 'h3;
            'h3: State <= 0;
            default: State <= 0;
		endcase
	end
	
always @ (*)
	begin
		sineTrigger <= (State == 'h1);
		dac_trigger <= (State == 'h3);
	end
endmodule
