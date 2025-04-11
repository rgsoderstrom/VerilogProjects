/*
    FixedPoint_TB.v
*/

`timescale 1ns / 1ps

module FixedPoint_TB;

    reg clk = 0;
    reg clr = 0;
    
    localparam W = 32;

    reg signed [W-1:0] a = 0;
    reg signed [W-1:0] b = 0;
    
    reg Enable = 0;
    wire signed [W-1:0] Sum;
    wire signed [W-1:0] Diff;
    wire signed [W-1:0] Prod;
    
    FixedPoint #(.TotalWidth (W),
                 .FractBits  (24))
             U1 (.Clock  (clk),
                 .Enable (Enable),
                 .Clear  (clr),

                 .a (a),
                 .b (b),
                    
                 .Sum  (Sum),
                 .Diff (Diff),
                 .Prod (Prod));


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
    initial
    begin
//        #123 a = 32'h03000000; // 32'hfe0700b8;
//             b = 32'h07000000; // 32'h2d231b3e;        

        #123 a = 32'h180f8939;
             b = 32'hfe21e257;    
             
        #100 Enable = 1'b1;   

                        
        #200 $finish;

    end
    
endmodule
