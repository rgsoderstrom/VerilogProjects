
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	


`timescale 1ns / 1ps

module S2P_Testbench;

  localparam DataWidth = 8; 
  
  reg  [DataWidth-1:0] SentWord;
  
  reg clk;
  reg clr;

  wire [0:0] inputDataBit;
  reg inputShiftClock;
  reg inputDone;
  
  assign inputDataBit = SentWord [DataWidth-1];
  
  wire ready;
  wire [DataWidth-1:0] dataOut;
    
    SerializerStoP #(.Width (DataWidth)) 
                 U1 (.DataIn (inputDataBit),
                     .Shift (inputShiftClock),
                     .Done (inputDone),   // data source sets this true when entire word has been shifted in
                     .Clr (clr),  // sync, active high
                     .Clk (clk),  // pos edge trigger
                     .Ready (ready), // copy of "Done" input
                     .DataOut (dataOut));
    
    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");
        $monitor ($time, " InputBit = %d, InputShiftClock = %d", inputDataBit, inputShiftClock);
        
        clk   = 1'b0;
        clr   = 1'b1; // clear is active high

        inputShiftClock = 0;
        inputDone = 0;
            
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
    integer i;
    
    initial
    begin
        #32
        SentWord = 8'hc3;

        for (i=0; i<DataWidth; i=i+1)
          begin
            #20 inputShiftClock <= 1'b1;
            #10 inputShiftClock <= 1'b0;
            SentWord [DataWidth-1:1] <= SentWord [DataWidth-2:0];  
            SentWord [0] <= 1'b0;                          
          end
        
        #20 inputDone = 1'b1;
        #20 inputDone = 1'b0;
        
        
        #200 $finish;
    end

endmodule
