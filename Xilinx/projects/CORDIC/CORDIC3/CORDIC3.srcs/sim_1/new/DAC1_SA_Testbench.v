/*
    DAC1_SA_Testbench - test full DAC1_Standalone module
*/

`timescale 1ns / 1ps

module DAC1_SA_Testbench;

    reg  clk;
    wire TP1;
    wire TP2;
    
    DAC1_Standalone U1 (.Clock50MHz (clk),
                        .test_point1 (TP1),
                        .test_point2 (TP2),
                        .dac_csn (),
                        .dac_sdi (),
                        .dac_ldac (),
                        .dac_sck ());

    
    
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
//        $display ("U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input");
//        $monitor($time, ": DATA: %d, %d, %d, %d, %d", U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input); 

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
         
     //   #3000 $finish;                   
    end

endmodule
