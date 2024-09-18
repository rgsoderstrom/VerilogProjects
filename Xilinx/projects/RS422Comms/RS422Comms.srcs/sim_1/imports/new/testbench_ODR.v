
/*
    testbench_ODR - testbench for WordInByteOutRAM (was called OutputDataRAM)
*/    

/*
	Simulation system asserts hard "Clear" for first 100ns
*/	

`timescale 1ns / 1ps

module testbench_ODR;

    localparam baw = 4;   // see WordInByteOutRAM.v for description 
    localparam l2idb = 1;  

    reg Clear = 0;    
    reg Clock = 0;

    reg [8 * (1 << l2idb) - 1 : 0] inputData = 16'h0201; // inputData = 32'h04030201;
    wire [7:0] outputData;
    
    reg BeginWrite = 0;
    wire SBeginWrite;
    reg [baw - l2idb - 1 : 0] writeAddr = 4'b0;
    
    
    wire ready;
    
    reg BeginRead = 0;
    wire SBeginRead;
       
    WordInByteOutRAM #(.BAW (baw), .L2IDB (l2idb))
                   U1 (.Clk (Clock),
                       .Clr (Clear),
                       .WriteData    (inputData),
                       .WriteAddress (writeAddr),
                       .WriteCycle   (SBeginWrite),
                       .ReadyToWrite (ready),
                       .ReadData      (outputData),
                       .ReadCycle     (SBeginRead));
                       
    SyncOneShot U2 (.trigger (BeginWrite), .clk (Clock), .clr (Clear), .Q (SBeginWrite)), 
                U3 (.trigger (BeginRead),  .clk (Clock), .clr (Clear), .Q (SBeginRead));      

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

        j = 0;        
        while (j<8)
        begin
          #5 if (ready == 1)
             begin
                     BeginWrite = 1;
                 #60 BeginWrite = 0;
                 #5  inputData = inputData + 16'h0202; // 32'h04040404;
                      writeAddr = writeAddr + 1;
                      j = j + 1;
             end
        end

//        for (j=0; j<8; j=j+1)  // ------------- ADD TEST FOR READY TO WRITE
//        begin
//            #10 BeginWrite = 1;
//            #60 BeginWrite = 0;
//            #100 inputData = inputData + 16'h0202; // 32'h04040404;
//                 writeAddr = writeAddr + 1;
//        end

        for (j=0; j<1<<baw; j=j+1)
        begin
            #20 BeginRead = 1;
            #60 BeginRead = 0;
        end
                          
//        #10 while (outDataReady == 0)
//            begin
//            end
                                                                         
        
        #500 $finish;

    end


endmodule
