/*
    ArduinoSerial.v -container for Arduino serial inteface
*/


`timescale 1ns / 1ps

module ArduinoSerial (input wire Clock,        
			  	      input wire Clear, // active high
					   
					// input data bytes and control to Message Router
					  output [7:0] InputByte,
					  output       InputByteReady,

					// output data bytes and control from MessageBuilders
					  input  wire [7:0] OutputByte,
					  input  wire       LoadOutputByte,
					  output wire       P2S_Empty,
					
				    // input bits from Arduino. These are connected to IO pins
                      input wire InputBit,
                      input wire InputBitShiftClock,
                      input wire InputByteDone,
                      					   
				    // output bits to Arduino. These are connected to FPGA IO pins
                      output wire OutputBit,
                      input  wire  OutputBitShiftClock,
                      output wire LastBit,
                      output wire FirstBit);

    wire SInputBitShiftClock;
    wire SInputByteDone;
    wire SOutputBitShiftClock;
    
	//************************************************************************
	
	SyncOneShot U1 (.trigger (InputBitShiftClock),  .clk (Clock), .clr (1'b0/*Clear*/), .Q (SInputBitShiftClock)),
	            U2 (.trigger (InputByteDone),       .clk (Clock), .clr (1'b0/*Clear*/), .Q (SInputByteDone)),
	            U3 (.trigger (OutputBitShiftClock), .clk (Clock), .clr (1'b0/*Clear*/), .Q (SOutputBitShiftClock));
			
	SerializerStoP #(.Width (8)) 
                U4 (.DataIn  (InputBit),
                    .Shift   (SInputBitShiftClock),
                    .Done    (SInputByteDone),
                    .Clr     (Clear),
                    .Clk     (Clock),                        
                    .Ready   (InputByteReady),
                    .DataOut (InputByte));			
			   
   	SerializerPtoS #(.Width (8))
                U5 (.Input (OutputByte),
                    .Clr   (Clear),
                    .Clk   (Clock),
                    .Load  (LoadOutputByte),
                    .Shift (SOutputBitShiftClock),
				    .Empty (P2S_Empty),
				    .FirstBit  (FirstBit),
				    .LastBit   (LastBit),
                    .OutputBit (OutputBit));
endmodule
