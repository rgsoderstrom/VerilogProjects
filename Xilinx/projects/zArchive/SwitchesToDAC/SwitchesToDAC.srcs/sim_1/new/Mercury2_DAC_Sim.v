
`timescale 1ns / 1ps

module Mercury2_DAC_Sim (input clk_50MHZ, // -- 50MHz onboard oscillator
                         input trigger,   // -- assert to write Din to DAC
                         input channel,   // -- 0 = DAC0/A, 1 = DAC1/B
                         input [9:0] Din, // -- data for DAC
                         output reg Busy);    // -- busy signal during conversion process

reg [1:0] State = 0;
reg [4:0] counter = 0;

localparam Delay = 3; // DAC reports Busy for this many clocks after trigger

initial
    State = 0;
    
always @ (posedge clk_50MHZ)
	begin
        case (State)
		    'h0: if (trigger == 1) State <= 'h1;			
            'h1: begin counter <= Delay; State <= 'h2; end
            'h2: begin counter <= counter - 1; if (counter == 0) State <= 'h0; end
        	 default: State <= 0;
		endcase
	end
	
always @ (*)
	begin
		Busy <= (State == 'h1) || (State == 'h2);
	end
endmodule
