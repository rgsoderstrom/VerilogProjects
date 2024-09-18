/*
    DAC_Write_Testbench
*/    

`timescale 1ns / 1ps

module DAC_Write_Testbench;

    reg clk = 0;
    reg trigger = 0;    
    reg [9:0] data = 10'h123;

    wire busy;
    
    Mercury2_DAC_Wrapper #(.SettlingTime (1e-7))
                Wrapper (.clk_50MHZ (clk),        // -- 50MHz onboard oscillator
                         .trigger (trigger),   // -- assert to write Din to DAC
                         .channel (1'b0),    // -- 0 = DAC0/A, 1 = DAC1/B
                         .Din (data), // -- data for DAC
                         .Busy (busy), // -- busy signal during conversion process
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
        #123
            trigger = 1;
        
        #20
            trigger = 0;
        
        #500    
          data = 10'h246;
         
        #500 
        //#1500
            trigger = 1;
            
        #20
            trigger = 0;
        
        #2000 
            $finish;
                   
    end
endmodule

