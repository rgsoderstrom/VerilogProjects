
/*
    SignedPWM_Testbench
*/
    
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	

`timescale 1ns / 1ps

module SignedPWM_Testbench;
    
    localparam W = 8;
    localparam db = 20; // minimum is 1
    
    reg load;
    reg [W-1:0] signedLevel;

    wire Pulses;
    wire Direction;
	
    reg clk;
    reg clear;
    
    reg encoderX = 0;
    reg encoderY = 0;
	
    SignedPWM #(.Width (W), 
                .InputClockFreq (160 * 3),
                .Deadband (db))
            U1 (.SignedLevel (signedLevel),  // twos complement
                .Load (load),
                .Clk (clk),
                .Clr (clear),
                .PulseTrain (Pulses),
                .MotorDirection (Direction),
                .EncoderX (encoderX),
                .EncoderY (encoderY));
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        
        //$monitor ($time, " level = %d, load = %d, AtLevel = %d, PWM = %d, Dir = %d, loadMag = %d, muxSel = %d, PWM Level = %d, %d, %d", 
          //          signedLevel, load, AtCmndLevel, Pulses, Direction, U1.loadMag, U1.muxSel, U1.U6.U5.Load, U1.U6.U5.LowResLevel, U1.U6.U5.HighResLevel);
        
        load = 1'b0;
        clk = 1'b0;
        clear = 1'b1;
        #20 clear = 0;  // clear is active high
    end
    
    //
    // clock period
    //
    always
        #5 clk = ~clk; //toggle clk 
        

    //
    // test run
    //
    initial
    begin
  
    #234
    signedLevel = 8'd20;  
    #10 load = 1;
    #10 load = 0;
        encoderX = 1;
        
    #8000
    signedLevel = 0; // -8'd20; 
    #10 load = 1;
    #10 load = 0;
        encoderX = 0;
        encoderY = 1;
    
    
    #10000 $finish;
               
    end

endmodule
