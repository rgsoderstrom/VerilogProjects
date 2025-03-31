
/*
	HeaderMsgSender.v - build and send any header-only message
*/

`timescale 1ns / 1ps

module HeaderMsgSender #(parameter MsgID = 100)
				       (input  wire Clock,        
 				        input  wire Clear,
					   
                        input wire        Send, // from controller
                        input wire        P2S_Empty,
                        input wire [15:0] SeqNumber,
						
                        output  wire      Ready,    // ready to send, to controller
                        output  wire      LoadByte, // to P2S serializer
					    output  wire[7:0] MsgByte);

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
