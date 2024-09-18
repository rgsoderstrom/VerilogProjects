/*
    testbench_Processing.v
*/

`timescale 1ns / 1ps

module testbench_Processing;

    localparam AddrBits = 4;
    localparam DataBits = 16;
	
    reg Clock = 0;
	reg Clear = 0;

    reg [15:0] RamWordIn = 16'h0;  // word shifted in, a byte at a time
    	
	// Processing Block Control & status
	reg Run = 0;
	wire SRun;
    wire Busy;
    wire Done;
	
	// Processing <-> RAM interface
    wire [DataBits - 1 : 0] OutputData;  // output from processing
    wire [DataBits - 1 : 0] InputData;   // input to processing
	wire [AddrBits - 1 : 0] WriteAddress;	
	wire [AddrBits - 1 : 0] ReadAddress;
	wire                    ramWrite;
	wire                    ramRead;
		
	// RAM byte interface
	reg  [7:0] ByteIn = 8'h10;
	wire [7:0] ByteOut;
	reg        ByteWriteCycle = 0;
	reg        ByteReadCycle = 0;
	reg        ByteAddrClear = 0;

	wire       SByteWriteCycle;
	wire       SByteReadCycle;
	wire       SByteAddrClear;
	
    // Components    
    Loopback_Processing #(.AddrBits (AddrBits), .DataBits (DataBits))
                    Proc (.Clock (Clock),
                          .Clear (Clear),                            
                          .Run  (SRun),
                          .Busy (Busy),
                          .Done (Done),
                          .WriteData  (OutputData),
                          .WriteCycle (ramWrite),
                          .WriteAddr  (WriteAddress),
                          .ReadData   (InputData),
						  .ReadCycle  (ramRead),
                          .ReadAddr   (ReadAddress));
                          
                          

    DualPortRAM2 #(.AddrWidth (AddrBits))
             RAM (.Clk (Clock),
                  .ByteWriteData  (ByteIn),
                  .ByteWrite      (SByteWriteCycle),                         
                  .ByteReadData   (ByteOut),
                  .ByteRead       (SByteReadCycle),                         
			      .ByteClearAddr  (SByteAddrClear),
                  .WordWriteData  (OutputData),
                  .WordWrite      (ramWrite),
                  .WordWriteAddr  (WriteAddress),                         
                  .WordReadData   (InputData),
                  .WordRead       (ramRead),
                  .WordReadAddr   (ReadAddress));
                                    
                  
    SyncOneShot U3 (.trigger (ByteWriteCycle), .clk (Clock), .clr (Clear), .Q (SByteWriteCycle)), 
                U4 (.trigger (ByteReadCycle),  .clk (Clock), .clr (Clear), .Q (SByteReadCycle)),
                U5 (.trigger (Run),            .clk (Clock), .clr (Clear), .Q (SRun)),      
                U6 (.trigger (ByteAddrClear),  .clk (Clock), .clr (Clear), .Q (SByteAddrClear));      

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

            ByteAddrClear = 1;
        #60 ByteAddrClear = 0;

        $display ("RAM word in");                

        for (j=0; j<12; j=j+1) // two bytes written each iteration  
        begin                
            $display ($time, ": 0x%h", RamWordIn);
            #10 ByteIn = RamWordIn [7:0];
            #10 ByteWriteCycle = 1;
            #60 ByteWriteCycle = 0;

            #10 ByteIn = RamWordIn [15:8];
            #10 ByteWriteCycle = 1;
            #60 ByteWriteCycle = 0;
            #10 RamWordIn = RamWordIn + 1;
        end

            Run = 1;
        #30 Run = 0;
        
        #2000 ByteAddrClear = 1;
        #60   ByteAddrClear = 0;
                
        $display ("RAM byte out");                
        
        for (j=0; j<24; j=j+1) 
        begin
            #10 ByteReadCycle = 1;
            #60 ByteReadCycle = 0;
            $display ($time, " 0x%h", ByteOut);
        end
       
    #500 $finish;
    end

endmodule
