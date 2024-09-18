
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	


`timescale 1ns / 1ps

module Loopback_testbench;

    reg  clk;
    reg  clr;
    reg  dataIn;
    
    reg  shiftIn;
    reg  loadHolding;
    
    reg  shiftOut;
    reg  loadOut;
    wire dataOut;
    
    reg [15:0] inputWord = 16'H1234;
    
    Loopback
        loopback (.DataIn (dataIn), .DataOut (dataOut), .ShiftIn (shiftIn), .ShiftOut (shiftOut),
                  .LoadHR (loadHolding), .LoadOut (loadOut), .Clr (clr), .CLK12MHZ (clk));    
    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");

        shiftIn     = 1'b0;
        loadHolding = 1'b0;
        shiftOut    = 1'b0;
        loadOut     = 1'b0;
            
        clk = 1'b0;
        clr = 1'b0;
        
        #50 clr = 1;  // clear is active low
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
        #112
        
        for (i=0; i<16; i=i+1)
        begin
            dataIn = inputWord [15 - i];
            #50 shiftIn = 1'b1;
            #50 shiftIn = 1'b0;                
        end
        
        loadHolding = 1'b1; #50 loadHolding = 1'b0;
        loadOut = 1'b1; #50 loadOut = 1'b0;
        
        for (i=0; i<16; i=i+1)
        begin
            #50 shiftOut = 1'b1;
            #50 shiftOut = 1'b0;                
        end
        
        #200 $finish;
    end


endmodule






