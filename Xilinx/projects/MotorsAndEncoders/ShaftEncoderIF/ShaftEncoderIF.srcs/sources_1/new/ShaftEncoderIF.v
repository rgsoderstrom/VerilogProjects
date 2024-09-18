
//
// ShaftEncoderIF  
//

// prescaler - added to remove the effects of a 4:1 speed increase from
//             the shaft we want to measure and the encoder shaft

`timescale 1ns / 1ps

module ShaftEncoderIF #(parameter Width = 4,
                        parameter PrescalerWidth = 0)
                       (input PhaseA,
                        input PhaseB,
                        input Clock12MHz,
                        input Clear, // active high
                        input LatchCounter,
                        output Half,
                        output reg [Width-1:0] LatchedCount);  
                   
    wire Change;
    wire Direction;
    wire [Width+PrescalerWidth-1:0] Count;

    wire ClearCounter = Clear | LatchCounter;
        
    initial
        LatchedCount = 0;        
    	
    Detector 
		detect1 (.PA (PhaseA), .PB (PhaseB), .clk (Clock12MHz), .clr (Clear), 
                 .Change (Change), .Direction (Direction));
                     										
    Counter #(.Width (Width + PrescalerWidth)) 
        counter1 (.Change (Change), .UDbar (Direction), .Half (Half),
                  .Clk (Clock12MHz), .Clr (ClearCounter), .Count (Count));

    always @ (posedge Clock12MHz)
    begin
        if (Clear == 1'b1)
            LatchedCount <= 0;
            
        else if (LatchCounter == 1'b1)
            LatchedCount <= Count [Width+PrescalerWidth-1 -: Width];
    end
    
endmodule

