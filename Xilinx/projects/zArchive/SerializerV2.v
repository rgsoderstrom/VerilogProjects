`timescale 1ns / 1ps

//
// SerializerV2 - Version 2 for Arduino
//

module SerializerV2 #(parameter NumbDataBits = 1)
                     (input [NumbDataBits-1:0] Input1,
                      input [NumbDataBits-1:0] Input2,
                      input            Clk,
                      input            Clr,
                      input            Load,
                      input            Shift,
                      output reg       OutputBit);

    reg [(2*NumbDataBits)-1:0] Content;

    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
        begin
            Content <= 0;
        end
        
        else if (Load == 1'b1)
        begin
            Content [(2*NumbDataBits)-1:NumbDataBits] <= Input1; 
            Content [NumbDataBits-1:0] <= Input2; 
        end
        
        else if (Shift == 1'b1)
        begin
            Content <= (Content << 1); 
        end
		
		#1 OutputBit <= Content [(2*NumbDataBits)-1];
    end  
endmodule




