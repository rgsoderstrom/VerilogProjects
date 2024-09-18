`timescale 1ns / 1ps

module TargetLevelReg #(parameter Width  = 4)  
                       (input  Clk,
                        input  Clr,
                        input  Load,
                        input  [Width-1:0]     InputLevel,
                        output reg [Width-1:0] OutputLevel);
                       
	initial
		OutputLevel = 0;
		
    always @ (posedge Clk)     
    begin                  
        if (Clr == 1'b1)
            OutputLevel = 0;
        
        else if (Load == 1'b1)
            OutputLevel = InputLevel;
    end
                               
endmodule
