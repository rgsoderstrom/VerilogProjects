/*
    testbench_Loopback.v
        - test all FPGA Loopback logic
*/

`timescale 1ns / 1ps

module testbench_Loopback;

    reg  Clock = 0;
	reg  ClearBar = 1;
	
	//*************************************************
	
	// simulate Arduino slowly shifting bits in to FPGA
	reg inputDataBit = 0;
	reg inputShiftClock = 0;
	reg inputByteReady = 0;  // all bits have been shifted in

	//*************************************************
	
	// simulate Arduino gathering bits shifted out
	wire outputBit;
	reg  outputBitShiftClock = 0;
	wire lastBit;
	wire firstBit;
	reg [7:0] receivedByte;

	//*************************************************
	
	Loopback U1 (.Clock               (Clock),
				 .ClearBar            (ClearBar),
                 .InputBit            (inputDataBit),
                 .InputBitShiftClock  (inputShiftClock),
                 .InputByteDone       (inputByteReady),
                 .OutputBit           (outputBit),
                 .OutputBitShiftClock (outputBitShiftClock),
                 .LastBit             (lastBit),
                 .FirstBit            (firstBit));

	//*************************************************

    //
    // test bench initializations
    //    
	
	//**********************************************************
	
	// Data Message
	reg  [7:0] DataMsgByteStream [0:63];
    reg  [7:0] DataMsgCount;  // number of bytes in MsgByteStream
    reg  [7:0] DataMsgIndex;    	
    wire [7:0] DataMessageByte;
    assign DataMessageByte = DataMsgByteStream [DataMsgIndex];
	
	// Run Proc Message
	reg  [7:0] RunProcMsgByteStream [0:7];
    reg  [7:0] RunProcMsgCount;  // number of bytes in MsgByteStream
    reg  [7:0] RunProcMsgIndex;    	
    wire [7:0] RunProcMessageByte;
    assign RunProcMessageByte = RunProcMsgByteStream [RunProcMsgIndex];
	
	// Send Data Message
	reg  [7:0] SendDataMsgByteStream [0:7];
    reg  [7:0] SendDataMsgCount;  // number of bytes in MsgByteStream
    reg  [7:0] SendDataMsgIndex;    	
    wire [7:0] SendDataMessageByte;
    assign SendDataMessageByte = SendDataMsgByteStream [SendDataMsgIndex];
	
	
    initial
    begin
        $readmemh("DataMsg.mem", DataMsgByteStream);
        DataMsgCount = (DataMsgByteStream [5] << 8) + DataMsgByteStream [4]; //8'd32;    
		DataMsgIndex = 0;   

        $readmemh("RunProcMsg.mem", RunProcMsgByteStream);
        RunProcMsgCount = (RunProcMsgByteStream [5] << 8) + RunProcMsgByteStream [4];    
	    RunProcMsgIndex = 0;   

        $readmemh("SendDataMsg.mem", SendDataMsgByteStream);
        SendDataMsgCount = (SendDataMsgByteStream [5] << 8) + SendDataMsgByteStream [4];    
	    SendDataMsgIndex = 0;   
    end		
    		         
	//**********************************************************
    		         
	initial
    begin
        $display ($time, " module: %m");
        $monitor ($time, " controller state %d", U1.U5.state);
            
            ClearBar = 0;
        #50 ClearBar = 1;
    end

    //
    // clock period
    //
    always
        #5 Clock = ~Clock;  
        
    //
    // test run
    //
	
    integer i, j, k;
	integer M;
		
    //******************************************		
	// shift each Data Msg byte into Loopback
		
    initial
    for (M=0; M<4; M=M+1)		
    begin
        #103 $display ($time, " send DataMsg"); 
            
        DataMsgIndex <= 0;

        for (j=0; j<DataMsgCount; j=j+1)
        begin
            for (i=0; i<8; i=i+1)
            begin
                #10 inputDataBit <= DataMessageByte [7 - i]; // MS bit out first                          
                #11 inputShiftClock <= 1'b1;
                #21 inputShiftClock <= 1'b0;
            end
            
            #10 inputByteReady <= 1;
            #20 inputByteReady <= 0;
                  
            DataMsgIndex <= DataMsgIndex + 1;
        end
    
        //************************************************
                
        #100 $display ($time, " send RunProcMsg");
                 
        RunProcMsgIndex <= 0;
            
        for (j=0; j<RunProcMsgCount; j=j+1)
        begin
            for (i=0; i<8; i=i+1)
            begin
                #10 inputDataBit <= RunProcMessageByte [7 - i]; // MS bit out first                          
                #11 inputShiftClock <= 1'b1;
                #21 inputShiftClock <= 1'b0;
            end
            
            #10 inputByteReady <= 1;
            #20 inputByteReady <= 0;
                  
            RunProcMsgIndex <= RunProcMsgIndex + 1;
        end
    

        // look for "Ready" messages out of Loopback    
        while (firstBit == 0)
        begin
            #100 $display ($time, " wait for \"Ready message\" first bit");
        end
    
        for (j=0; j<8; j=j+1) // expect 8 byte header-only message
        begin        
            for (k=0; k<8; k=k+1)
            begin
                #50 receivedByte [7-k] <= outputBit;
                #51 outputBitShiftClock <= 1;
                #52 outputBitShiftClock <= 0;
            end
             
            $display ($time, " 0x%x", receivedByte);
        end
        
    //************************************************
     
//        #1000 $display ($time, " send SendDataMsg");
//
//        for (j=0; j<SendDataMsgCount; j=j+1)
//        begin
//			for (i=0; i<8; i=i+1)
//			  begin
//				#10 inputDataBit <= SendDataMessageByte [7 - i]; // MS bit out first                          
//				#11 inputShiftClock <= 1'b1;
//				#21 inputShiftClock <= 1'b0;
//			  end
//		
//			  #10 inputByteReady <= 1;
//			  #20 inputByteReady <= 0;
//			  
//              SendDataMsgIndex <= SendDataMsgIndex + 1;
//        end
//        
//    // look for "Data" messages out of Loopback    
//        while (firstBit == 0)
//        begin
//            #100 $display ($time, " wait for first bit");
//        end
//
//        for (j=0; j<32; j=j+1) // expect 32 byte message
//        begin        
//            for (k=0; k<8; k=k+1)
//            begin
//              #50 receivedByte [7-k] <= outputBit;
//              #51 outputBitShiftClock <= 1;
//              #52 outputBitShiftClock <= 0;
//            end
//         
//            $display ($time, " 0x%x", receivedByte);
//        end


    // make sure it stops sending
            
//        $display ($time, " look for more bytes");
        
//        while (firstBit == 0)
//        begin
//            #100 $display ($time, " wait for first bit");
//        end
        
        #2000 $display ($time, " M loop end");
    end // "M" loop
    
endmodule
