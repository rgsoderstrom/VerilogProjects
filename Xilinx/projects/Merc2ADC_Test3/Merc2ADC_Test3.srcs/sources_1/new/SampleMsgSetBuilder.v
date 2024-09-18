
/*
	SampleMsgSetBuilder.v 
		- build and send a set of 32 sample messages
			- assert "Clear" once, then "Send" for each individual message
		- sets "AllSent" after last message
*/

`timescale 1ns / 1ps

module SampleMsgSetBuilder #(parameter SampleMsgID = 200,
							 parameter NumberMsgs = 32)
				            (input  Clock50MHz,        
 				             input  Clear,  	   // asserted prior to each message set
					   
							 output       Ready,   // ready to send a message, (state == Idle)
							 input        Send,    // send one message
							 output       AllSent, // true when NumberMsgs sent
							 
							 input [15:0] SeqNumber,
							 
							 input [7:0]  SampleByte, // RAM interface
							 output       ByteRead,
						
							 input        P2S_Empty, // output serializer
							 output       LoadByte, 
							 output [7:0] MsgByteOut);

	// wires from header generator to msg sender
	wire [7:0]  HeaderByte;
	wire        LastHeaderByte;
	wire [15:0] ByteCount;
	wire        ClearHeaderAddr;
	wire        NextHeaderAddr;

	// message counter
	wire [5:0] MsgCounter;
	assign AllSent = (MsgCounter == NumberMsgs) && (Ready == 1);
	
	CounterUEC #(.Width (6))
             MC (.Enable (Send),
				 .Clr    (Clear),  
                 .Clk    (Clock50MHz),  
                 .AtZero (),
                 .AtMax  (),
                 .Q      (MsgCounter));
		
	MsgSender MS (.Clock  (Clock50MHz),
                  .Clear  (Clear),                   
                  .Ready (Ready),
                  .Send  (Send),
                  .OutputByte      (MsgByteOut), 
                  .HeaderByte      (HeaderByte), 
                  .LastHeaderByte  (LastHeaderByte), 
                  .ByteCount       (ByteCount),
                  .ClearHeaderAddr (ClearHeaderAddr),
                  .NextHeaderAddr  (NextHeaderAddr),
                  .P2SLoad         (LoadByte),
                  .P2SEmpty        (P2S_Empty),
				  .DataByte        (SampleByte),    
                  .ClearDataAddr   (), // not used
                  .RamRead         (ByteRead));
	
	MsgHeaderGen #(.ID (SampleMsgID), .ByteCount (8 + 2 * 256)) 
			   MH (.Clk (Clock50MHz),
                   .ClearAddr      (ClearHeaderAddr),
                   .NextAddr       (NextHeaderAddr),
                   .SequenceNumber (SeqNumber),
                   .MsgByteCount   (ByteCount), 
                   .LastReadByte   (LastHeaderByte),
                   .HeaderByte     (HeaderByte));
endmodule
	
	
	