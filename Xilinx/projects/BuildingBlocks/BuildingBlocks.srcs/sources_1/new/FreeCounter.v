`timescale 1ns / 1ps

module FreeCounter #(parameter CounterWidth = 6,
                     parameter OutputWidth = 4) 
                    (input Clk,
                     input Clr,
                     output reg Overflow,
                     output reg [OutputWidth-1:0] LSBs);
        
    reg [CounterWidth-1:0] FCValue;
	
	initial
		FCValue = 0;
                 
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
            FCValue <= 0;
        else
            FCValue <= FCValue + 1'b1;
            
        Overflow <= &FCValue;

        LSBs <= FCValue [OutputWidth-1:0];     
    
    end                    
endmodule
