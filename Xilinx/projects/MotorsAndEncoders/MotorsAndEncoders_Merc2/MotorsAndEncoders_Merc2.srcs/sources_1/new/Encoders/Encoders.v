
/*
    Encoders.v
*/    


`timescale 1ns / 1ps


module Encoders (input X1,
                 input Y1,
                 input X2,
                 input Y2,
                 
                 output OutputBit,
                 output LastBit,
                 output FirstBit,
                 input  OutputShiftClock,
                 
                 input StartCollection,
                 input StopCollection,
                 input BuildCollectionMessage,
                 input SendCollectionMessage,
                 input SampleClock,
                 
                 input Clear,
                 input Clock);
                 
    localparam SamplesPerMessage = 32; // 6; // 20 for actual
                     
    reg  SSWrite, SSRead;
    wire SSEmpty, SSFull;
    wire [7:0]  SSDataOut;
    wire [12:0] SSNumbStored;
    wire [7:0] Counts1;
    wire [7:0] Counts2;
    
    assign SSClear = Clear || StartCollection;
                                      
    SampleStorage #(.AddrWidth (12))
                U1 (.EncCounts1 (Counts1),
                    .EncCounts2 (Counts2),
                    .Write (SSWrite),
                    .Read  (SSRead),
                    .SampleOut (SSDataOut),
                    .Full  (SSFull),
                    .Empty (SSEmpty),
                    .NumberStored (SSNumbStored),
                    .Clear (SSClear),
                    .Clock (Clock));
                 
    reg  MHNewHeader, MHReadNext;
    wire MHEmpty;
    wire [7:0] MHDataOut;
                     
    MessageHeader #(.MsgID (8'h99),         // ------------------------- ?
                    .ByteCount (4 + 2 + SamplesPerMessage))
                U2 (.DataOut   (MHDataOut),
                    .Empty     (MHEmpty),
                    .ReadNext  (MHReadNext),
                    .NewHeader (MHNewHeader),
                    .Clear (Clear),
                    .Clock (Clock));                

    reg [1:0] muxSelect = 0;
    wire [7:0] MuxDataOut;

    Mux4 U3 (.in0    (MHDataOut),  
             .in1    (SSDataOut),
             .in2    (SSNumbStored [7:0]),
             .in3    ({3'b000, SSNumbStored [12:8]}),             
	  	     .select (muxSelect),
	         .out    (MuxDataOut));
	      
//    ShaftEncoderIF_Sim #(.Width (8), .BaseCount (8'h30), .Step (1))
//                     U4 (.Clock12MHz (Clock),
//                         .Clear (Clear),
//                         .LatchCounter (SampleClock),
//                         .Half (),
//                         .LatchedCount (Counts1));  
                 
//    ShaftEncoderIF_Sim #(.Width (8), .BaseCount (8'hA0), .Step (1))
//                     U5 (.Clock12MHz (Clock),
//                         .Clear (Clear),
//                         .LatchCounter (SampleClock),
//                         .Half (),
//                         .LatchedCount (Counts2)); 
                         
    ShaftEncoderIF #(.Width (8), .PrescalerWidth (2)) // prescaler takes out the 1:4 gear ratio between wheel and encoder
                     U4 (.PhaseA (X1),
                         .PhaseB (Y1),
                         .Clock12MHz (Clock),
                         .Clear (Clear),
                         .LatchCounter (SampleClock),
                         .Half (),
                         .LatchedCount (Counts1));  
                 
    ShaftEncoderIF #(.Width (8), .PrescalerWidth (2))
                     U5 (.PhaseA (X2),
                         .PhaseB (Y2),
                         .Clock12MHz (Clock),
                         .Clear (Clear),
                         .LatchCounter (SampleClock),
                         .Half (),
                         .LatchedCount (Counts2)); 
                         
    wire outputFifoEmpty;
    reg outputFifoWrite = 0, outputFifoRead = 0;
    wire [7:0] FifoDataOut;
                                 
    FIFO1 U6 (.Clk (Clock),
              .Clr (Clear),
              .Empty (outputFifoEmpty),
              .Full (),
              .WriteData (MuxDataOut),
              .ReadData (FifoDataOut),
              .NumberStored (),
              .WriteCycle (outputFifoWrite),
              .ReadCycle  (outputFifoRead));                            

    reg LoadP2S;
    wire P2SEmpty;

    SerializerPtoS U7 (.Input (FifoDataOut),
                       .Clr (Clear),   
                       .Clk (Clock),   
                       .Load      (LoadP2S),
                       .Shift     (OutputShiftClock),
				       .Empty     (P2SEmpty),
				       .FirstBit  (FirstBit), 
				       .LastBit   (LastBit),  						
                       .OutputBit (OutputBit));                         
              
reg [6:0] state = 0;
reg [7:0] sampleCountDown = 0;

initial
    state = 0;
    
always @ (posedge Clock)
	begin
		if (Clear == 1'b1)
            begin
			    state <= 0;
		    end
		    
		else if (StopCollection == 1)
            begin
			    state <= 0;
		    end
		    
		else
			case (state)
				0: if (StartCollection == 1) state <= 1; 
				   else if (BuildCollectionMessage == 1) state <= 11;
				   else if (SendCollectionMessage == 1)  state <= 51;
								
				1: if (SSFull == 1) state <= 0; else if (SampleClock == 1) state <= 2;
				2: state <= 3;
				3: state <= 1;
				
				11: begin muxSelect <= 0; state <= 12; end				    
				12: state <= 13;
				13: state <= 14; 
				14: state <= 15;
				15: state <= 16;				
				16: state <= 17;
		        17: state <= 18;				
		        18: state <= 19;
		        19: begin muxSelect <= 2; state <= 20; end
		        20: state <= 21;
		        21: begin muxSelect <= 3; state <= 22; end
		        22: state <= 23;
		        23: begin sampleCountDown <= SamplesPerMessage; state <= 24; end
		        24: begin muxSelect <= 1; state <= 25; end
		        25: begin sampleCountDown <= sampleCountDown - 1; state <= 26; end
		        26: begin if (sampleCountDown != 0) state <= 25; else state <= 27; end
		        27: state <= 0;
		    
                51: if (P2SEmpty) state <= 52;
                52: state <= 53;
                53: if (outputFifoEmpty) state <= 0; else state <= 51;
                                    
				default: state <= 0;
		endcase
	end
	
always @ (*)
	begin
		SSWrite     <= (state == 3);
		MHNewHeader <= (state == 11);
		MHReadNext  <= (state == 13) || (state == 15) || (state == 17);
		SSRead      <= (state == 25);

		outputFifoWrite <= (state == 12) || (state == 14) || (state == 16) || (state == 18) || (state == 20) || (state == 22) || (state == 26);
        outputFifoRead  <= (state == 52);
        LoadP2S         <= (state == 53);
	end
	
endmodule
