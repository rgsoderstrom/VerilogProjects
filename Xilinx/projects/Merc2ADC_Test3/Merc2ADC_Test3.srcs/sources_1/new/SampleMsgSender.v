
/*
	SampleMsgSender.v
		- build and send one of a set of sample messages
		- for each set of msgs:
			- assert "Prep" once, then "Send" for each individual message
		- sets "AllSent" after last message
*/

`timescale 1ns / 1ps

module SampleMsgSender  #(parameter SampleMsgID       = 200,
				 		  parameter MaxSamplesPerMsg  = 32,  // max samples per message
                          parameter AddrWidth         = 10)  // up to 2^AddrWidth samples to send
				         (input  Clock50MHz,        
 				          input  Clear,
					   
 				          input        Prepare,     // assert once prior to a message set
						  output       Ready,       // ready to send a message
						  input        LoadAndSend, // load samples and send one message
						  output       AllSent,     // true when all sample data has been sent
							 
						  input [15:0] SeqNumber,
							 
						  input  [15:0]          SampleWord, // A/D Sample Buffer interface
						  output [AddrWidth-1:0] ReadAddr,
						  output                 SampleRead,
						  input  [AddrWidth:0]   WriteAddr, // total number to send
						
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
	reg  [15:0] SampleCountDown;
	assign MsgSampleCount = MaxSamplesPerMsg < NumbRemaining ? MaxSamplesPerMsg : NumbRemaining;
	
	// select source of next word to write to msg RAM
	reg 		DataWordMuxSel;
    wire [15:0] MsgDataWord;
	assign MsgDataWord = DataWordMuxSel == 0 ? MsgSampleCount : SampleWord;
	
	// Sample RAM read address counter
	reg [AddrWidth-1:0] ReadAddrCounter = 0;
	reg ClearSRA;  // clear read addr counter
	reg IncrSRA;   // clear read addr counter
	assign ReadAddr = ReadAddrCounter;
	
	// determine number of samples remaining. 16 bit, non-negative
    assign NumbRemaining = WriteAddr > ReadAddr ? WriteAddr - ReadAddr : 0;             

	// message RAM word write address
 	localparam N = $clog2 (1 + MaxSamplesPerMsg);
 	reg  [N-1:0] MessageWriteAddr = 0;
 	wire [N-1:0] MsgDataAddr = MessageWriteAddr;
	reg          ClearMWA;
	reg          IncrMWA;
	
    // Message RAM
    wire [7:0] MsgDataByte;
    wire ByteAddrClear;
    wire ByteReadCycle;
    reg  MsgDataWrite;
    
    DualPortRAM2 #(.AddrWidth (N)) 
              U1  (.Clk (Clock50MHz),
                   .ByteWriteData (8'b0),
                   .ByteWrite     (0),
                   .ByteReadData  (MsgDataByte),   // ByteReadData valid 3 clocks after ByteRead asserted
                   .ByteRead      (ByteReadCycle), 
                   .ByteClearAddr (ByteAddrClear),
                   .WordWriteData (MsgDataWord),
                   .WordWriteAddr (MagDataAddr),
                   .WordWrite     (MsgDataWrite),
                   .WordReadAddr  ('b0),
                   .WordReadData  (),
                   .WordRead      (0));
    
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
                  .ClearDataAddr   (), // not used
                  .RamRead         (ByteReadCycle));
	
	MsgHeaderGen #(.ID (SampleMsgID), .ByteCount (8 + 2 + 2 * MaxSamplesPerMsg)) 
			   U3 (.Clk (Clock50MHz),
                   .ClearAddr      (ClearHeaderAddr),
                   .NextAddr       (NextHeaderAddr),
                   .SequenceNumber (SeqNumber),
                   .MsgByteCount   (ByteCount), 
                   .LastReadByte   (LastHeaderByte),
                   .HeaderByte     (HeaderByte));
                   
    localparam Idle = 0;                   
    localparam Prep = 6'h01;   
                    
    localparam WriteCount1  = 6'h10;                   
    localparam WriteCount2  = 6'h11;                   
    localparam WriteCount2A = 6'h12;                   
    localparam WriteCount2B = 6'h13;                   
    localparam WriteCount3  = 6'h14;     
                  
    localparam WriteData1  = 6'h21;                   
    localparam WriteData2  = 6'h22;                   
    localparam WriteData2A = 6'h23;                   
    localparam WriteData2B = 6'h24;                   
    localparam WriteData3  = 6'h25;
                       
    localparam SendMsg1    = 6'h30;      
    
    reg [5:0] state = Idle;
    
    assign AllSent = (NumbRemaining == 0) && (state == Idle);             

    always @ (posedge Clock50MHz)
    begin
        case (state)
            Idle: if (Prepare == 1) state <= Prep; 
                  else if (LoadAndSend == 1) state <= WriteCount1;    
    
            Prep: state <= Idle;
            
            WriteCount1: begin DataWordMuxSel <= 0; 
                               state <= WriteCount2; 
                         end            
    
            WriteCount2:  state <= WriteCount2A;                    
            WriteCount2A: state <= WriteCount2B;        
            WriteCount2B: state <= WriteCount3;        
    
            WriteCount3: begin DataWordMuxSel <= 1;
                               SampleCountDown <= MsgSampleCount;
                               state <= WriteData1;
                         end
                         
            WriteData1: if (SampleCountDown == 0) state <= SendMsg1;
                        else state <= WriteData2;
                        
            WriteData2:  state <= WriteData2A;                     
            WriteData2A: state <= WriteData2B;                     
            WriteData2B: state <= WriteData3;
            
            WriteData3: begin SampleCountDown <= SampleCountDown - 1; 
                              state <= WriteData1; 
                        end
                                 
            SendMsg1: state <= Idle;
            
            default: state <= Idle;            
        endcase
    end

    always @ (*)
    begin
        ClearSRA = (state == Prep);    
        IncrSRA  = (state == WriteData3);
        ClearMWA = (state == WriteCount1);
        IncrMWA  = (state == WriteData3);    
        
        MsgDataWrite = (state == WriteCount2) || (state == WriteData2);
        SendMsg      = (state == SendMsg1);            
    end
    
endmodule
	
	
	