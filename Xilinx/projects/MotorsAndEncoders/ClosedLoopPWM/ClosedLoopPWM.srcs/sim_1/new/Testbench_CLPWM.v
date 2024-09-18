/*
    Testbench_CLPWM
*/    

/*
	Simulation system asserts hard "Clear" for first 100ns
*/	

`timescale 1ns / 1ps

module Testbench_CLPWM;

    localparam N = 7;
    
    reg  clk;
    reg  clr;
    reg [N-1:0] reqSpeed = 0;
    reg load = 0;
    reg encCountUp = 0, encCountDown = 0;
    wire PWM_out;
    wire stopped;
    
    ClosedLoopPWM #(.Width (N), 
                    .Deadband (1), // 1 is minimum 
                    .InputClockFreq (4 * 160), 
                    .PulseGenInternalFreq (160))
                U1 (.RequestedSpeed (reqSpeed), .Load (load),
                    .EncoderX (encCountUp), .EncoderY (encCountDown),
                    .PWM (PWM_out), .Stopped (stopped), 
                    .Clock (clk), .Clear (clr));

    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");
        clk = 1'b0;
        clr = 1'b1;
        
        #50 clr = 0;  // clear is active high
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
        #115 
            reqSpeed = 'h10;
            load = 1;
        #10 load = 0;
        #10 encCountUp = 1;
    
        #4000 reqSpeed = 0;
              load = 1;
          #10 load = 0;
              encCountUp = 0;
              encCountDown = 1;
              
        #10000 $finish;
    end
    
endmodule
