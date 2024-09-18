`timescale 1ns / 1ps

// Serializer function implemented as a mux selecting
// one bit from a register

module Serializer #(parameter NumbDataBits = 1)
                   (input [NumbDataBits-1:0] InputBits,
                    input            Clk,
                    input            Clr,
                    input            Load,
                    output reg       Trigger,
                    output reg       OutputBit);

    localparam NumbLeadingZeros  = 4; // padding, for scope display
    localparam NumbTrailingZeros = 4; 
    localparam ContentSize = NumbLeadingZeros + NumbDataBits + NumbTrailingZeros;
        
    localparam MaxSelect = ContentSize - 1;
        
    reg [ContentSize-1:0] Content;
    reg [5:0] Select;   // OutputBit = Content [Select];

//
// update Content on Clr or Load
//            
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
        begin
            Content <= 0;
        end
        
        else if (Load == 1'b1)
        begin
            Content [NumbDataBits+NumbTrailingZeros-1 : NumbTrailingZeros] <= InputBits; 
        end
    end
  
//
// select bit to be output
//                     
    always @ (posedge Clk)
    begin
        if (Clr == 1) // ((Clr == 1'b1) || (Load == 1'b1))
        begin
            Select = MaxSelect;
        end
        
        else
        begin
            if (Select == 0)
                Select = MaxSelect;
            else
                Select = Select - 1;
        end
        
        OutputBit = Content [Select];
        Trigger = (Select == MaxSelect);
    end
                         
endmodule
