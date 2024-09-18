
/*
    SampleStorage.v
*/    

`timescale 1ns / 1ps

module SampleStorage #(parameter DataWidth = 8,       // number of data bits wide
                       parameter AddrWidth = 12)      // FIFO capacity = (2 ^ AddrWidth)
                     (input [DataWidth-1:0] EncCounts1,
                      input [DataWidth-1:0] EncCounts2,
                      input                 Write,
                      input                 Read,

                      output [DataWidth-1:0] SampleOut,
                      output                 Full,
                      output                 Empty,
                      output [AddrWidth:0]   NumberStored,
                                      
                      input Clear,
                      input Clock);
         
    wire [DataWidth-1:0] fifoIn;           
    reg fifoWrite;
    reg muxSelect;
                     
    FIFO1 #(.DataWidth (DataWidth), .AddrWidth (AddrWidth))
        U1 (.Clk   (Clock),
            .Clr   (Clear),               
            .Full  (Full),
            .Empty (Empty),
            .WriteData  (fifoIn),
            .ReadData   (SampleOut),
            .WriteCycle (fifoWrite),
            .ReadCycle  (Read),
            .NumberStored (NumberStored));
                
    Mux2 #(.Width (DataWidth))
        U2 (.in0 (EncCounts1), .in1 (EncCounts2), .select (muxSelect), .out (fifoIn));
                
    reg [2:0] state = 0;
            
	initial
	begin
        state = 0;
    end
         
    always @ (posedge Clock)
        if (Clear == 1'b1)
            begin
                state <= 0;
            end

        else case (state)  
            0: if (Write == 1) state <= 1;
            1: state <= 2; 
            2: state <= 3; 
            3: state <= 0;
            
            default: state <= 0; 
        endcase
            
    always @ (*)
        begin
            fifoWrite = (state == 1) || (state == 3);
            muxSelect = (state == 2) || (state == 3);    
        end
                              
endmodule
