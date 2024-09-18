
//
// Controller_Testbench
//
        
/************************************************************

	Simulation system asserts hard "Clear" for first 100ns

************************************************************/	

`timescale 1ns / 1ps

module Controller_Testbench;
    localparam Width = 7;
    localparam Deadband = 20;
    
    reg             SetRequestedLevel = 0;
    reg [Width-1:0] RequestedLevel    = 0;
    reg [Width-1:0] CurrentLevel      = 0;
    reg             LevelReached      = 0; 

    wire setTLMS;
    wire clrTLMS;
    wire setCL;
    wire clrCL;
    wire setTL;
    wire clrTL;
    wire setAL;
    wire clrAL;
    
    reg clr = 0;
    reg clk = 0;
    
    PWM_Controller #(.Width (Width), .Deadband (Deadband))
             U1 (.load         (SetRequestedLevel),
                 .targetLevel  (RequestedLevel),
                 .currentLevel (CurrentLevel),
                 .ILR          (LevelReached), // 
                 
                 .setTLMS (setTLMS),
                 .clrTLMS (clrTLMS),
                 .setCL (setCL),
                 .clrCL (clrCL),
                 .setTL (setTL),
                 .clrTL (clrTL),
                 .setAL (setAL),
                 .clrAL (clrAL),
                                  
                 .Clear (clr),
                 .Clock (clk));
                 
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        //$monitor($time, "Load = %d, %d %d, %d", 
          //      pwmLoad, PWM1.Level, PWM1.level, PWM1.U1.Overflow);

        clk = 1'b0;
        clr = 1'b1;
        #120 clr = 0;  // clear is active high
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
//        // case 1
//        #402 RequestedLevel = 10;
//             CurrentLevel   = 0; 
//             SetRequestedLevel = 1'b1;
//         #10 SetRequestedLevel = 1'b0;
         
//        // case 2
//         #402 RequestedLevel = 50;
//              CurrentLevel   = 0; 
//         #10  SetRequestedLevel = 1'b1;
//         #10  SetRequestedLevel = 1'b0;
//         #100 LevelReached = 1;
//         #10  LevelReached = 0;
         
//        // case 3
//        #402  RequestedLevel = 10;
//              CurrentLevel   = 50; 
//         #10  SetRequestedLevel = 1'b1;
//         #10  SetRequestedLevel = 1'b0;         
//         #100 LevelReached = 1;
//         #10  LevelReached = 0;
         
        // case 4
        #402  RequestedLevel = 90;
              CurrentLevel   = 50; 
         #10  SetRequestedLevel = 1'b1;
         #10  SetRequestedLevel = 1'b0;         
         #100 LevelReached = 1;
         #10  LevelReached = 0;
         
       #500 $stop;  
    end


endmodule
