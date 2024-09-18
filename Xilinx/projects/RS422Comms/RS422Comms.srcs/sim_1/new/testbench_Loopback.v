/*
    testbench_Loopback.v
        - test all FPGA Loopback logic
*/

`timescale 1ns / 1ps

module testbench_Loopback;

    reg  Clock = 0;
	reg  ClearBar = 1;
	
	//*************************************************
	
	// simulate Arduino slowly shifting bits in
	wire inputDataBit;
	reg inputShiftClock;
	reg inputByteReady;  // all bits have been shifted in

	
	reg  [7:0] FileByte;                // 
	assign inputDataBit = FileByte [7];
	
	//*************************************************
	
	// simulate Arduino gathering bits shifted out
	wire outputBit;
	reg  outputBitShiftClock;
	wire lastBit;
	wire firstBit;
	
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
	
	reg  [7:0] DataMsgByteStream [0:63];
    reg  [7:0] DataMsgCount;  // number of bytes in MsgByteStream
    reg  [7:0] DataMsgIndex;    	
    wire [7:0] DataMessageByte;
    assign DataMessageByte = DataMsgByteStream [DataMsgIndex];
	
	
    initial
    begin
        $readmemh("DataMsg.mem", DataMsgByteStream);
        DataMsgCount = 8'd32;    
		DataMsgIndex = 0;   
    end		
    		         
	initial
    begin
        $display ("module: %m");
        //$monitor ($time, " out data ready %d, out data 0x%h", outDataReady, outputData);
            
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
	
    integer i, j;
		
    initial
    begin
		#103 
		
		//******************************************
		
		// shift each Data Msg byte into Loopback
		
        for (j=0; j<DataMsgCount; j=j+1)
        begin
			for (i=0; i<8; i=i+1)
			  begin
				#21 inputShiftClock <= 1'b1;
				#11 inputShiftClock <= 1'b0;
				#10 inputBit <= DataMsgByte [i];                          
			  end
		
			  #10 inputByteReady <= 1;
			  #20 inputByteReady <= 0;
			  
              DataMsgIndex <= DataMsgIndex + 1;
        end
        

        
        #1500 $finish;
     end

endmodule











