/*
    DAC1_Ctrl_Testbench.v - DAC1 data generator controller test
        - expanded to test all DAC 1 data generator
*/    

/************************************************************
	Simulation system asserts hard "Clear" for first 100ns
************************************************************/	

`timescale 1ns / 1ps

module DAC1_Ctrl_Testbench;

    reg  clk;
    reg  clr;
    reg  Blanking = 0;
    reg  StartRamp = 0;
        
    wire DacBusy;
    wire CountEnable;
    wire RampDone;

    wire dac_trigger;
    wire LoadBlanking;
    wire LoadInitial;
    
    wire [9:0] RampCount;
    
    DAC1_Controller U1 (.Clock (clk),
                        .BeginBlanking (Blanking),
                        .StartRamp     (StartRamp),
                        .dac_busy      (DacBusy),
                        .CountEnable   (CountEnable),
                        .RampDone      (RampDone),
                        .dac_trigger   (dac_trigger),
                        .LoadBlanking  (LoadBlanking),
                        .LoadInitial   (LoadInitial));

    ClockDivider #(.Divisor (32))
        U2 (.FastClock (clk),  
            .Clear (clr),  
            .SlowClock (), 
		    .Pulse (CountEnable));

    RampCounter #(.BlankingLevel (10),
                  .RampInitial (50),
                  .RampFinal (75)) 
              U3 (.Clock (clk),
                  .Clear (clr),
                  .LoadBlanking (LoadBlanking),
                  .LoadInitial  (LoadInitial),
                  .Enable (CountEnable),
                  .RampDone (RampDone),
                  .Ramp (RampCount));
                     
    Mercury2_DAC_Wrapper_Sim #(.SettlingTime (1e-7))
                     U4 (.clk_50MHZ (clk),        // -- 50MHz onboard oscillator
                         .trigger (dac_trigger),   // -- assert to write Din to DAC
                         .channel (1'b0),    // -- 0 = DAC0/A, 1 = DAC1/B
                         .Din (RampCount), // -- data for DAC
                         .Busy (DacBusy), // -- busy signal during conversion process
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
          clr = 1'b1;
      #50 clr = 1'b0;
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

        #115  Blanking = 1'b1;
        #20   Blanking = 1'b0;
         

        #200 StartRamp = 1;
        #20  StartRamp = 0;
         
        #20000 Blanking = 1'b1;
        #20   Blanking = 1'b0;
         

        #200 StartRamp = 1;
        #20  StartRamp = 0;
         
         
        #30000 $finish;                   
    end

endmodule
