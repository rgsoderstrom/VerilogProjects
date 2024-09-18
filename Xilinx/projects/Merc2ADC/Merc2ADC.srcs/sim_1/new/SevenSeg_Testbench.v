/*
    SevenSeg_Testbench.v
*/    

/************************************************************
	Simulation system asserts hard "Clear" for first 100ns
************************************************************/	

`timescale 1ns / 1ps

module SevenSeg_Testbench;

    reg  FastClock;
    wire SlowPulse;
    reg  clr = 1;
                                
    wire segmentA;
    wire segmentB;
    wire segmentC;
    wire segmentD;
    wire segmentE;
    wire segmentF;
    wire segmentG;
    wire dot;
    wire select3; // select digit 3
    wire select2;
    wire select1;
    wire select0;
    reg  [15:0] value = 16'h1234;
    reg  [3:0]  dots = 4'h0;
    reg  loadValue = 0;
    reg [3:0] brightness = 5;
    
    SevenSegmentDriver U1 (.segmentA (segmentA),
                           .segmentB (segmentB),
                           .segmentC (segmentC),
                           .segmentD (segmentD),
                           .segmentE (segmentE),
                           .segmentF (segmentF),
                           .segmentG (segmentG),
                           .dot (dot),
                           .select3 (select3), // select digit 3
                           .select2 (select2),
                           .select1 (select1),
                           .select0 (select0),
                           .value (value),
                           .dots (dots),
                           .loadValue (loadValue),
                           .brightness (brightness),
                           .Enable (SlowPulse),
                           .Clock (FastClock));

    ClockDivider U2 (.FastClock (FastClock), .Clear (clr), .SlowClock (), .Pulse (SlowPulse));
    
    
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
//        $display ("U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input");
//        $monitor($time, ": DATA: %d, %d, %d, %d, %d", U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input); 

          FastClock = 1'b0;
    end
    
    //
    // clock period
    //
    always
        #5 FastClock = ~FastClock; 
        
    //
    // test run
    //
    initial
    begin
        #110 clr = 0;
        #35  loadValue = 1'b1;
        #10  loadValue = 1'b0;
         
        #2500 $finish;                   
    end
        
endmodule
