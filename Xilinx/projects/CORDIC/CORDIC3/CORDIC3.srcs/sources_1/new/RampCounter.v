/*
    RampCounter.v 

*/

`timescale 1ns / 1ps

module RampCounter #(parameter Width = 10)
                    (input [Width-1:0] BlankingLevel,
                     input [Width-1:0] RampInitial,
                     input [Width-1:0] RampFinal,
                     
                     input  Clock,
                     input  Clear,
                     
                     input  LoadBlanking,
                     input  LoadInitial,
                     input  Enable,
                     output RampDone,
                     output [Width-1:0] Ramp);
    
//module RampCounter #(parameter Width = 10,
//                     BlankingLevel = 0,
//                     RampInitial   = 52,   // 0.25V
//                     RampFinal     = 255)  // 1.25V
//                    (input  Clock,
//                     input  Clear,
//                     input  LoadBlanking,
//                     input  LoadInitial,
//                     input  Enable,
//                     output RampDone,
//                     output [Width-1:0] Ramp);
    
    reg  [Width-1:0] Counter;
    reg  Running;  // true when counter incrementing
        
    assign Ramp = Counter;
    assign RampDone = (Counter == RampFinal && Running == 1);
    
    initial
    begin
        Counter  <= 0;
        Running  <= 0;
    end
                     
    always @ (posedge Clock)
    begin
        if (Clear == 1)
        begin
            Counter  <= 0;
            Running  <= 0;
        end
        
        else if (LoadBlanking == 1)
        begin
            Counter <= BlankingLevel;
            Running <= 0;
        end
        
        else if (LoadInitial == 1)
        begin
            Counter <= RampInitial;
            Running <= 1;
        end

        if (Running == 1 && Enable == 1)
        begin
            if (RampDone == 1)
                Running <= 0;
            else 
            begin
                Counter <= Counter + 1;            
            end
        end         
    end     
                    
endmodule


