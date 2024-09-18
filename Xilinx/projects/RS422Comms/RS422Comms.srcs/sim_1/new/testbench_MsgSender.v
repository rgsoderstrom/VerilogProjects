/*
    testbench_MsgSender.v
*/

`timescale 1ns / 1ps

module testbench_MsgSender;

    reg  Clock = 0;
	reg  Clear = 0;
	
	reg  SendMessage = 0;
	wire SSendMessage;

    reg P2SEmpty = 1;
    	
    wire ClearHeaderAddr;
    wire NextHeaderAddr;
    wire ClearDataAddr;
    wire NextDataAddr;
    
    wire [7:0]  HeaderByte;
    wire [15:0] ByteCount;
    wire        LastHeaderByte;
    
    wire [7:0] DataByte;

    reg [15:0] WordWriteData = 16'd0;
    reg        WordWriteCycle = 0;
    wire       SWordWriteCycle;
    reg  [3:0] WordWriteAddr = 0;
    
    reg [15:0] SequenceNumber = 16'hdef0;
    wire [7:0] MsgOutputByte;
	
    MsgHeader #(.ID (16'h5678),
                .ByteCount (16'd14))
		    U1 (.Clk       (Clock),
                .ClearAddr (ClearHeaderAddr),   
                .SequenceNumber (SequenceNumber),
                .NextAddr       (NextHeaderAddr),
                .LastReadByte   (LastHeaderByte),
                .MsgByteCount   (ByteCount),
                .ByteReadData   (HeaderByte));
                
    DualPortRAM #(.L2Width (1),
                  .L2Depth (4)) 
              U2 (.Clk (Clock),
                  .ByteWriteData  (8'd0),
                  .ByteWriteCycle (1'd0),
                  .ByteReadData  (DataByte),
                  .IncrByteAddr  (NextDataAddr),
				  .ClearByteAddr (ClearDataAddr),
				  .LastAddr (),
                  .WordWriteData  (WordWriteData),
                  .WordWriteCycle (SWordWriteCycle),
                  .WordWriteAddr  (WordWriteAddr),
                  .WordReadData (),
                  .WordReadAddr (0));

     MsgSender U3 (.Clock (Clock),
                   .Clear (Clear),
                   .Ready (DataMsgSent),
                   .Start (SendMessage),
                   .OutputByte (MsgOutputByte), 
                   .HeaderByte (HeaderByte),
                   .LastHeaderByte (LastHeaderByte), 
                   .ByteCount      (ByteCount),
                   .ClearHeaderAddr (ClearHeaderAddr),
                   .NextHeaderAddr  (NextHeaderAddr),
                   .P2SLoad  (LoadP2S),
                   .P2SEmpty (P2SEmpty),                   
                   .DataByte (DataByte),                               
                   .ClearDataAddr (ClearDataAddr), 
                   .NextDataAddr  (NextDataAddr));
                    

    SyncOneShot U4 (.trigger (SendMessage),    .clk (Clock), .clr (Clear), .Q (SSendMessage)),
                U5 (.trigger (WordWriteCycle), .clk (Clock), .clr (Clear), .Q (SWordWriteCycle));
                   
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        //$monitor ($time, " out data ready %d, out data 0x%h", outDataReady, outputData);
            
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

    //integer j;
    
    initial
    begin
       #103 Clear = 0;
            WordWriteData = 16'haabb;
        #10 WordWriteCycle = 1;
        #50 WordWriteCycle = 0;

            WordWriteAddr = WordWriteAddr + 1;
            WordWriteData = 16'hccdd;
        #10 WordWriteCycle = 1;
        #50 WordWriteCycle = 0;

            WordWriteAddr = WordWriteAddr + 1;
            WordWriteData = 16'heeff;
        #10 WordWriteCycle = 1;
        #50 WordWriteCycle = 0;

            SendMessage = 1;
        #50 SendMessage = 0;
        
        #1500 $finish;
     end

endmodule
