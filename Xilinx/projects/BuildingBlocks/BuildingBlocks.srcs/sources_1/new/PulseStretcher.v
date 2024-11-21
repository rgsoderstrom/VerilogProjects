/*
    PulseTretcher.v - extend a pulse for easier viewing on test point
*/

`timescale 1ns / 1ps

module PulseStretcher #(parameter Count = 500_000)
                       (input Clock50MHz,
                        input trigger,
                        output extended);

    reg [23:0] Counter = 0;
    assign extended = (Counter != 24'h0);    
    
    always @ (posedge Clock50MHz) begin
        if (trigger == 1)
            Counter <= Count;
        else if (Counter != 0)
            Counter <= Counter - 1;    
    end
    
endmodule
