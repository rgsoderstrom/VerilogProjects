
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	



/*
    FIFO_Testbench2 - test interleaved writes & reads
*/

`timescale 1ns / 1ps

module FIFO1_Testbench2;

    localparam DataWidth = 8; 

    reg  [DataWidth-1:0] testPatterns [0:31];
    wire [DataWidth-1:0] readData;
    reg  clock = 0;
    reg  clear = 0;
    wire empty, full;
    reg  writeCycle = 0;
    reg  readCycle = 0;
    
    integer  select = 0;
    integer i;
    
    FIFO1 #(.DataWidth (DataWidth),
            .AddrWidth (4))
        U1 (.Clk (clock),
            .Clr (clear),
            .Empty (empty),
            .Full (full),
            .WriteData (testPatterns [select]),
            .ReadData (readData),
            .WriteCycle (writeCycle),
            .ReadCycle (readCycle));  
  
    //
    // test bench initializations
    //    
    
    initial
    begin
        for (i=0; i<32; i=i+1)
            testPatterns [i] = 8'haa + 2 * i;
    end

    initial
    begin
        $display ("module: %m");

//        $monitor ($time, " ReadAddr = %d, WriteAddr = %d, NumberStored = %d, full = %d, fifo_empty = %d, Received = %x",
//                    U1.fifo.ReadAddr, U1.fifo.WriteAddr, U1.fifo.NumberStored, U1.fifo.Full, U1.fifo.Empty, ReceivedWord);
        
        
        clock = 1'b0;
        clear = 1'b1; // active high

        #20 clear = 1'b0; 
    end
    
    //
    // clock period
    //
    always
        #5 clock = ~clock; //toggle clk 
        

    //
    // test run
    //
    
    initial
    begin
        #62
        for (select=0; select<8; select=select+1)
        begin
            #100 writeCycle = 1;
            #10  writeCycle = 0;
        end
        
        for (i=0; i<4; i=i+1)
        begin
            #100 readCycle = 1;
            #10  readCycle = 0;
        end

        for (select=8; select<12; select=select+1)
        begin
            #100 writeCycle = 1;
            #10  writeCycle = 0;
        end
        
        for (i=0; i<8; i=i+1)
        begin
            #100 readCycle = 1;
            #10  readCycle = 0;
        end

    
    end
       

endmodule


