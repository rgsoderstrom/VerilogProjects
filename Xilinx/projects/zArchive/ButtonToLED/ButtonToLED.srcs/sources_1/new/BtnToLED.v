`timescale 1ns / 1ps

module BtnToLED(
    input clk,
    input sw,
    output led0,
    output reg led1,
    output reg A0
    );
    
    reg [24:0] count = 0;
    assign led0 = count [24];
    always @ (posedge (clk)) 
        begin
            count <= count + 1;
            led1 = sw;
            A0 = sw;   // SW0, not BTN!
        end
        
endmodule
