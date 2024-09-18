//
// Loopback.v - top level module for RS-422 loopback tests
//

`timescale 1ns / 1ps

module Loopback (input Clock,
				 input ClearBar,
                 input InputBit,
                 input InputBitShiftClock,
                 input InputByteDone,
                 output OutputBit,
                 input  OutputBitShiftClock,
                 output LastBit,
                 output FirstBit);
	
	// short aliases for width & depth
	localparam M = 10; // address bits 
	localparam N = 16; // data bits per word

    // Data Message Byte Count.
	localparam DMBC = 32; 

	localparam loadMsgID = 16'd100; // messages from Arduino
	localparam runMsgID  = 16'd101;
    localparam sendMsgID = 16'd102;
    
    localparam dataMsgID = 16'd100; // messages to Arduino, was 103 
    localparam rdyMsgID  = 16'd104;
	
    wire Clear;
//  assign Clear = !ClearBar;
    
	// wires for input section
    wire SInputBitShiftClock;
	wire SInputByteDone;
	wire [7:0] InputByte;
	wire       InputByteReady;
	
	// wires for msg router, controller, RAM and processing
	wire        MessageComplete;
	wire [15:0] MessageID;
	wire [7:0]  MessageByte;
	wire        ClearMsg1RamWriteAddr;
	wire        WriteMsg1Byte;
	
	wire RdyMsgSent;
	wire DataMsgSent;
	wire RunProcessing;
	wire SendReadyMsg;
	wire SendDataMsg;
	wire IncrSeqCntr;
	wire MsgMuxSelect;
	wire ProcessingDone;
	
	wire [M-1:0] ReadAddress;
	wire [N-1:0] InputData;    // input data words from PC
							   // connected to RAM read data output
	
	wire [M-1:0] WriteAddress;
	wire [N-1:0] OutputData;   // processing output, sent back to PC
							   // connected to RAM write data input
	
	wire         WriteRAM;
	wire         ReadRAM;
	
	wire [7:0] DataByteMsg1;
	wire       NextMsg1DataByte;
 //wire       ClearMsg1RamAddr;
		
	// wires for output message generation
	wire       P2SLoad1;
	wire       P2SLoad2;
	wire       P2SEmpty;
	wire [7:0] DataMsgByte;
    wire [7:0] RdyMsgByte;
    wire       ClearMsg1RamReadAddr;
  //wire       NextMsg1DataByte;
	wire       ClearHeaderAddr1;
	wire       NextHeaderAddr1;

	wire [7:0]  HeaderByteMsg1;
	wire        LastHeaderByte1;
	wire [15:0] ByteCountMsg1;

	wire        ClearHeaderAddr2;
	wire        NextHeaderAddr2;
	wire [7:0]  HeaderByteMsg2;
	wire        LastHeaderByte2;
	wire [15:0] ByteCountMsg2;

	wire [15:0] SeqNumber;
	wire [7:0]  OutputMsgByte;
	
	// wires for output
	wire LoadOutputByte;
    wire SOutputBitShiftClock;
    
	// combinatorial logic
	assign ClearMsg1RamAddr = ClearMsg1RamReadAddr | ClearMsg1RamWriteAddr;
	assign LoadOutputByte   = P2SLoad1 | P2SLoad2;
	
	reg [27:0] ResetCounter;
    assign Clear = (ResetCounter == 28'b1);

	initial
	   ResetCounter = 50_000_000;
	   
	always @ (posedge Clock)
	   if (ClearBar == 0)
	       ResetCounter = 50_000_000;
	   else if (ResetCounter != 28'b0)
	       ResetCounter <= ResetCounter - 1;
		
		
	SyncOneShot U1 (.trigger (InputBitShiftClock),  .clk (Clock), .clr (Clear), .Q (SInputBitShiftClock)),
	            U2 (.trigger (InputByteDone),       .clk (Clock), .clr (Clear), .Q (SInputByteDone)),
	           U15 (.trigger (OutputBitShiftClock), .clk (Clock), .clr (Clear), .Q (SOutputBitShiftClock));
			
	SerializerStoP #(.Width (8)) 
                U3 (.DataIn  (InputBit),
                    .Shift   (SInputBitShiftClock),
                    .Done    (SInputByteDone),
                    .Clr     (Clear),
                    .Clk     (Clock),                        
                    .Ready   (InputByteReady),
                    .DataOut (InputByte));			
			   
	MsgRouter2 #(.ID1 (loadMsgID), 
	             .ID2 (999)) // not used
             U4 (.Clock (Clock),
                 .Clear (Clear),
			 	 .MessageByte (InputByte),
				 .MessageByteReady (InputByteReady),
                 .SyncWord (),
                 .MessageID (MessageID),
                 .ByteCount (),
                 .SequenceNumber (),
			     .MessageComplete (MessageComplete),
				 .DataByte (MessageByte),
				 .ClearMsg1 (ClearMsg1RamWriteAddr),
				 .WriteMsg1 (WriteMsg1Byte));
//				 .ClearMsg2 (),
//				 .WriteMsg2 ());				
     
	Loopback_Ctrl #(.LoadDataMsgID      (loadMsgID),
                    .RunProcessingMsgID (runMsgID),
                    .SendDataMsgID      (sendMsgID))
                U5 (.Clock (Clock),
                    .Clear (Clear),
                    .MessageComplete (MessageComplete),
					.MessageID (MessageID),					   
                    .RunProcessing (RunProcessing),
                    .SendReadyMsg (SendReadyMsg),
                    .SendDataMsg (SendDataMsg),
                    .IncrSeqCntr (IncrSeqCntr),
                    .ProcessingComplete (ProcessingDone),
                    .MsgMuxSelect (MsgMuxSelect),
                    .RdyMsgSent (RdyMsgSent),
                    .DataMsgSent (DataMsgSent));
	 
	Loopback_Processing #(.AddrBits (10),
                          .DataBits (16))
                      U6 (.Clock (Clock),
                          .Clear (Clear),                            
                          .Run (RunProcessing),
                          .Busy (),
                          .Done (ProcessingDone),
                          .WriteData  (OutputData),
                          .WriteCycle (WriteRAM),
                          .WriteAddr  (WriteAddress),                         
                          .ReadData   (InputData),
						  .ReadCycle  (ReadRAM),
                          .ReadAddr   (ReadAddress));

	DualPortRAM2 #(.AddrWidth (M))
              U7 (.Clk (Clock),
                  .ByteWriteData (MessageByte),
                  .ByteWrite     (WriteMsg1Byte),                         
                  .ByteReadData  (DataByteMsg1),
                  .ByteRead      (NextMsg1DataByte),                         
			      .ByteClearAddr (ClearMsg1RamAddr),
                  .WordWriteData (OutputData),
                  .WordWrite     (WriteRAM),
                  .WordWriteAddr (WriteAddress),                         
                  .WordReadData  (InputData),
                  .WordRead      (ReadRAM),
                  .WordReadAddr  (ReadAddress));
				                    
	Mux2 #(.Width (8))
 		U8 (.in0 (DataMsgByte),  
            .in1 (RdyMsgByte),
			.select (MsgMuxSelect),
	        .out (OutputMsgByte));
	 
	CounterUEC #(.Width (16))
			 U9 (.Enable (IncrSeqCntr),
		         .Clr    (Clear), 
                 .Clk    (Clock),
                 .Output (SeqNumber));

	// loopback data msg
	MsgSender U10 (.Clock (Clock),
                   .Clear (Clear),                   
                   .Ready (DataMsgSent),
                   .Send  (SendDataMsg),
                   .OutputByte (DataMsgByte),
                   .HeaderByte (HeaderByteMsg1),
                   .LastHeaderByte (LastHeaderByte1), 
                   .ByteCount (ByteCountMsg1),
                   .ClearHeaderAddr (ClearHeaderAddr1),
                   .NextHeaderAddr (NextHeaderAddr1),                   
                   .P2SLoad  (P2SLoad1),
                   .P2SEmpty (P2SEmpty),                   
                   .DataByte      (DataByteMsg1),
                   .ClearDataAddr (ClearMsg1RamReadAddr), 
                   .RamRead       (NextMsg1DataByte));
				   
	// ready msg
	MsgSender U11 (.Clock (Clock),
                   .Clear (Clear),                   
                   .Ready (RdyMsgSent),
                   .Send  (SendReadyMsg),
                   .OutputByte (RdyMsgByte),
                   .HeaderByte (HeaderByteMsg2),
                   .LastHeaderByte (LastHeaderByte2), 
                   .ByteCount (ByteCountMsg2),
                   .ClearHeaderAddr (ClearHeaderAddr2),
                   .NextHeaderAddr (NextHeaderAddr2),                   
                   .P2SLoad (P2SLoad2),
                   .P2SEmpty (P2SEmpty),                   
                   .DataByte (8'd0),
                   .ClearDataAddr (), 
                   .RamRead ());

	// data msg
	MsgHeaderGen #(.ID (dataMsgID), .ByteCount (DMBC))
			  U12 (.Clk (Clock),
                   .ClearAddr (ClearHeaderAddr1),
                   .NextAddr (NextHeaderAddr1),
                   .SequenceNumber (SeqNumber),
                   .MsgByteCount (ByteCountMsg1),
                   .LastReadByte (LastHeaderByte1),
                   .HeaderByte (HeaderByteMsg1));
	 
	// ready msg
	MsgHeaderGen #(.ID (rdyMsgID), .ByteCount (8)) // header only msg
			  U13 (.Clk (Clock),
                   .ClearAddr (ClearHeaderAddr2),
                   .NextAddr (NextHeaderAddr2),
                   .SequenceNumber (SeqNumber),
                   .MsgByteCount (ByteCountMsg2),
                   .LastReadByte (LastHeaderByte2),
                   .HeaderByte (HeaderByteMsg2));
	 
	SerializerPtoS #(.Width (8))
                U14 (.Input (OutputMsgByte),
                     .Clr (Clear),
                     .Clk (Clock),
                     .Load  (LoadOutputByte),
                     .Shift (SOutputBitShiftClock),
				     .Empty (P2SEmpty),
				     .FirstBit (FirstBit),
				     .LastBit  (LastBit),
                     .OutputBit (OutputBit));
	 
	 
endmodule

