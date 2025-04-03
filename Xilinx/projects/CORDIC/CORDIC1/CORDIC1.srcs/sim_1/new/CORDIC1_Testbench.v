/*
    CORDIC1_Testbench.v
*/    

/************************************************************
	Simulation system asserts hard "Clear" for first 100ns
************************************************************/	

`timescale 1ns / 1ps

module CORDIC1_Testbench;

    reg  clk = 0;
	reg  clr = 1;
                    
    CORDIC1_Top U1 (.Clock50MHz (clk), 
                    .test_point1 (),
                    .test_point2 (),
                    .dac_csn (),  // -- DAC SPI Chip Select
                    .dac_sdi (),  // -- DAC SPI MOSI
                    .dac_ldac (), // -- DAC SPI Latch enable
                    .dac_sck ()); // -- DAC SPI CLOCK

    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
       // $display ("U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input");
       // $monitor($time, ": DATA: %d, %d, %d, %d, %d", U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input); 

        clk = 1'b0;
		
		#100 clr = 0;
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
       // #50000 
           // $finish;
         
          
    end
        
endmodule
