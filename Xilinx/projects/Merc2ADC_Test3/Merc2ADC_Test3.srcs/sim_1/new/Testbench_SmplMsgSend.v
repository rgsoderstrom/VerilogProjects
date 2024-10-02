/*
    Testbench_SmpleMsgSend - Sample Message Sender

*/

`timescale 1ns / 1ps

module Testbench_SmplMsgSend;

    localparam AddrWidth = 6;
    localparam MaxSamplesPerMsg = 8;
    
    reg  Clock = 0;
    reg  Clear = 1;

    reg [15:0] SeqNumber = 16'h1357;
    
    // stream of samples
    reg [15:0] InputRamp = 16'hAA01;
    reg [AddrWidth:0]    SampleWriteCount = 0;
    wire [AddrWidth-1:0] SampleWriteAddr = SampleWriteCount [AddrWidth-1:0];
    
    //wire [15:0]          WordWriteData;
    wire [15:0]          SampleReadData;
    wire [AddrWidth-1:0] SampleReadAddr;
    reg                  SampleWrite = 0;
    wire                 SampleRead;


    DualPortRAM2 #(.AddrWidth (AddrWidth)) 
              U1  (.Clk (Clock),
                   .ByteWriteData (8'b0),
                   .ByteReadData  (),
                   .ByteWrite     (1'b0),
                   .ByteRead      (1'b0), 
                   .ByteClearAddr (1'b0),
                   .WordWriteData (InputRamp),
                   .WordReadData  (SampleReadData),
                   .WordWriteAddr (SampleWriteAddr),
                   .WordReadAddr  (SampleReadAddr),
                   .WordWrite     (SampleWrite),
                   .WordRead      (SampleRead));

    reg Prepare = 0;
    reg LoadAndSend = 0;
    
    wire ReadyToSend;
    wire AllSent;
    wire P2S_Empty;
    wire P2S_Load1;
    wire [7:0] SampleMsgByte;
    
    SampleMsgSender  #(.MaxSamplesPerMsg (MaxSamplesPerMsg),
                       .AddrWidth (AddrWidth))  
				   U2 (.Clock50MHz  (Clock),        
 				       .Clear       (Clear),
					   .Prepare     (Prepare),
					   .Ready       (ReadyToSend),       
					   .LoadAndSend (LoadAndSend), 
					   .AllSent     (AllSent),     							 
					   .SeqNumber   (SeqNumber),							 
					   .SampleWord  (SampleReadData),
					   .ReadAddr    (SampleReadAddr),
				       .SampleRead  (SampleRead),
					   .SampleCount (SampleWriteCount),
				  	   .P2S_Empty   (P2S_Empty),
					   .LoadByte    (P2S_Load1), 
					   .MsgByteOut  (SampleMsgByte));

    //*******************************************************************
    // simulate Serializer
    
    reg [7:0] Serializer = 0;
    reg [7:0] SerializerCntDown = 0; 
    assign P2S_Empty = (SerializerCntDown == 0);
    
    always @ (posedge Clock) begin
        if (P2S_Load1 == 1) begin
            Serializer <= SampleMsgByte;
            SerializerCntDown <= 8'd16;        
        end
        
        else if (SerializerCntDown != 0)
            SerializerCntDown <= SerializerCntDown - 1;                
    end
    
	//*************************************************

    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        $monitor ($time, " Serializer %h", Serializer);
    //    $monitor ($time, " state %d, msgByte 0x%h, WriteByte %h", U1.state, U1.MessageByte, U1.WriteDataByte);
                            
            Clear = 1;
        #50 Clear = 0;
    end
	
    //
    // clock period
    //
    always
        #10 Clock = ~Clock;  


    //
    // Test scenario
    //
    
    //integer i;
    
    initial
    begin
	   // write samples into RAM
	   #100 
	       for (SampleWriteCount=0; SampleWriteCount<28; SampleWriteCount=SampleWriteCount+1)
	       begin
	         #30 SampleWrite <= 1;
	         #20 SampleWrite <= 0;
	         #60 InputRamp <= InputRamp + 1;       
	       end
		  
        // send messages
        #100 Prepare <= 1;
        #20  Prepare <= 0;
        
        #100 LoadAndSend <= 1;
        #20  LoadAndSend <= 0;
		
		#14000 LoadAndSend <= 1;
        #20   LoadAndSend <= 0;
		 
		#14000 LoadAndSend <= 1;
        #20   LoadAndSend <= 0;
		 
		#14000 LoadAndSend <= 1;
        #20   LoadAndSend <= 0;
		 
		#14000 LoadAndSend <= 1;
        #20   LoadAndSend <= 0;
		 
	//	#1500 $finish;

    end    
    
    
    

endmodule



