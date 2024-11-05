/*
    Testbench_SmpleMsgSendV3 - Sample Message Sender
*/

`timescale 1ns / 1ps

module Testbench_SmplMsgSendV3;

    localparam AddrWidth = 6;
    localparam MaxSamplesPerMsg = 8;
    
    reg  Clock = 0;
    reg  Clear = 1;

    reg [15:0] SeqNumber = 16'h1357;
    
    // stream of samples
    reg [15:0] InputRamp = 16'hAA01;
    reg [AddrWidth:0]    SampleWriteCount = 0;
    wire [AddrWidth-1:0] SampleWriteAddr = SampleWriteCount [AddrWidth-1:0];
    
    wire [7:0] SampleByte;
    reg        SampleWrite = 0;
    wire       SampleByteRead;

    reg Prepare = 0;

    DualPortRAM2 #(.AddrWidth (AddrWidth)) 
              U1  (.Clk (Clock),
                   .ByteClearAddr (Prepare),

                   .ByteWriteData (8'b0),
                   .ByteWrite     (1'b0),                   

                   .ByteReadData  (SampleByte),
                   .ByteRead      (SampleByteRead), 

                   .WordWriteData (InputRamp),
                   .WordWriteAddr (SampleWriteAddr),
                   .WordWrite     (SampleWrite),

                   .WordReadData  (),
                   .WordReadAddr  ('b0),
                   .WordRead      ('b0));
                   

    reg Send = 0;
    
    wire ReadyToSend;
    wire AllSent;
    wire P2S_Empty;
    wire P2S_Load1;
    wire [7:0] SampleMsgByte;
    
    SampleMsgSenderV3  #(.MaxSamplesPerMsg (MaxSamplesPerMsg),
                         .AddrWidth (AddrWidth))  
				   U2 (.Clock50MHz  (Clock),        
 				       .Clear       (Clear),
					   .PrepareToSend  (Prepare),					   
					   .Ready          (ReadyToSend),       
					   .Send           (Send), 
					   .SeqNumber      (SeqNumber),							 
					   .SampleByte     (SampleByte),
				       .SampleByteRead (SampleByteRead),
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
        $monitor ($time, " P2S_Load %h, Serializer %h", P2S_Load1, Serializer);
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
	       for (SampleWriteCount=0; SampleWriteCount<22; SampleWriteCount=SampleWriteCount+1)
	       begin
	         #30 SampleWrite <= 1;
	         #20 SampleWrite <= 0;
	         #60 InputRamp <= InputRamp + 1;       
	       end
		  
        // send messages
        #100 Prepare <= 1;
        #20  Prepare <= 0;
        
        #100 Send <= 1;
        #20  Send <= 0;
		
		#14000 Send <= 1;
        #20    Send <= 0;
		 
		#14000 Send <= 1;
        #20    Send <= 0;
		 
		#14000 Send <= 1;
        #20    Send <= 0;
		 
	//	#14000 Send <= 1;
    //    #20    Send <= 0;
		 
		#15000 $finish;

    end    
endmodule



