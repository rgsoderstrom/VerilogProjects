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
						output reg EnableCordic,
                        output reg dac_trigger,
                        output reg MultEnable,
                        output reg Done);
              
localparam Idle       = 0;
localparam SetWS      = 1;
localparam WaitForDAC = 2;
localparam WriteDAC   = 3;
localparam DoMult     = 4;
localparam SetDone    = 5;
			  
reg [2:0] State;

initial
  begin
    State <= Idle;
    EnableCordic <= 0;
  end
  
always @ (posedge Clock50MHz)
	begin
        case (State)
		    Idle: if (StartPing == 1) State <= SetWS;
            
            SetWS: begin EnableCordic <= 1; State <= WaitForDAC; end    
			
            WaitForDAC: begin if (dac_busy == 0) State <= WriteDAC; end
			
            WriteDAC: State <= DoMult;
			
            DoMult:  if (WindowDone == 1) State <= SetDone; else State <= WaitForDAC;
            
            SetDone: begin EnableCordic <= 0; State <= Idle; end
                        
        	default: State <= Idle;
		endcase
	end
	
//always @ (*)
always @ (posedge Clock50MHz)
	begin
	    WindowStart <= (State == SetWS);
		dac_trigger <= (State == WriteDAC);
		MultEnable  <= (State == DoMult);
		Done        <= (State == SetDone);
	end                       
endmodule
