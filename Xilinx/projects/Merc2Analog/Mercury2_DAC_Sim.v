
`timescale 1ns / 1ps

module Mercury2_DAC_Sim (input wire clk_50MHZ, // -- 50MHz onboard oscillator
                         input wire trigger,   // -- assert to write Din to DAC
                         input wire channel,   // -- 0 = DAC0/A, 1 = DAC1/B
                         input wire [9:0] Din, // -- data for DAC
                         output reg Busy, // -- busy signal during conversion process
                         output wire dac_csn,
                         output wire dac_sdi, 
                         output wire dac_ldac, 
                         output wire dac_sck);

reg [1:0] State = 0;
reg [6:0] counter = 0;

reg [9:0] value0 = 0;
reg [9:0] value1 = 0;

localparam Delay = 70; // DAC reports Busy for this many clocks after trigger - 1.4 uS

assign dac_csn  = 0;
assign dac_sdi  = 0;
assign dac_ldac = 0;
assign dac_sck  = 0;

initial
    State = 0;
   
always @ (posedge clk_50MHZ)
    if (trigger == 1)
        if (channel == 0)
            value0 <= Din;
        else    
            value1 <= Din;
    
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
