
/*
    testbench_Router.v
*/    

`timescale 1ns / 1ps

module testbench_Router;

    reg  Clock = 0;
	reg  Clear = 0;
	
	reg [7:0] MsgByteStream [0:63];
    reg [7:0] StreamCount = 0;  // number of bytes in MsgByteStream
    reg [7:0] StreamIndex = 0;
    	
    wire [7:0] MessageByte;
    assign MessageByte = MsgByteStream [StreamIndex];
    
    reg MsgByteReady = 0;
    wire SMsgByteReady;

    wire [15:0] SyncWord;
    wire [15:0] MessageID;
    wire [15:0] ByteCount;
    wire [15:0] SequenceNumber;
    wire        MsgComplete;

    wire [7:0] MsgDataByte;
    wire ClearAddr1;
    wire WriteData1;
    wire ClearAddr2;
    wire WriteData2;
    
    MsgRouter2 #(.ID1 (16), .ID2 (32))
             U1 (.Clock (Clock),
                 .Clear (Clear),
		         .MessageByte (MessageByte),
				 .MessageByteReady (SMsgByteReady),
                 .SyncWord  (SyncWord),
                 .MessageID (MessageID),
                 .ByteCount (ByteCount),
                 .SequenceNumber (SequenceNumber),
			     .MessageComplete (MsgComplete),
				 .DataByte (MsgDataByte),
				 .ClearMsg1 (ClearAddr1), 
				 .WriteMsg1 (WriteData1),
				 .ClearMsg2 (ClearAddr2), 
				 .WriteMsg2 (WriteData2));
	
	SyncOneShot U2 (.trigger (MsgByteReady), .clk (Clock), .clr (Clear), .Q (SMsgByteReady));
		
	wire [15:0] WordReadData;
	reg  [4:0]  WordReadAddr = 0;
	reg  [15:0] WordWriteData;
	reg  [4:0]  WordWriteAddr = 0;
	
	reg WordWrite = 0;
	wire SWordWrite;
	
	reg WordRead = 0;
	wire SWordRead;
	
    DualPortRAM2 #(.AddrWidth (5)) 
             U3   (.Clk (Clock),
                   .ByteWriteData (MsgDataByte),
                   .ByteReadData  (),
                   .ByteWrite     (WriteData1),
                   .ByteRead      (), 
                   .ByteClearAddr (ClearAddr1),
                   .WordWriteData (),
                   .WordReadData  (WordReadData),  // WordReadData valid 2 clocks after WordReadAsserted
                   .WordWriteAddr (),
                   .WordReadAddr  (WordReadAddr),
                   .WordWrite     (1'b0),
                   .WordRead      (SWordRead));
	
	SyncOneShot U4 (.trigger (WordWrite), .clk (Clock), .clr (Clear), .Q (SWordWrite));
	SyncOneShot U5 (.trigger (WordRead),  .clk (Clock), .clr (Clear), .Q (SWordRead));
	
	localparam BPW = 3;
	
	wire [8*BPW-1:0] Msg32Data;
	 
    MessageWord #(.BytesPerWord (BPW))
              U6 (.Clock (Clock),
				  .ClearAddr (ClearAddr2),
				  .WriteByte (WriteData2),
				  .DataByte  (MsgDataByte),
				  .DataWord  (Msg32Data));
	
    //
    // test bench initializations
    //    
    initial
    begin
        $readmemh("test1.mem", MsgByteStream);
        StreamCount = 8'd25;    
    end		
    		         
    initial
    begin
        $display ("module: %m");
    //    $monitor ($time, " state %d, msgByte 0x%h, WriteByte %h", U1.state, U1.MessageByte, U1.WriteDataByte);
                            
            Clear = 1;
        #50 Clear = 0;
    end

    //
    // clock period
    //
    always
        #5 Clock = ~Clock;  
        
    //
    // test run
    //
    
    integer j;

    initial
    begin    
        #125
        for (j=0; j<StreamCount; j=j+1)
        begin
            #50 MsgByteReady = 1;
            #50 MsgByteReady = 0;
                StreamIndex = StreamIndex + 1;
        end
        
        #50 WordReadAddr = 0; 
        
        for (j=0; j<3; j=j+1)
        begin
                WordRead = 1;
            #50 WordRead = 0;
            #50 WordReadAddr = WordReadAddr + 1;         
        end


//            WordWriteData = WordReadData + 8'd3;
//        #50 WordWrite = 1;        
//        #50 WordWrite = 0;        

//        #50 WordReadAddr = 0;        
//        #50 WordReadAddr = WordReadAddr + 1; 
//        #50 WordReadAddr = WordReadAddr + 1; 
        
        
        
        
        #200 $finish;    
    
    end

endmodule



