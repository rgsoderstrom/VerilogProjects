/*
    PhaseCounter.v - up-counter that wraps at max
*/
    
`timescale 1ns / 1ps

module PhaseCounter #(parameter Width = 16)
                     (input Clock,
                      input Clear,  // active high, synchronous
                      input Enable,
                      input  [Width-1:0] Step, // frequency
                      output [Width-1:0] Phase);
                      
    reg [Width-1:0] Counter;
    assign Phase = Counter;
    
    initial
        Counter = 0;
        
    
    always @ (posedge Clock)
    begin
        if (Enable == 1)
        begin
            if (Clear == 1)
                Counter <= 0;
            else
                Counter <= Counter + Step;
                
           //Zero <= (Counter == 0);
        end
    end
                         
endmodule
