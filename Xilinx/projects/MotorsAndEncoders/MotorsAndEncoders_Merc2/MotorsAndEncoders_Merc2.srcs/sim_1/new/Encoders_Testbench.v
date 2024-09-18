
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	

/*
    Encoders_Testbench.v
*/    

`timescale 1ns / 1ps

module Encoders_Testbench;

    reg Clear = 0;    
    reg Clock = 0;
    wire pulse40Hz;

    wire outputDataBit, firstBit; 
    reg  outputShiftClock = 0;
    wire SOutpuShiftClock;
    
    reg  startColl = 0, stopColl = 0, buildMsg = 0, sendMsg = 0;
    wire SStartColl, SStopColl, SBuildMsg, SSendMsg;
    
    reg [7:0] receivedBits = 0;  // word reconstructed from serial bit stream
    reg [7:0] receivedByte = 0;  // entire byte copied to here
        
    Encoders U1 (//.FifoDataOut    (dataOut),   // TEMP
                 //.outputFifoRead (SFifoRead), // TEMP
                 
                 .OutputBit (outputDataBit),
                 .LastBit (),
                 .FirstBit (firstBit),
                 .OutputShiftClock (SOutputShiftClock),

                 .StartCollection        (SStartColl),
                 .StopCollection         (SStopColl),
                 .BuildCollectionMessage (SBuildMsg),
                 .SendCollectionMessage  (SSendMsg),                 
                 .SampleClock            (pulse40Hz),
                 
                 .Clear (Clear),
                 .Clock (Clock));
                 
    ClockDivider #(.Divisor (8))
 			  U2  (.FastClock (Clock), .Clear (Clear), .SlowClock (), .Pulse (pulse40Hz));
             
    SyncOneShot 
             U3 (.trigger (startColl), .clk (Clock), .clr (Clear), .Q (SStartColl)),
             U4 (.trigger (stopColl),  .clk (Clock), .clr (Clear), .Q (SStopColl)),
             U5 (.trigger (buildMsg),  .clk (Clock), .clr (Clear), .Q (SBuildMsg)),
             U6 (.trigger (sendMsg),   .clk (Clock), .clr (Clear), .Q (SSendMsg)),
             U7 (.trigger (outputShiftClock),  .clk (Clock), .clr (Clear), .Q (SOutputShiftClock));
    

    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        $monitor ($time, " msg byte %d, 0x%h", receivedByte, receivedByte);
            
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

    integer i, j, k;
    
    initial
    begin
        
        #112   // wait for "clear" to go away
        
    //******************************************************************
    
            startColl = 1;
        #60 startColl = 0;
                         
        #800 stopColl = 1;
        #60  stopColl = 0;

        for (j=0; j<2; j=j+1) // each message
        begin
            #200 buildMsg = 1;
            #60  buildMsg = 0;
                          
            #1000 sendMsg = 1;
            #100  sendMsg = 0;

            for (k=0; k<12; k=k+1) // each byte of a message
            begin
                for (i=0; i<8; i=i+1) // each bit in a byte
                begin
                    receivedBits [7 - i] <= outputDataBit;
                    #10 outputShiftClock <= 1'b1;
                    #50 outputShiftClock <= 1'b0;
                end
          
                receivedByte = receivedBits;
            end                                      
        end
        
                                                                            
        #1000 $finish;

    end



endmodule
