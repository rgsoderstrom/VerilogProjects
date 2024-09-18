
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	


`timescale 1ns / 1ps

module Loopback_Testbench;

  localparam DataWidth = 8; 
  
  reg  [DataWidth-1:0] SentWord;
  reg  SentBit;
  reg  wordDone = 1'b0;
  
  reg  [DataWidth-1:0] inputShiftRegister = 0; // accumulate bits received from Loopback
  reg  [DataWidth-1:0] ReceivedWord = 0;       // completed word copied to here
  
  reg clk;
  reg clrBar;

  reg  writeCycle = 0;
  reg  readCycle = 0;
  wire receivedBit;
  wire lastBit;
  wire firstBit;
  
  reg [DataWidth-1:0] testPatterns [0:3];
        
  Loopback U1 (.InputDataBit (SentBit), // 
               .InputShiftClock (writeCycle),
               .InputDone (wordDone),
               
               .OutputDataBit (receivedBit),
               .OutputShiftClock (readCycle),
               .LastBit (lastBit),
               .FirstBit (firstBit),
                 
               .Clk (clk),
               .ClearBar (clrBar)); // active low
            
    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");

        $monitor ($time, " ReadAddr = %d, WriteAddr = %d, NumberStored = %d, full = %d, fifo_empty = %d, Received = %x",
                    U1.fifo.ReadAddr, U1.fifo.WriteAddr, U1.fifo.NumberStored, U1.fifo.Full, U1.fifo.Empty, ReceivedWord);
        
     //   $monitor ($time, " Sent = %x, Received = %x",
      //             SentWord, ReceivedWord);
        
        clk    = 1'b0;
        clrBar = 1'b0; // clear-bar is active low

        writeCycle = 0;
            
        #20 clrBar = 1'b1; 
    end
    
    //
    // clock period
    //
    always
        #5 clk = ~clk; //toggle clk 
        

    //
    // test run
    //
    
//    initial
//        #15000 $finish;

    //
    // read loop
    //    
    
    integer i, j, k;
    
    initial
    begin

        #1000
        while (1)
        begin            
            #12
            if (firstBit == 1'b1)
            begin  
                inputShiftRegister = 8'h0;
                        
                for (i=0; i<DataWidth; i=i+1)
                begin
                    #10 inputShiftRegister [0] <= receivedBit;

                    #10 if (lastBit == 1'b0)
                        begin
                          inputShiftRegister [DataWidth-1:1] <= inputShiftRegister [DataWidth-2:0];
                          inputShiftRegister [0] <= 1'b0;
                        end

                        else
                          ReceivedWord <= inputShiftRegister; 
                       
                    #100 readCycle <= 1'b1;
                    #100 readCycle <= 1'b0;
                end
            end
        end
    end
       
    //
    // write loop
    //
    initial
    begin
        testPatterns [0] = 8'hab;
        testPatterns [1] = 8'h34;
        testPatterns [2] = 8'h98;
        testPatterns [3] = 8'h54;

        #100
        
        for (j=0; j<4; j = j+1)
        begin
            #100 SentWord = testPatterns [j];
            
            for (k=0; k<DataWidth; k=k+1)
            begin
                    SentBit = SentWord [DataWidth - 1 - k];
                #100 writeCycle <= 1'b1;
                #100 writeCycle <= 1'b0;
            end
       
            #100 wordDone = 1'b1;
            #100 wordDone = 1'b0;
        end
    end

endmodule


