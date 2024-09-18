/*
    PhaseCounter_Testbench
*/    

`timescale 1ns / 1ps

module PhaseCounter_Testbench;

    localparam Width = 5;
  
    reg clk;
    reg clr;
    reg enable = 1;
    reg  [Width-1:0] freq = 'h5;
    wire [Width-1:0] phase;
    wire             zero;
    
    PhaseCounter #(.Width (Width))
               U1 (.Clock  (clk),
                   .Clear  (clr),  // active high
                   .Enable (enable),
                   .Step   (freq), // frequency
                   .Phase  (phase),
                   .Zero   (zero));

    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");
      //$monitor ($time, " receivedByte = 0x%x", receivedByte);
        
        clk   = 1'b0;
        clr   = 1'b1; // clear is active high
        
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
                
        #400 $finish;

    end
        
endmodule
