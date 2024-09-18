/*
    ShaftEncoderIF_Sim - provide a known stream of counts to test "Encoders" 
                         sampling and message generation logic
*/    

`timescale 1ns / 1ps

module ShaftEncoderIF_Sim #(parameter Width = 4,
                            parameter MaxCount = 7,  // limit to +- this value
                            parameter AllowNeg = 1)
                           (input PhaseA,  // interpreted as "count up by 1" command
                            input PhaseB,  //     "          "count down by 1" command
                            input Clock12MHz,
                            input Clear, // active high
                            input LatchCounter,
                            output Half,
                            output reg [Width-1:0] LatchedCount);  
        
    assign countUp   = PhaseA; // just aliases
    assign countDown = PhaseB;
    
    integer Count = 0;
    integer Max = MaxCount;
    integer Min = AllowNeg ? (-1 * MaxCount) : 0;
    
    assign Half = (Count [Width-1] != Count [Width-2]);
    
    always @ (posedge Clock12MHz)
    begin
        if (Clear == 1'b1)
        begin
            LatchedCount <= 0;
            Count <= 0;
        end
                    
        else if (LatchCounter == 1'b1)
        begin            
            if (countUp)
            begin
                if (Count < Max - 1) Count = Count + 1;
                else                 Count = Max;
            end
            
            if (countDown)
            begin         
                if (Count > Min + 1) Count = Count - 1;
                else                 Count = Min;
            end    
                
            LatchedCount = Count;
    
        end
    end
        
endmodule


