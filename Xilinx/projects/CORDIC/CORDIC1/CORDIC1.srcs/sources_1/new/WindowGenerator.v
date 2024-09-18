/*
    WindowGenerator
*/    

`timescale 1ns / 1ps

module WindowGenerator #(parameter Width = 12,      // bits
                                   Duration = 1024) // time at max level, clocks
                        (input  Clock,
                         input  Clear,
                         input  Trigger,
                         input  Step,
                         output [Width-1:0] Window);
                         
    localparam MAX = (1 << Width) - 2048; // 1024 bad
  //localparam MAX = (1 << (Width - 1)) - 1;
  //localparam MAX = (1 << Width) - 1;
                             
    reg [Width-1:0] RampCounter; // counts clocks during transitions
    reg [15:0] DurationCounter;  // counts clocks while at max
    reg [1:0] State;
            
    assign Window = RampCounter;
                                 
    initial
    begin
        RampCounter <= 0;
        DurationCounter <= 0;
        State <= 0;
    end
        
    always @ (posedge Clock)
    begin
        if (Clear == 1)
        begin
            RampCounter <= 0;
            DurationCounter <= 0;
            State <= 0;
        end
        
        else
            if (Trigger == 1) 
            begin 
                RampCounter <= 0; 
                State <= 1; 
            end
            
        else if (Step == 1)
            case (State)
                0: State <= 0;
                
                1: if (RampCounter == MAX)
                     begin 
                       DurationCounter <= 0;
                       State <= 2;
                     end
                   else 
                     RampCounter <= RampCounter + 1;
                 
                2: begin
                     DurationCounter <= DurationCounter + 1;
                     if (DurationCounter == Duration) State <= 3;
                   end
                   
                3: if (RampCounter == 0) 
                       State <= 0;
                   else 
                       RampCounter <= RampCounter - 1;
                 
                default: State <= 0;
            endcase
    end

endmodule
