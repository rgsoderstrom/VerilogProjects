/*
    RampCounter_Testbench.v
*/

`timescale 1ns / 1ps

module RampCounter_Testbench;

    reg  clk;
    reg  clr = 0;
    reg  loadBlanking = 0;
    reg  startRamp = 0;
    wire [9:0] ramp;
    wire rampDone;
    wire countEnable;
    
    ClockDivider #(.Divisor (16)) // ClockDivisor  = 3006) // 30mS rise time
           ClkDiv (.FastClock (clk),  
                   .Clear     (clr),
                   .SlowClock (), 
				   .Pulse     (countEnable));                   
                        
    RampCounter #(.BlankingLevel (20),
                  .RampInitial   (52),
                  .RampFinal     (255))
        RampCntr (.Clock (clk),
                  .Clear (clr),
                  .LoadBlanking (loadBlanking),
                  .LoadInitial  (startRamp),
                  .RampDone     (rampDone),
                  .Enable       (countEnable),
                  .Ramp (ramp));
                        
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
//        $display ("U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input");
//        $monitor($time, ": DATA: %d, %d, %d, %d, %d", U1.cordicOut, U1.windowOut, U1.multiplierOut, U1.subtracterOut, U1.dac_input); 

        clk = 1'b0;
        clr = 1;
    #50 clr = 0;
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
            loadBlanking = 1;
        #20
            loadBlanking = 0;
                
        #600
            startRamp = 1;
        #20
            startRamp = 0; 
                       
        #100000 
            loadBlanking = 1;
        #20
            loadBlanking = 0;
                
        #1600
            startRamp = 1;
        #20
            startRamp = 0; 
                   
    end


endmodule
