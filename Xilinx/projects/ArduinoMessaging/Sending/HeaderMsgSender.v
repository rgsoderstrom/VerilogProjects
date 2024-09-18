
/*
	HeaderMsgSender.v - build and send any header-only message
*/

`timescale 1ns / 1ps

module HeaderMsgSender #(parameter MsgID = 100)
				       (input  Clock,        
 				        input  Clear,
					   
                        input        Send, // from controller
                        input        P2S_Empty,
                        input [15:0] SeqNumber,
						
                        output       Ready,    // ready to send, to controller
                        output       LoadByte, // to P2S serializer
					    output [7:0] MsgByte);

	// wires from header generator to msg sender
	wire [7:0]  HeaderByte;
	wire        LastHeaderByte;
	wire [15:0] ByteCount;
	wire        ClearHeader;
	wire        NextHeaderByte;

	MsgSender MS (.Clock  (Clock),
                  .Clear  (Clear),                   
                  .Ready (Ready),
                  .Send  (Send),
                  .OutputByte      (MsgByte), 
                  .HeaderByte      (HeaderByte), 
                  .LastHeaderByte  (LastHeaderByte), 
                  .ByteCount       (ByteCount),
                  .ClearHeaderAddr (ClearHeader),
                  .NextHeaderAddr  (NextHeaderByte),
                  .P2SLoad         (LoadByte),
                  .P2SEmpty        (P2S_Empty),
				  .DataByte      (),    
                  .ClearDataAddr (), 
                  .RamRead       ());

	MsgHeaderGen #(.ID (MsgID)) 
			   MH (.Clk (Clock),
                   .ClearAddr      (ClearHeader),
                   .NextAddr       (NextHeaderByte),
                   .SequenceNumber (SeqNumber),
                   .MsgByteCount   (ByteCount), 
                   .LastReadByte   (LastHeaderByte),
                   .HeaderByte     (HeaderByte));
endmodule
