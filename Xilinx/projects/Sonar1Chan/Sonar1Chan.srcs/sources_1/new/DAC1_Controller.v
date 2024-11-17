/*
    DAC1_Controller.v
        - controller for DAC Chan 1 ramp generator
*/

`timescale 1ns / 1ps

module DAC1_Controller (input  Clock,
                        input  BeginBlanking,
                        input  BeginRamp,
                        input  dac_busy,
                        input  CountEnable,
                        input  RampDone,
						output reg InBlanking,
                        output reg dac_trigger,
                        output reg LoadBlanking,
                        output reg LoadInitial);
						
	localparam Idle     = 4'h0;
	localparam SetLB    = 4'h1;
	localparam WaitDAC1 = 4'h2;
	localparam LoadDAC1 = 4'h3;
	localparam SetIB    = 4'h4;
	localparam LoadRamp = 4'h5;
	localparam WaitDAC2 = 4'h6;
	localparam LoadDAC2 = 4'h7;
	localparam WaitCE   = 4'h8;
	
	reg [3:0] State;

	initial
		State = Idle;
		
	always @ (posedge Clock)
		begin
			case (State)
				Idle: if (BeginBlanking == 1)   State <= SetLB; 
					   else if (BeginRamp == 1) State <= LoadRamp;
				
				SetLB: State <= WaitDAC1;    
				
				WaitDAC1: begin if (dac_busy == 0) State <= LoadDAC1; end
				
				LoadDAC1: State <= SetIB;
				
				SetIB: begin InBlanking <= 1; State <= Idle; end
				
				LoadRamp: begin InBlanking <= 0; State <= WaitDAC2; end
				
				WaitDAC2: begin if (dac_busy == 0) State <= LoadDAC2; end	    
				
				LoadDAC2: if (RampDone == 1) State <= Idle; else State <= WaitCE;
				
				WaitCE: if (CountEnable == 1) State <= WaitDAC2;		    
				
				default: State <= Idle;
			endcase
		end
		
	always @ (*)
		begin
			LoadBlanking <= (State == SetLB);
			dac_trigger  <= (State == LoadDAC1 || State == LoadDAC2);
			LoadInitial  <= (State == LoadRamp);
		end                       
endmodule
