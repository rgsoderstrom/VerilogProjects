
/*
    testbench_DPR_2 - testbench for Dual Port RAM
        - word write followed by byte read
*/    

/*
	Simulation system asserts hard "Clear" for first 100ns
*/	

`timescale 1ns / 1ps

module testbench_DPR_2;

    localparam l2depth = 3; // (2 ^ l2depth) = number of words (not bytes) stored
	
    localparam l2width = 1; // 2 => 4 bytes, 32 bits
	                        // 1 => 2 bytes, 16 bits
							// 0 => 1 byte,   8 bits
							
    localparam WC = (1 << l2depth); // word count
    localparam BC = (1 << l2depth) * (1 << l2width); // byte count
    							
    reg Clock = 0;
	reg Clear = 0;
	
    reg  [8 * (1 << l2width) - 1 : 0] WordInputData = 32'h0201;
    wire [8 * (1 << l2width) - 1 : 0] WordOutputData;

	reg [l2depth - 1 : 0] WordReadAddress;
	reg [l2depth - 1 : 0] WordWriteAddress;

    reg  WordWrite = 0;
    wire SWordWrite;

    reg  [7:0] ByteInputData = 8'h10;
    wire [7:0] ByteOutputData;

    reg  ByteWrite = 0;
    wire SByteWrite;
    
    reg  IncrByteReadAddr = 0;
    wire SIncrByteReadAddr;
    
    wire Last;

    reg  ClearByteAddr = 0;
    wire SClearByteAddr;

	DualPortRAM #(.L2Width (l2width), .L2Depth (l2depth))
              U1 (.Clk (Clock),
				  .ByteWriteData  (ByteInputData),
				  .ByteWriteCycle (SByteWrite),
				  .ByteReadData   (ByteOutputData),
				  .IncrByteAddr   (SIncrByteReadAddr),
				  .ClearByteAddr  (SClearByteAddr),
				  .LastAddr       (Last),
				  .WordWriteData  (WordInputData),
		          .WordWriteCycle (SWordWrite),
				  .WordWriteAddr  (WordWriteAddress),
			      .WordReadData   (WordOutputData),
				  .WordReadAddr   (WordReadAddress));
                      
    SyncOneShot U2 (.trigger (ByteWrite),        .clk (Clock), .clr (Clear), .Q (SByteWrite)), 
                U3 (.trigger (IncrByteReadAddr), .clk (Clock), .clr (Clear), .Q (SIncrByteReadAddr)),
                U4 (.trigger (WordWrite),        .clk (Clock), .clr (Clear), .Q (SWordWrite)),      
                U6 (.trigger (ClearByteAddr),    .clk (Clock), .clr (Clear), .Q (SClearByteAddr));      


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

    integer j;
    
    initial
    begin
        
        #112   // wait for "clear" to go away
        
    //******************************************************************

        WordWriteAddress = 0;
        
        for (j=0; j<WC; j=j+1) 
        begin
            #10 WordInputData = (8'ha << 8) + j;
            #10 WordWrite = 1;
            #60 WordWrite = 0;
            #10 WordWriteAddress = WordWriteAddress + 1;
        end

            ClearByteAddr = 1;
        #60 ClearByteAddr = 0;
                
        for (j=0; j<BC-1; j=j+1)
        begin
            #10 IncrByteReadAddr = 1;
            #60 IncrByteReadAddr = 0;
        end
        
    end

endmodule
