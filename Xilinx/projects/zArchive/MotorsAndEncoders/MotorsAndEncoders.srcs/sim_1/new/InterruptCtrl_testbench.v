
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	


`timescale 1ns / 1ps

module InterruptCtrl_testbench;

    reg int1;
    reg int2;
    reg int3;
    reg int4;
    reg clearInt;
    
    reg Clr = 0;       // active high, connected to button 0
    reg CLK12MHZ = 0;

    wire Interrupt;

    InterruptCtrl 
        IC1 (.in1 (int1), .in2 (int2), .in3 (int3), .in4 (int4),
             .clearInterrupt (clearInt), .Clr (Clr), .Clk (CLK12MHZ), .interrupt (Interrupt));

    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        Clr = 1'b1;
        #50 Clr = 0;  // clear is active high
    end
    
    //
    // clock period
    //
    always
        #5 CLK12MHZ = ~CLK12MHZ;  
        
    initial
    begin
        int1 = 0;
        int2 = 0;
        int3 = 0;
        int4 = 0;
        clearInt = 0;
    
        #92 int1 = 1;
        #40 int1 = 0;
    
        #40 clearInt = 1;
        #40 clearInt = 0;
    
        #40 int3 = 1;
        #40 int3 = 0;
    
        #40 clearInt = 1;
        #40 clearInt = 0;
    end


endmodule
