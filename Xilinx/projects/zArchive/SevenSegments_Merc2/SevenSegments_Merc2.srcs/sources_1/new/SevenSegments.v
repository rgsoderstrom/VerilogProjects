`timescale 1ns / 1ps

// SevenSegments.v - Mercury 2 initial tests


module SevenSegments (input clk,
                      input sw0,  // slide switch
                      input sw1,
                      input sw2,
                      input sw3,
                      input sw4,
                      input sw5,
                      input sw6,
                      input sw7,
                      input pb0,  // pushbutton switches 
                      input pb1, 
                      input pb2, 
                      input pb3,
                      output reg ana0, // anode for one digit
                      output reg ana1,
                      output reg ana2,
                      output reg ana3,
                      output reg segA, // one segment
                      output reg segB,
                      output reg segC,
                      output reg segD,
                      output reg segE,
                      output reg segF,
                      output reg segG,
                      output reg segDot);
                      
    always @ (posedge clk)
     begin    
        ana0 <= ~pb0;
        ana1 <= ~pb1;
        ana2 <= ~pb2;
        ana3 <= ~pb3;
        
        segA   <= sw0;        
        segB   <= sw1;        
        segC   <= sw2;        
        segD   <= sw3;        
        segE   <= sw4;        
        segF   <= sw5;        
        segG   <= sw6;        
        segDot <= sw7;        
    end      
                      
endmodule


