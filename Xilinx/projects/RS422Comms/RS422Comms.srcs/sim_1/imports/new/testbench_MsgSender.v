/*
    testbench_MsgSender.v
*/

`timescale 1ns / 1ps

module testbench_MsgSender;

    reg  Clock = 0;
	reg  Clear = 0;
	
	reg  SendMessage = 0;
	wire SSendMessage;

    wire P2SEmpty;
    	
    wire ClearHeaderAddr;
    wire NextHeaderAddr;
    wire ClearDataAddr;
    wire ramReadCycle;
    
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
    wire [7:0] P2S_Byte;
	
    MsgHeaderGen #(.ID (16'h5678),
                   .ByteCount (16'd14))
   	       	   U1 (.Clk       (Clock),
                   .ClearAddr (ClearHeaderAddr),   
                   .SequenceNumber (SequenceNumber),
                   .NextAddr       (NextHeaderAddr),
                   .LastReadByte   (LastHeaderByte),
                   .MsgByteCount   (ByteCount),
                   .HeaderByte     (HeaderByte));
                
    DualPortRAM2 #(.AddrWidth (4)) 
               U2 (.Clk (Clock),
                   .ByteWriteData (8'b0),
                   .ByteReadData  (DataByte),   // ByteReadData valid 3 clocks after ByteRead asserted
                   .ByteWrite (1'b0),
                   .ByteRead  (ramReadCycle), 
                   .ByteClearAddr (ClearDataAddr),
                   .WordWriteData (WordWriteData),
                   .WordReadData  (),  // WordReadData valid 2 clocks after WordReadAsserted
                   .WordWriteAddr (WordWriteAddr),
                   .WordReadAddr (0),
                   .WordWrite (SWordWriteCycle),
                   .WordRead (0));

     MsgSender U3 (.Clock (Clock),
                   .Clear (Clear),
                   .Ready (DataMsgSent),
                   .Send  (SendMessage),
                   .OutputByte (MsgOutputByte), 
                   .HeaderByte (HeaderByte),
                   .LastHeaderByte  (LastHeaderByte), 
                   .ByteCount       (ByteCount),
                   .ClearHeaderAddr (ClearHeaderAddr),
                   .NextHeaderAddr  (NextHeaderAddr),
                   .P2SLoad  (LoadP2S),
                   .P2SEmpty (P2SEmpty),                   
                   .DataByte (DataByte),                               
                   .ClearDataAddr (ClearDataAddr), 
                   .RamRead       (ramReadCycle));
                    

    SyncOneShot U4 (.trigger (SendMessage),    .clk (Clock), .clr (Clear), .Q (SSendMessage)),
                U5 (.trigger (WordWriteCycle), .clk (Clock), .clr (Clear), .Q (SWordWriteCycle));
                
    Register U6 (.Input (MsgOutputByte),
                 .Clr (Clear),   // sync, active high
                 .Clk (Clock),   // pos edge triggered
                 .Load (LoadP2S),
  				 .Empty (P2SEmpty),     // ready to load,
                 .Output (P2S_Byte),
                 .GetNext (0));

    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        $monitor ($time, " msg byte 0x%h", MsgOutputByte);
            
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
            WordWriteData = 16'h3412;
        #10 WordWriteCycle = 1;
        #50 WordWriteCycle = 0;

            WordWriteAddr = WordWriteAddr + 1;
            WordWriteData = 16'h7856;
        #10 WordWriteCycle = 1;
        #50 WordWriteCycle = 0;

            WordWriteAddr = WordWriteAddr + 1;
            WordWriteData = 16'hbc9a;
        #10 WordWriteCycle = 1;
        #50 WordWriteCycle = 0;

            SendMessage = 1;
        #50 SendMessage = 0;
        
//            SequenceNumber <= SequenceNumber + 1;
//      #1500 SendMessage = 1;
//        #50 SendMessage = 0;
        
//            SequenceNumber <= SequenceNumber + 1;
//      #1500 SendMessage = 1;
//        #50 SendMessage = 0;
        
        #1500 $finish;
     end

endmodule
