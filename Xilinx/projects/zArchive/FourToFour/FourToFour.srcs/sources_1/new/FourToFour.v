`timescale 1ns / 1ps

module FourToFour (input InA,
                   input InB,
                   input InC,
                   input InD,
                   input clk,
                   output reg OutA,
                   output reg OutB,
                   output reg OutC,
                   output reg OutD);
               
    always @ (posedge clk)
     begin    
        OutA <= InA;
        OutB <= InB;
        OutC <= InC;
        OutD <= InD;                                
    end      
     
endmodule
