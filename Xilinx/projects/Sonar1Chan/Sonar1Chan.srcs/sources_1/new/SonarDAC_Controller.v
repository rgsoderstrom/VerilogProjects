/*
    SonarDAC_Controller.v
        - controller for SONAR Tx waveform & TVG ramp
*/

`timescale 1ns / 1ps

module SonarDAC_Controller (input wire  Clock50MHz,
					 	    input wire  BeginSequence,
						    input wire  PingDone,
						  //input  RampDone,
						    input wire  InBlanking,
						    input wire [19:0] BlankingCounts,
						    output reg BeginPing,
                            output reg BeginBlanking,
                            output reg BeginRamp,
                            output reg dacMuxSelect);

    reg [19:0] BlankingDelayCntr; 
    reg [3:0] State;
    
//    localparam BlankingCounts = 50_000_000 * 0.003;

	localparam idle   = 4'h0;
	localparam setBB  = 4'h1;
	localparam waitIB = 4'h2;
	localparam setBS  = 4'h3;
	localparam waitPD = 4'h4;
	localparam loadDC = 4'h5;
	localparam delay  = 4'h6;
	localparam setSR  = 4'h7;
  //localparam waitRD = 4'h8;
	
    initial
      begin
        State = 0;
        BlankingDelayCntr = 0;
        dacMuxSelect = 1;
      end
        
    always @ (posedge Clock50MHz)
	   begin
         case (State)
		    idle: if (BeginSequence == 1) State <= setBB; 
            
            setBB: begin dacMuxSelect <= 1; State <= waitIB; end
            
            waitIB: if (InBlanking == 1) State <= setBS;
            
			setBS:  begin dacMuxSelect <= 0; State <= waitPD; end
			
			waitPD: if (PingDone == 1) State <= loadDC;
						
            loadDC: begin 
						BlankingDelayCntr <= BlankingCounts; 
						dacMuxSelect <= 1;
						State <= delay; 
				    end
                        
            delay: if (BlankingDelayCntr == 0) State <= setSR; 
                   else BlankingDelayCntr <= BlankingDelayCntr - 1;  
            
            setSR: State <= idle; // waitRD;
            
          //waitRD: if (RampDone == 1) State <= idle;
            
        	default: State <= idle;
		endcase
	end
		
    always @ (*)
	    begin  
		    BeginBlanking <= (State == setBB);
		    BeginPing     <= (State == setBS);
	   	    BeginRamp     <= (State == setSR);
    	end                       
    
endmodule
