
/*
	Testbench - for simple building blocks
*/	

/*
	Simulation system asserts hard "Clear" for first 100ns
*/	

`timescale 1ns / 1ps

module Testbench;

    reg clk = 0;
    reg clr = 0;

    localparam Width = 10;    
    localparam One = (1 << (Width - 1));
    
    localparam RW = Width;
    localparam WW = Width+1;
    
    
    
    
    reg [WW-1:0] WriteAddr =  100;     
    reg [RW-1:0] ReadAddr = 0;     
    wire [15:0] Remaining;   
                        
    Trial #(.Width (Width))
        U1 (.WriteAddr (WriteAddr),
            .ReadAddr  (ReadAddr),
            .Remaining (Remaining));                    
    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");
        //$monitor ($time, " EventCounter.Count = %d, EventCounter.Zero = %d", U1.Count, U1.Zero);
        
        clk   = 1'b0;
        clr   = 1'b1; // clear is active high

        #20 clr = 0; 
    end

    //
    // clock period
    //
    always
        #10 clk <= ~clk; //toggle clk 
        
    //
    // test run
    //

    integer i;
        
    initial
    begin
        #120 
            for (i=0; i<150; i=i+1)
            begin    
              #20   ReadAddr = ReadAddr + 'd1;
            end
            
        #200 $finish;
    end

endmodule
