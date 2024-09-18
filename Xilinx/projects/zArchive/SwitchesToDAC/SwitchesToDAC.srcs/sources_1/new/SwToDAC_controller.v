
/*
    SwToDAC_controller.v
*/    

`timescale 1ns / 1ps

module SwToDAC_controller (input  Clk50,
                           input  dac_busy,
                           output reg channel, 
                           output reg load,         // load switch latch
                           output reg dac_trigger); // trigger DAC
                                                      
reg [2:0] State;

initial
    State = 0;
    
always @ (posedge Clk50)
	begin
        case (State)
		    'h0: if (dac_busy == 0) State <= 'h1;			
            'h1: begin channel <= 0; State <= 'h2; end
            'h2: State <= 'h3;
            'h3: State <= 'h4;
            'h4: if (dac_busy == 1) State <= 'h5;
            'h5: begin channel <= 1; if (dac_busy == 0) State <= 6; end
            'h6: State <= 7;
            'h7: if (dac_busy == 1) State <= 0;
        	 default: State <= 0;
		endcase
	end
	
always @ (*)
	begin
		load        <= (State == 'h1);
		dac_trigger <= (State == 'h3) || (State == 'h6);
	end
endmodule
