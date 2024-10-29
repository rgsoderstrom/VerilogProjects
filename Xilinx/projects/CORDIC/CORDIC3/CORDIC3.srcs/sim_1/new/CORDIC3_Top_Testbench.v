
/*
    CORDIC3_Top_Testbench - test full DAC1_Standalone module
*/

`timescale 1ns / 1ps

module CORDIC3_Top_Testbench;

    reg  clk;
    wire TP1;
   // wire TP2;
    reg  PingTrigger = 0;
    wire SPingTrigger;
        
    CORDIC3_Top #(.ClockFreq (50_000))
              U1 (.Clock50MHz  (clk),
                  .PingTrigger (SPingTrigger),
                  .test_point1 (TP1),
                // .test_point2 (TP2),
                  .dac_csn (),
                  .dac_sdi (),
                  .dac_ldac (),
                  .dac_sck ());    
                  
    SyncOneShot U2 (.trigger (PingTrigger), // low->high triggers, not required to be sync to clk
                    .clk (clk),
                    .clr (1'b0),           // async, active high
                    .Q   (SPingTrigger));  // pos pulse, one clock period long
                  
    
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
        #200 PingTrigger = 1;
        #60  PingTrigger = 0;
         
        #25_000_000 PingTrigger = 1;
        #60  PingTrigger = 0;
         
     //   #3000 $finish;                   
    end

endmodule
