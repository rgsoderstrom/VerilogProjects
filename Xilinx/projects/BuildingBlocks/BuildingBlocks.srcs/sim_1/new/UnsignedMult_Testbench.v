/*
    UnsignedMult_Testbench
*/

`timescale 1ns / 1ps

module UnsignedMult_Testbench;

    localparam I1W = 8;
    localparam I2W = 8; //4;
    localparam OW  = 8;
    
    reg Clock = 0;
    reg Clear = 1;
    reg EnableCount1 = 0;
    reg EnableCount2 = 1;
    
    wire [I1W-1:0] count1;
    wire [I2W-1:0] count2;
    wire [OW-1:0] product;
    
    UnsignedMult #(.WidthA (I1W), .WidthB (I2W), .WidthOut (OW))
        U1 (.out (product), .a (count1), .b (count2));    
     // U1 (.out (product), .a (count1), .b (count2), .Clock (Clock), .Enable (1'b1));    
            
    CounterUEC #(.Width (I1W))
             U2 (.Enable (EnableCount1),
				 .Clr (Clear),   // sync, active high
                 .Clk (Clock),   // pos edge triggered
                 .Output (count1));

    CounterUEC #(.Width (I2W))
             U3 (.Enable (EnableCount2),
				 .Clr (Clear),   // sync, active high
                 .Clk (Clock),   // pos edge triggered
                 .Output (count2));


    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        $monitor ($time, "Clock: %d, %d = %d * %d", Clock, product, count1, count2);            
        
        Clock   = 1'b0;
        Clear   = 1'b1; // clear is active high

        #20 Clear = 0; 
    end


    //
    // clock period
    //
    always
        #5 Clock <= ~Clock; //toggle clk 
        
        
    //
    // test run
    //
    
    initial
    begin    
        #42 EnableCount1 = 1;
        #42 EnableCount2 = 0;
        
        #100                                                                    
        $finish;
    end
    


    
endmodule
