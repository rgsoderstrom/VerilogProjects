/*
    MsgSenders_S1C.v - container for Message Senders

*/

`timescale 1ns / 1ps

module MsgSenders_S1C #(parameter AddrWidth        = 10,
						parameter MaxSamplesPerMsg = 256,
                        parameter RdyMsgID    = 201,
						parameter SampleMsgID = 200)
                      (input wire Clock,
                       input wire Clear,
                       
                       input wire SendReadyMsg,
                       input wire SendSampleMsg,
                       input wire SampleMsgPrep,
                       
                       input wire [7:0]          SampleByte,
                       output wire               SampleByteRead,
                       input  wire [AddrWidth:0] SampleCount,                       
                   
                       output wire [7:0] OutputByte,
                       output wire       LoadOutputByte,
                       input  wire       P2S_Empty);

	//*******************************************************
	
    reg [15:0] NextSeqNumber = 0;					   
		
	wire IncrSeqNumber = SendReadyMsg | SendSampleMsg;
	wire ClearSeqNumber = Clear;
	
	always @(posedge Clock) begin
		if (ClearSeqNumber == 1)     NextSeqNumber <= 0;
		else if (IncrSeqNumber == 1) NextSeqNumber <= NextSeqNumber + 1;
	end
					   
	//*******************************************************

	wire [7:0] RdyMsgByte;
	wire [7:0] SampleMsgByte;
	
	reg OutputByteMuxSel = 0;
	
	always @(posedge Clock) begin
		if      (SendReadyMsg == 1)  OutputByteMuxSel <= 0;
		else if (SendSampleMsg == 1) OutputByteMuxSel <= 1;
	end

	assign OutputByte = OutputByteMuxSel == 0 ? RdyMsgByte : SampleMsgByte;
	
	//*******************************************************
	
	wire P2S_Load0, P2S_Load1;
	assign LoadOutputByte = P2S_Load0 | P2S_Load1;
	
	HeaderMsgSender #(.MsgID (RdyMsgID))
				  U1 (.Clock (Clock),        
 				      .Clear (Clear),
                      .Send  (SendReadyMsg),
                      .P2S_Empty (P2S_Empty),
                      .SeqNumber (NextSeqNumber),
                      .Ready     (),
                      .LoadByte  (P2S_Load0),
					  .MsgByte   (RdyMsgByte));

	SampleMsgSenderV3 #(.SampleMsgID      (SampleMsgID),
				 		.MaxSamplesPerMsg (MaxSamplesPerMsg),
                        .AddrWidth        (AddrWidth))
				    U2 (.Clock50MHz (Clock),
 				        .Clear      (Clear),
                        .PrepareToSend  (SampleMsgPrep),
						.Ready (),
						.Send           (SendSampleMsg),
						.SeqNumber      (NextSeqNumber),
						.SampleByte     (SampleByte),
						.SampleByteRead (SampleByteRead),
						.SampleCount 	(SampleCount),
					  	.P2S_Empty 		(P2S_Empty),
						.LoadByte 		(P2S_Load1),
						.MsgByteOut 	(SampleMsgByte));
                       
                       
endmodule
