
/*
    PWM_Testbench.v
*/

        
/************************************************************

	Simulation system asserts hard "Clear" for first 100ns

************************************************************/	


`timescale 1ns / 1ps

module PWM_TestBench;

    localparam Width = 4;
    localparam FCWidth = Width + 2; 
    
    reg [Width-1:0] TargetLevel;
    wire PWMOut;
    wire AtLevel;
    reg  clk;
    reg  clr;
    reg  pwmLoad;
                
    //localparam dbCase = 0;
    //localparam dbCase = 1;
    localparam dbCase = 4;
                    
    PWM #(.Width (Width), .FreeCounter_Width (FCWidth), .Deadband (dbCase)) 
     PWM1 (.Clk12MHz (clk), 
           .Clr (clr), 
           .PWMLoad (pwmLoad), 
           .RequestedLevel (TargetLevel), 
           .PWM (PWMOut), 
           .AtReqLevel (AtLevel));
        
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        //$monitor($time, "Load = %d, %d %d, %d", 
        //        pwmLoad, PWM1.Level, PWM1.level, PWM1.U1.Overflow);

        pwmLoad = 1'b0;    
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
        #400 TargetLevel = 4'b1010;  
             pwmLoad = 1'b1;
         #10 pwmLoad = 1'b0;
             TargetLevel = 4'b0000;  // like in SPWM
         
         #7000 TargetLevel = 4'b0101; 
               pwmLoad = 1'b1;
         #10   pwmLoad = 1'b0;
               TargetLevel = 4'b0000;  // like in SPWM

         
//         #5000 TargetLevel = 4'b0011;
//               pwmLoad = 1'b1;
//         #10   pwmLoad = 1'b0;
         
          
    end
        
endmodule
