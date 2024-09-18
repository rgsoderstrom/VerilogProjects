`timescale 1ns / 1ps

module InterruptCtrl (input in1,  // 4 pos edge triggered interrupt
                      input in2,
                      input in3,
                      input in4,
                      input clearInterrupt, //
                      input Clr, 
                      input Clk,
                      output reg interrupt);
                      
    reg wasIn1, wasIn2, wasIn3, wasIn4, wasClearInterrupt;
    
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
        begin
            wasIn1 = 1'b0; 
            wasIn2 = 1'b0; 
            wasIn3 = 1'b0; 
            wasIn4 = 1'b0; 
            wasClearInterrupt = 1'b0;  
            interrupt = 1'b0;                     
        end
        
        else
        begin
            if (wasIn1 == 1'b0 && in1 == 1'b1) interrupt <= 1'b1;
            if (wasIn2 == 1'b0 && in2 == 1'b1) interrupt <= 1'b1;
            if (wasIn3 == 1'b0 && in3 == 1'b1) interrupt <= 1'b1;
            if (wasIn4 == 1'b0 && in4 == 1'b1) interrupt <= 1'b1;           
        
            if (wasClearInterrupt == 1'b0 && clearInterrupt == 1'b1) interrupt <= 1'b0;
            
            wasIn1 <= in1;
            wasIn2 <= in2;
            wasIn3 <= in3;
            wasIn4 <= in4;
            wasClearInterrupt <= clearInterrupt;
            
        end
    end                 
endmodule




