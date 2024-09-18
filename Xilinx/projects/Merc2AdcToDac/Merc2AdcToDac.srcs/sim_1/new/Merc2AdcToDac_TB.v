
//******************************************************************************
//
//  Merc2AdcToDac_TB - 
//

`timescale 1ns / 1ps

module Merc2AdcToDac_TB;

    reg  clk = 0;
    reg  clr = 0;
    
    Merc2AdcToDac #(.ClockDivisor (40), .ADC_Delay (4))
                 U1 (.adc_miso (), // ADC controls
                     .adc_mosi (),
                     .adc_csn (),
                     .adc_sck (),               
                     .dac_csn (),  // DAC controls
                     .dac_sdi (),  
                     .dac_ldac (), 
                     .dac_sck (),       
				     .Clear (clr), // simulation only
                     .Clock50MHz (clk));

    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        //$display ("U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input");
        //$monitor($time, ": DATA: %d, %d, %d, %d, %d", U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input); 

        clk = 1'b0;
        clr = 1;
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
  //      #5000 
  //          $finish;
         
          
    end

endmodule
