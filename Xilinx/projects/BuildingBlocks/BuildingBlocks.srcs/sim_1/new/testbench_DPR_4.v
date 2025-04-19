
/*
    testbench_DPR_4 - testbench for Dual Port RAM, 4 bytes per word
                    - RAM configured as 1024 words, each 32 bits
*/    

/*
	Simulation system asserts hard "Clear" for first 100ns
*/	

/*
    look in "Tcl Console" and log file:
    C:\Users\rgsod\Documents\FPGA\Xilinx\projects\BuildingBlocks\BuildingBlocks.sim\sim_1\behav\xsim\simulate.log
*/   



// see testbench_DPR2.v for some changes not incorporated here



`timescale 1ns / 1ps

module testbench_DPR_4;

    localparam AddrWidth = 6; // 10; // 2^10 = 1024 words
    
    reg Clock = 0;
	reg Clear = 0; 
    	
    reg  [31:0] WordWriteData = 32'h88664422;
    wire [31:0] WordReadData;

	reg [AddrWidth - 1 : 0] WordReadAddress = 0;
	reg [AddrWidth - 1 : 0] WordWriteAddress = 0;

    reg  WordWrite = 0;
    reg  WordRead = 0;

    reg  [7:0] ByteWriteData = 0;
    wire [7:0] ByteReadData;

    reg  ByteAddrClear = 0;
    reg  ByteRead = 0;
    reg  ByteWrite = 0;

    DualPortRAM4 #(.AddrWidth (AddrWidth))
              U1 (.Clk (Clock),

                  .ByteClearAddr  (ByteAddrClear),
				  .ByteWriteData  (ByteWriteData),
				  .ByteWrite      (ByteWrite),

				  .ByteReadData  (ByteReadData),
				  .ByteRead      (ByteRead),
                  
				  .WordWriteData  (WordWriteData),
				  .WordWrite      (WordWrite),
				  .WordWriteAddr  (WordWriteAddress),
				  
				  .WordReadData  (WordReadData),
				  .WordRead      (WordRead),
				  .WordReadAddr  (WordReadAddress));
				  
    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");
        $monitor ($time, " word read addr 0x%h, word read data 0x%h", WordReadAddress, WordReadData);
            
            Clear = 1;
        #50 Clear = 0;
    end

    //
    // clock period
    //
    always
        #10 Clock = ~Clock;  
        
    //
    // test run
    //

    integer i, j;
    integer WC = 4; // word count, number of words initially written
        
    initial
    begin        
        #110   // wait for "clear" to go away
        
    //******************************************************************

    // Byte write
        ByteWriteData = 8'ha0;

        #20 ByteAddrClear = 1;
        #20 ByteAddrClear = 0;

        #60                
        for (i=0; i<WC*4; i=i+1)
        begin
            #20 ByteWrite = 1;
            #20 ByteWrite = 0;
            #80 ByteWriteData = ByteWriteData + 8'h11;
        end        

    // Word read
	    #20 WordReadAddress = 10'd0;
	    
        for (j=0; j<4; j=j+1)
        begin
            #20 WordRead = 1;
            #20 WordRead = 0;
            #20 WordReadAddress = WordReadAddress + 10'b1;
        end
        
    // Word write
	    #20 WordWriteAddress = 10'b0;
		
        for (j=0; j<WC; j=j+1)
        begin
            #20 WordWrite = 1;
            #20 WordWrite = 0;
            #20 WordWriteData = WordWriteData + 32'h01010101;
                WordWriteAddress = WordWriteAddress + 10'b1;
        end

    // Byte read
        #80 ByteAddrClear = 1;
        #20 ByteAddrClear = 0;
        
        for (i=0; i<WC*4; i=i+1)
        begin
            #80 ByteRead = 1;
            #20 ByteRead = 0;
        end        
        
        #200 $finish;
    end
endmodule
