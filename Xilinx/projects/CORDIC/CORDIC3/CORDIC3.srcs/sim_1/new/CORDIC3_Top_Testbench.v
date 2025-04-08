
/*
    CORDIC3_Top_Testbench - test full DAC1_Standalone module
*/

`timescale 1ns / 1ps

module CORDIC3_Top_Testbench;

    reg  clk;
	reg  clr = 1;
	
    wire TP1;
        
    CORDIC3_Top //#(.ClockFreq (50_000))
              U1 (.Clock50MHz  (clk),
                  .test_point1 (TP1),
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
		#150 clr = 0;
		
         
   //    #300_000 $finish;                   
    end

endmodule
