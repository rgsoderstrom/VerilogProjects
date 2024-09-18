
`timescale 1ns / 1ps

module Mercury2_ADC_Sim (input  clock,         // -- 50MHz onboard oscillator
                         input  trigger,       // -- assert to write Din to ADC
                         input  [2:0] channel, // -- 0..7
                         output reg [9:0] Dout,    // -- data out
                         output reg OutVal,    // -- output valid
                         input  diffn,         // -- select single ended or differential
                         input  adc_miso,
                         output adc_mosi, 
                         output adc_cs, 
                         output adc_clk);
                         
reg [1:0] State = 0;
reg [6:0] counter = 0;

localparam Delay = 10; // 80; // ADC sets OutVal low for this many clocks after trigger - 1.4 uS

assign adc_mosi = 0;
assign adc_cs   = 0;
assign adc_clk  = 0;

initial
    State = 0;
    
reg [9:0] dout = 10'd512;
//reg [9:0] dout = 10'h1f6;
    
always @ (posedge clock)
	begin
        case (State)
		    'h0: if (trigger == 1) begin dout <= dout + 1; State <= 'h1; end			
            'h1: begin counter <= Delay; State <= 'h2; end
            'h2: begin counter <= counter - 1; if (counter == 0) State <= 'h0; end
        	 default: State <= 0;
		endcase
	end
	
always @ (*)
	begin
		OutVal <= (State == 'h0); // output valid
//		Dout <= 10'h3ff;
//		Dout <= 10'h001;
		Dout <= dout;
	end

endmodule
