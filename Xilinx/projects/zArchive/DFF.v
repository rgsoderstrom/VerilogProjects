`timescale 1ns / 1ps

module DFF (input Clk,
            input Clr,
            input D,
            output reg Q,
            output reg Qbar);
    
    always @ (posedge Clk, negedge Clr)
        if (Clr == 0) 
            begin
                Q <= 0;
                Qbar <= 1;
            end
        else 
		    begin
                Q <= D;
                Qbar <= ~D;
           end
       
endmodule
