
/*
	SampleMsgSenderV3.v
		- build and send one of a set of sample messages
		- for each set of msgs:
			- assert "PrepareToSend" once, then "Send" for each individual message
*/

`timescale 1ns / 1ps

module SampleMsgSenderV3 #(parameter SampleMsgID       = 200,
				 		   parameter MaxSamplesPerMsg  = 32,  // max samples per message
                           parameter AddrWidth         = 10)  // up to 2^AddrWidth samples to send
				         (input wire  Clock50MHz,
 				          input wire  Clear,

 				          input  wire PrepareToSend, // assert once prior to a message set
						  output wire Ready,         // ready to send a message
						  input  wire Send, 		    // send one message

						  input wire [15:0] SeqNumber,

						  input  wire [7:0]         SampleByte,  // A/D Sample RAM interface
						  output  wire              SampleByteRead,
						  input   wire[AddrWidth:0] SampleCount, // total number to send

					  	  input   wire      P2S_Empty, // output serializer can accept a byte
						  output  wire      LoadByte,  // into output serializer
						  output  wire [7:0] MsgByteOut);
						  
	// wires to/from the controller
	reg 	   SubtSentCount;
	reg        SendMsg;
	reg 	   EnableRamRead;
	reg  [1:0] MsgDataByteSel;
	//wire       SenderReady;
	wire       ByteReadCycle;
	
	assign SampleByteRead = ByteReadCycle & EnableRamRead;
	
	// wires from header generator to msg sender
	wire [7:0]  HeaderByte;
	wire        LastHeaderByte;
	wire [15:0] ByteCount;
	wire        ClearHeaderAddr;
	wire        NextHeaderAddr;
						  
	//*********************************************************************************
	
	// number samples remining and number to send this msg
	reg  [AddrWidth:0] NumbRemaining;
	wire [15:0] NextMsgSampleCount;
  //wire [AddrWidth:0] NextMsgSampleCount;
	
	always @(posedge Clock50MHz) begin
		if      (PrepareToSend == 1) NumbRemaining <= SampleCount;		
		else if (SubtSentCount == 1) NumbRemaining <= NumbRemaining - NextMsgSampleCount;	
	end
	
	assign NextMsgSampleCount = MaxSamplesPerMsg < NumbRemaining ? MaxSamplesPerMsg : NumbRemaining;

	//*********************************************************************************

	// next byte to write to msg sender
	reg [7:0] MsgDataByte;
	
	always @(posedge Clock50MHz)
		case (MsgDataByteSel)
			2'b00: MsgDataByte <= NextMsgSampleCount [7:0];
			2'b01: MsgDataByte <= NextMsgSampleCount [15:8];
			2'b10: MsgDataByte <= SampleByte;
			2'b11: MsgDataByte <= 8'b0;
		endcase

	MsgSender U2 (.Clock (Clock50MHz),
                  .Clear (Clear),
                  .Ready (Ready),
                  .Send  (SendMsg),
                  .OutputByte      (MsgByteOut),
                  .HeaderByte      (HeaderByte),
                  .LastHeaderByte  (LastHeaderByte),
                  .ByteCount       (ByteCount),
                  .ClearHeaderAddr (ClearHeaderAddr),
                  .NextHeaderAddr  (NextHeaderAddr),
                  .P2SLoad         (LoadByte),
                  .P2SEmpty        (P2S_Empty),
				  .DataByte        (MsgDataByte),
                  .ClearDataAddr   (),
                  .RamRead         (ByteReadCycle));

	MsgHeaderGen #(.ID (SampleMsgID), .ByteCount (8 + 2 + 2 * MaxSamplesPerMsg))
			   U3 (.Clk (Clock50MHz),
                   .ClearAddr      (ClearHeaderAddr),
                   .NextAddr       (NextHeaderAddr),
                   .SequenceNumber (SeqNumber),
                   .MsgByteCount   (ByteCount),
                   .LastReadByte   (LastHeaderByte),
                   .HeaderByte     (HeaderByte));
                   
    localparam Idle   = 4'h00;
    localparam Send1  = 4'h01;
    localparam Send2  = 4'h02;
    localparam Send3  = 4'h03;
    localparam Send4  = 4'h04;
    localparam Send5  = 4'h05;
    localparam Send6  = 4'h06;
    localparam Send7  = 4'h07;
    localparam Send8  = 4'h08;
    localparam Send9  = 4'h09;
    localparam Send10 = 4'h0A;
                    
    reg [3:0] state = Idle;
    
    always @ (posedge Clock50MHz)
    begin
		if (Clear == 1)
			state <= Idle;
			
        else case (state)
            Idle:  if (Send == 1) state <= Send1;
            
			Send1: begin EnableRamRead <= 0; state <= Send2; end
			
			Send2: if (ByteReadCycle == 1) state <= Send3;
			
			Send3: begin MsgDataByteSel <= 0; state <= Send4; end
			
			Send4: if (ByteReadCycle == 1) state <= Send5;
			
			Send5: begin MsgDataByteSel <= 2'b1; state <= Send6; end
			
			Send6: begin EnableRamRead <= 1; state <= Send7; end
			
			Send7: if (ByteReadCycle == 1) state <= Send8;
			
			Send8: begin MsgDataByteSel <= 2'd2; state <= Send9; end
			
			Send9: if (Ready == 1) state <= Send10;
			
			Send10: state <= Idle;

            default: state <= Idle;
        endcase
    end

    always @ (*)
    begin
        SendMsg       = (state == Send1);
		SubtSentCount = (state == Send10);
    end
    
endmodule


