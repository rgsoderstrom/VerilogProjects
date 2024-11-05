
/*
	SampleMsgSender.v
		- build and send one of a set of sample messages
		- for each set of msgs:
			- assert "Prepare" once, then "LoadAndSend" for each individual message
		- sets "AllSent" after last message
*/

`timescale 1ns / 1ps

module SampleMsgSender  #(parameter SampleMsgID       = 200,
				 		  parameter MaxSamplesPerMsg  = 32,  // max samples per message
                          parameter AddrWidth         = 10)  // up to 2^AddrWidth samples to send
				         (input  Clock50MHz,
 				          input  Clear,

 				          input        ClearReadAddr, // was Prepare,     // assert once prior to a message set
						  output       Ready,       // ready to send a message
						  input        LoadAndSend, // load samples and send one message

						  input [15:0] SeqNumber,

						  input  [15:0]          SampleWord, // A/D Sample Buffer interface
						  output [AddrWidth-1:0] SampleReadAddr,
						  output reg             SampleRead,
						  input  [AddrWidth:0]   SampleCount, // total number to send

					  	  input        P2S_Empty, // output serializer can accept a byte
						  output       LoadByte,
						  output [7:0] MsgByteOut);

	// wires from header generator to msg sender
	wire [7:0]  HeaderByte;
	wire        LastHeaderByte;
	wire [15:0] ByteCount;
	wire        ClearHeaderAddr;
	wire        NextHeaderAddr;

	// number samples this msg
	wire [15:0] NumbRemaining;
	wire [15:0] MsgSampleCount;
	reg  [15:0] SampleCountDown = 16'd0;
	assign MsgSampleCount = MaxSamplesPerMsg < NumbRemaining ? MaxSamplesPerMsg : NumbRemaining;

	// select source of next word to write to msg RAM
	reg 		DataWordMuxSel = 0;
    wire [15:0] MsgDataWord;
	assign MsgDataWord = DataWordMuxSel == 0 ? MsgSampleCount : SampleWord;

	// Sample RAM read address counter
	reg  [AddrWidth:0]   SampleReadCnt = 0;
	reg ClearSRC;  // clear read addr counter
	reg IncrSRC;   // clear read addr counter
	assign SampleReadAddr = SampleReadCnt [AddrWidth-1:0];

	always @ (posedge Clock50MHz) begin
	   if (ClearSRC == 1) SampleReadCnt <= 0;
	   if (IncrSRC  == 1) SampleReadCnt <= SampleReadCnt + 1;
	end

	// determine number of samples remaining. 16 bit, non-negative
    assign NumbRemaining = SampleCount > SampleReadCnt ? SampleCount - SampleReadCnt : 0;

	// message RAM word write address
 	localparam N = $clog2 (1 + MaxSamplesPerMsg);
 	reg  [N-1:0] MessageWriteAddr = 0;
 	wire [N-1:0] MsgDataAddr = MessageWriteAddr;
	reg          ClearMWA;
	reg          IncrMWA;

	always @ (posedge Clock50MHz) begin
	   if (ClearMWA == 1) MessageWriteAddr <= 0;
	   if (IncrMWA  == 1) MessageWriteAddr <= MessageWriteAddr + 1;
	end

    // Message RAM
    wire [7:0] MsgDataByte;
    wire ByteAddrClear;
    wire ByteReadCycle;
    reg  MsgDataWrite;
    
    DualPortRAM2 #(.AddrWidth (N))
              U1  (.Clk (Clock50MHz),
                   .ByteWriteData (8'b0),
                   .ByteWrite     (1'b0),
                   .ByteReadData  (MsgDataByte),   // ByteReadData valid 3 clocks after ByteRead asserted
                   .ByteRead      (ByteReadCycle),
                   .ByteClearAddr (ByteAddrClear),
                   .WordWriteData (MsgDataWord),
                   .WordWriteAddr (MsgDataAddr),
                   .WordWrite     (MsgDataWrite),
                   .WordReadAddr  ('b0),
                   .WordReadData  (),
                   .WordRead      (1'b0));
    
    reg SendMsg;
    
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
                  .ClearDataAddr   (ByteAddrClear),
                  .RamRead         (ByteReadCycle));

	MsgHeaderGen #(.ID (SampleMsgID), .ByteCount (8 + 2 + 2 * MaxSamplesPerMsg))
			   U3 (.Clk (Clock50MHz),
                   .ClearAddr      (ClearHeaderAddr),
                   .NextAddr       (NextHeaderAddr),
                   .SequenceNumber (SeqNumber),
                   .MsgByteCount   (ByteCount),
                   .LastReadByte   (LastHeaderByte),
                   .HeaderByte     (HeaderByte));
                   
    localparam Idle  = 0;
    localparam Prep1 = 6'h01;
                    
    localparam LoadCount1 = 6'h11;
    localparam LoadCount2 = 6'h12;
    localparam LoadCount3 = 6'h13;
    localparam LoadCount4 = 6'h14;
    localparam LoadCount5 = 6'h15;
                  
    localparam LoadData1 = 6'h21;
    localparam LoadData2 = 6'h22;
    localparam LoadData3 = 6'h23;
    localparam LoadData4 = 6'h24;
    localparam LoadData5 = 6'h25;
    localparam LoadData5A = 6'h2D;
    localparam LoadData6 = 6'h26;
    localparam LoadData7 = 6'h27;
    localparam LoadData8 = 6'h28;
    localparam LoadData9 = 6'h29;
    localparam LoadDataA = 6'h2a;
    localparam LoadDataB = 6'h2b;
                       
    localparam SendMsg1  = 6'h31;
    
    reg [5:0] state = Idle;
    
  //assign AllSent = (NumbRemaining == 0) && (Ready == 1) && (state == Idle);

    always @ (posedge Clock50MHz)
    begin
        case (state)
            Idle: if      (ClearReadAddr == 1) state <= Prep1;
                  else if (LoadAndSend == 1)   state <= LoadCount1;
    
            Prep1: state <= Idle;
            
            LoadCount1: begin DataWordMuxSel <= 0; state <= LoadCount2; end
            LoadCount2: state <= LoadCount3;
            LoadCount3: state <= LoadCount4;
            LoadCount4: state <= LoadCount5;
            LoadCount5: state <= LoadData1;

            LoadData1: begin DataWordMuxSel <= 1; state <= LoadData2; end
            LoadData2: begin SampleCountDown <= MsgSampleCount; state <= LoadData3; end
            LoadData3: if (SampleCountDown == 0) state <= SendMsg1; else state <= LoadData4;
            LoadData4:  state <= LoadData5;
            LoadData5:  state <= LoadData5A;
            LoadData5A: state <= LoadData6;
            LoadData6:  state <= LoadData7;
            LoadData7:  state <= LoadData8;
            LoadData8:  state <= LoadData9;
            LoadData9:  state <= LoadDataA;
            LoadDataA:  begin SampleCountDown <= SampleCountDown - 1; state <= LoadDataB; end
            LoadDataB:  state <= LoadData3;
                                
            SendMsg1: state <= Idle;
            
            default: state <= Idle;
        endcase
    end

    always @ (*)
    begin
        ClearSRC = (state == Prep1);
        IncrSRC  = (state == LoadData8);
        
        ClearMWA = (state == LoadCount2);
        IncrMWA  = (state == LoadCount5) || (state == LoadData9);
        
        MsgDataWrite = (state == LoadCount3) || (state == LoadData6);
        SampleRead   = (state == LoadData4);
        SendMsg      = (state == SendMsg1);
    end
    
endmodule


