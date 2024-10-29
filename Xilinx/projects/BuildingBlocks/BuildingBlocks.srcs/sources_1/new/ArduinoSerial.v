/*
    ArduinoSerial.v -container for Arduino serial inteface
*/


`timescale 1ns / 1ps

module ArduinoSerial (input Clock,        
			  	      input Clear, // active high
					   
					// input data bytes and control to Message Router
					  output [7:0] InputByte,
					  output       InputByteReady,

					// output data bytes and control from MessageBuilders
					  input [7:0]  OutputByte,
					  input        LoadOutputByte,
					  output       P2S_Empty,
					
					// sequence number
					  output [15:0] NextSeqNumber, // to all Message Builders
					  input         IncrSeqNumber, // logical "or" of all SendMsg commands
					  
				    // input bits from Arduino, connected to IO pins
                      input InputBit,
                      input InputBitShiftClock,
                      input InputByteDone,
                      					   
				    // output bits to Arduino, connected to IO pins
                      output OutputBit,
                      input  OutputBitShiftClock,
                      output LastBit,
                      output FirstBit);

    wire SInputBitShiftClock;
    wire SInputByteDone;
    wire SOutputBitShiftClock;
    
	//************************************************************************
	
	reg SeqNumberCounter = 0;
	
	always @(posedge Clock) begin
		if (Clear == 1)
			SeqNumberCounter = 0;

		else if (IncrSeqNumber == 1)
			SeqNumberCounter = SeqNumberCounter + 1;
	end
	
	assign NextSeqNumber = SeqNumberCounter + 1;
	
	//************************************************************************
	
	SyncOneShot U1 (.trigger (InputBitShiftClock),  .clk (Clock), .clr (0/*Clear*/), .Q (SInputBitShiftClock)),
	            U2 (.trigger (InputByteDone),       .clk (Clock), .clr (0/*Clear*/), .Q (SInputByteDone)),
	            U3 (.trigger (OutputBitShiftClock), .clk (Clock), .clr (0/*Clear*/), .Q (SOutputBitShiftClock));
			
	SerializerStoP #(.Width (8)) 
                U4 (.DataIn  (InputBit),
                    .Shift   (SInputBitShiftClock),
                    .Done    (SInputByteDone),
                    .Clr     (Clear),
                    .Clk     (Clock),                        
                    .Ready   (InputByteReady),
                    .DataOut (InputByte));			
			   
   	SerializerPtoS #(.Width (8))
                U5 (.Input (OutputMsgByte),
                    .Clr   (Clear),
                    .Clk   (Clock),
                    .Load  (LoadOutputByte),
                    .Shift (SOutputBitShiftClock),
				    .Empty (P2S_Empty),
				    .FirstBit  (FirstBit),
				    .LastBit   (LastBit),
                    .OutputBit (OutputBit));
endmodule
