/*
    SineTable_Testbench
*/    

`timescale 1ns / 1ps

module SineTable_Testbench;

    reg         trigger = 0;
    reg  [15:0] phase = 'hc000; // 'h0;
    wire [15:0] results;
    wire        ready;
    reg clk = 0;

    SineTable 
        U1 (.phase (phase), .sine (results), .Trigger (trigger), .Clock (clk), .Done (ready));

    //
    // test bench initializations
    //    

    initial
    begin
        $display ("module: %m");
        $monitor ("DATA: %d, ", $time, results);        
      //$monitor ("DATA: %d,  %d, ", addr, data);        
      //$monitor ("%x, %x,  %x, %d, %d, ", U1.rising, U1.index, U1.fraction, addr, data);        
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
        #23 
            for (i=0; i<100; i=i+1)
            begin
              #100 trigger = 1;
               #10 trigger = 0;
               #10 phase = phase + 'h234;
            end
                    
        #200 $finish;
    end

endmodule
