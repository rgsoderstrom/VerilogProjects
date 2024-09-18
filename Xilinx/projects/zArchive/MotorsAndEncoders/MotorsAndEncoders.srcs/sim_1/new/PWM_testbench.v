
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	


`timescale 1ns / 1ps

module PWM_testbench;

    reg Load = 0;
    reg [3:0] Level = 4'h3;
    
    reg Clr = 0;
    reg CLK12MHZ = 0;

    wire SLoad;
    wire AtLevel;
    wire PWM;
    
    SyncOneShot
        os (.trigger (Load), .clk (CLK12MHZ), .clr (Clr), .Q (SLoad));
        
    PWM 
        pwm (.CLK12MHZ (CLK12MHZ), .Clr (Clr), .Load (SLoad), .Level (Level), .AtLevel (AtLevel), .PWM (PWM));
            
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        Clr = 1'b1;
        #50 Clr = 0;  // clear is active high
    end
    
    //
    // clock period
    //
    always
        #5 CLK12MHZ = ~CLK12MHZ;  
        
    initial
    begin
        #80 Load = 1;    
        #60 Load = 0;
        
    end
            
endmodule
