`timescale 1ns / 1ps

module FreeCounter #(Width = 6) 
                    (input Clk,
                     input Clr,
                     output reg [Width-1:0] FCValue); // LSBs);
        
 //   reg [Width-1:0] FCValue;
	
	initial
		FCValue = 0;
                 
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
            FCValue <= 0;
        else
            FCValue <= FCValue + 1'b1;
            
    //  LSBs <= FCValue;     
    
    end                    
endmodule
