/*
    WindowGenerator
*/    

`timescale 1ns / 1ps

module WindowGenerator #(parameter Width        = 16,    // bits
                                   FractionBits = 10,
                                   Duration     = 1024) // time at max level, clocks
                        (input  wire Clock,
                         input  wire Clear,
                         input  wire Trigger,
                         input  wire Step,
                         output reg  Done,
                         output wire signed [Width-1:0] Window);
                         
    localparam One = (1 << FractionBits);

                             
    reg signed [15:0] RampCounter;     // counts clocks during transitions
    reg [15:0] DurationCounter; // counts clocks while at max
    reg [3:0] State;
            
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
                
                1: if (RampCounter == One)
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
                       State <= 4;
                   else 
                       RampCounter <= RampCounter - 1;
					   
				4: State <= 0;
                 
                default: State <= 0;
            endcase
    end
	
	always @ (*)
	begin
		Done = (State == 4);
	end

endmodule
