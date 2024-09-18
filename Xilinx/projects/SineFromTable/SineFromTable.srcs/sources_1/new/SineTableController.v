/*
    SineTableController - controller for sine LUT and interpolation
*/

`timescale 1ns / 1ps

module SineTableController (input  Clock,
                            input  Trigger,
                            output reg LoadTheta,
                            output reg MultEnable,
                            output reg AddEnable,
                            output reg Done);                            
reg [1:0] State;

initial
    State = 0;
    
always @ (posedge Clock)
	begin
        case (State)
            'h0: if (Trigger == 1) State <= 'h1; 
            'h1: State <= 'h2;
            'h2: State <= 'h3;
            'h3: State <= 0;
            default: State <= 0;
		endcase
	end
	
always @ (*)
	begin
		Done       <= (State == 'h0);
		LoadTheta  <= (State == 'h1);
		MultEnable <= (State == 'h2);
		AddEnable  <= (State == 'h3);
	end
endmodule
