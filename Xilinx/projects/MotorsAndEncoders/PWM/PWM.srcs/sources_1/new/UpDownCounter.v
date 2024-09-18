`timescale 1ns / 1ps

module UpDownCounter #(parameter Width = 4)
                      (input Clk,
                       input Clr,
                       input Enable,
                       input Up,
                       input Down,
					   input Load,
					   input [Width-1:0] Preset,
                       output reg [Width-1:0] Count);
                       
    reg [Width-1:0] UDCount;
	
	initial
		UDCount = 0;

    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
            UDCount <= 0;

		else if (Load == 1)
			UDCount <= Preset;
			
        else if (Enable == 1'b1)
        begin
            if (Up == 1)   UDCount <= UDCount + 1;
            if (Down == 1) UDCount <= UDCount - 1;
        end
                    
        Count = UDCount;                    
    end                       
endmodule
