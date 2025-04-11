`timescale 1ns / 1ps

module CORDIC4_TestBench;

    reg  clk;
                        
    CORDIC4_Top U1 (.Clock50MHz (clk));

    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        //$display ("U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input");
        //$monitor($time, ": DATA: %d, %d, %d, %d, %d", U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input); 

        clk = 1'b0;
    end
    
    //
    // clock period
    //
    always
        #10 clk = ~clk; //toggle clk 
        
    //
    // test run
    //
    initial
    begin
  //      #5000 
  //          $finish;
         
          
    end
        
endmodule
