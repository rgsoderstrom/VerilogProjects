/*
    WindowGenerator.v
        - generate trapezoidal window for ping envelope
*/

`timescale 1ns / 1ps

module WindowGenerator #(parameter Width = 12,      // bits
                                   RampStep = 1,
                                   Duration = 1024) // time at max level, clocks
                        (input  Clock,
                         input  Clear,
                         input  Trigger,
                         input  Step,
                         output reg WindowDone,
                         output [Width-1:0] Window);
                         
    localparam MAX = 12'hbff; // (1 << Width) - 1;
                             
    reg [Width-1:0] RampCounter; // counts clocks during transitions
    reg [15:0] DurationCounter;  // counts clocks while at max
    reg [2:0] State;
            
    assign Window = RampCounter;
                                 
    initial
    begin
        RampCounter <= 0;
        DurationCounter <= 0;
        WindowDone <= 0;
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
                WindowDone <= 0;
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
                     RampCounter <= RampCounter + RampStep;
                 
                2: begin
                     DurationCounter <= DurationCounter + 1;
                     if (DurationCounter == Duration) State <= 3;
                   end
                   
                3: if (RampCounter == 0) 
                       State <= 4;
                   else 
                       RampCounter <= RampCounter - RampStep;
          
                4: begin WindowDone <= 1; State <= 0; end
                       
                default: State <= 0;
            endcase
    end

//    always @(*)
//      begin
//        WindowDone <= (State == 4); 
//      end
      
endmodule

