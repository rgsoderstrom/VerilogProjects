/*
    testbench_Header
*/    

/*
	Simulation system asserts hard "Clear" for first 100ns
*/	

`timescale 1ns / 1ps

module testbench_Header;

    reg Clock = 0;
    reg Clear = 0;
    
	reg  ClearAddr = 0;
	wire SClearAddr;
	
	reg  NextAddr = 0;
	wire SNextAddr;
	
	wire [15:0] MsgByteCount;
	wire        Last;
	wire [7:0]  HeaderByte;
	
    reg [15:0] SequenceNumber = 16'hdef0;
	
    MsgHeader #(.ID (16'h5678),
                .ByteCount (16'h9abc))
		    U1 (.Clk (Clock),
                .ClearAddr (SClearAddr),
                .NextAddr  (SNextAddr),
                .SequenceNumber (SequenceNumber),
                .MsgByteCount   (MsgByteCount),
                .LastReadByte   (Last),
                .ByteReadData   (HeaderByte));

    SyncOneShot U2 (.trigger (ClearAddr), .clk (Clock), .clr (Clear), .Q (SClearAddr)), 
                U3 (.trigger (NextAddr),  .clk (Clock), .clr (Clear), .Q (SNextAddr));

     
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

    integer i;
    
    initial
    begin        
        #112   // wait for "clear" to go away

        for (i=0; i<2; i=i+1)
        begin
            #50 ClearAddr = 1;
            #50 ClearAddr = 0;
    
            while (Last != 1)
            begin
                #50 NextAddr = 1;
                #50 NextAddr = 0;        
            end
            
            SequenceNumber = SequenceNumber + 1;
        end

        #500 $finish;
    end
            
endmodule

