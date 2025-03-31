/*
    LocalOsc_TB
*/

`timescale 1ns / 1ps

module LocalOsc_TB;
    reg Step = 0;
    reg clk = 0;
    reg clr = 0;

    wire signed [31:0] I;
    wire signed [31:0] Q;
    wire Valid;
    
    LocalOscIQ #(._PhaseStep (2621))
             U1 (.Clock (clk),
                 .Clear (clr),
                 .Step  (Step),
                 .I (I),
                 .Q (Q),
                 .Valid (Valid));

    //
    // test bench initializations
    //    

    initial
    begin
        $display ("module: %m");
    //  $monitor ($time, " Sine = 0x%x", I);
        
        clk   = 1'b0;
        clr   = 1'b1; // clear is active high
        
        #40 clr = 0;
    end

    //
    // clock period
    //
    always
        #10 clk = ~clk; //toggle clk 
        
    //
    // test run
    //

    integer i;
    
    initial           
    begin
        for (i=0; i<500; i=i+1) begin                        
//      for (i=0; i<50; i=i+1) begin                        
            #9980  Step = 1; 
            #20    Step = 0;
        end                            
                            
        #2000 $finish;
    end



endmodule
