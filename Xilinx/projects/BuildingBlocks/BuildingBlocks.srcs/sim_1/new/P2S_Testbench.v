
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	


`timescale 1ns / 1ps

module P2S_Testbench;

    localparam DataWidth = 8; 

    reg [DataWidth-1:0] sentWord;      // word loaded in to P2S shift register
    reg [DataWidth-1:0] receivedBits;  // word reconstructed from serial bit stream
    reg [DataWidth-1:0] receivedByte;  // entire byte copied to here
  
    reg clk;
    reg clr;

    wire  outputDataBit;
    reg   outputShiftClock, loadP2S;
    wire  SOutputShiftClock, SLoadP2S;
    
    wire P2S_empty;
    wire firstBit;
    wire lastBit;
    
    integer i = 0;
    reg [7:0] bitCounter = 0;
        
    SerializerPtoS #(.Width (DataWidth))
                u1  (.Input (sentWord),
                     .Clr (clr),   // sync, active high
                     .Clk (clk),   // pos edge triggered
                     .Load (SLoadP2S),
                     .Shift (SOutputShiftClock),
                     .Empty (P2S_empty),     // ready to load,
					 .FirstBit (firstBit),  // true when OutputBit is first bit of Input
				     .LastBit (lastBit),    //  "     "      "     "  last   "   "   "						
                     .OutputBit (outputDataBit));
                     
    SyncOneShot 
            u2 (.trigger (loadP2S), .clk (clk), .clr (clr), .Q (SLoadP2S)),
            u3 (.trigger (outputShiftClock), .clk (clk), .clr (clr), .Q (SOutputShiftClock));

    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");
        $monitor ($time, " receivedByte = 0x%x", receivedByte);
        
        clk   = 1'b0;
        clr   = 1'b1; // clear is active low

        receivedBits = 0;
        receivedByte = 0;
        outputShiftClock = 0;
        loadP2S = 0;
            
        #20 clr = 0; 
    end

    //
    // clock period
    //
    always
        #5 clk = ~clk; //toggle clk 
        
    //
    // test run
    //

    initial
    begin
        //-------------------------------------------------------------
    
        #112 sentWord = 8'h81;
        #10  loadP2S = 1;
        #50  loadP2S = 0;

        bitCounter = 0;

        // shift until lastBit set
        
        while (lastBit == 0)
        begin
            receivedBits [DataWidth-1-bitCounter] <= outputDataBit;
            bitCounter <= bitCounter + 1;  
            #10 outputShiftClock <= 1'b1;
            #50 outputShiftClock <= 1'b0;
        end
        
        receivedBits [DataWidth-1-bitCounter] <= outputDataBit;
        bitCounter <= bitCounter + 1;  
        #10 outputShiftClock <= 1'b1;
        #50 outputShiftClock <= 1'b0;

        receivedByte = receivedBits;
        
    //-------------------------------------------------------------

    // Hard-code 8 bits (shift 8 times)
        
        #32 sentWord = 8'haa;
            receivedBits = 0;
        #10 loadP2S = 1;
        #50 loadP2S = 0;

        for (i=0; i<8; i=i+1)
        begin
            receivedBits [7 - i] <= outputDataBit;
            #10 outputShiftClock <= 1'b1;
            #50 outputShiftClock <= 1'b0;
        end
          
        receivedByte = receivedBits;
        
        #200 $finish;
    end
    
endmodule


