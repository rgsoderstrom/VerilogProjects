/*
    SignedPWM 
        - signed pulse width modulator
        - input 2's complement
*/

/*
    Modified to use closed-loop magnitude PWM
*/
     
`timescale 1ns / 1ps

module SignedPWM #(parameter Width = 8, 
                             InputClockFreq = 12_500_000,
                             Deadband = 20)
                  (input [Width-1:0] SignedLevel,  // twos complement
                   input Load,
                   input Clk,
                   input Clr,
                   output PulseTrain,
                   output MotorDirection,
                   output Stopped,
                   input  EncoderX,
                   input  EncoderY);
                  
    wire [Width-2:0] magPwmLevel;  // into mag PWM
    wire [Width-2:0] magLevel;     // out of 2's compl to signed mag
    wire loadMag;
    wire loadDir;
    wire muxSel;
    wire nextDir;
    wire magPwmAtZero;
    
    assign Stopped = magPwmAtZero;
    
SPWMController U1 (.Load (Load),
                   .NextDir (nextDir),
                   .Dir (MotorDirection),
                   .MagAtZero (magPwmAtZero),
                   .Clk (Clk),   // 12 MHz
                   .Clear (Clr), //  active high
                   .MuxSel  (muxSel),
                   .LoadMag (loadMag),
                   .LoadDir (loadDir));

TwosCompToSignMag #(.Width (Width))
            U2 (.TwosCompIn (SignedLevel),
                .Load (Load),
                .Clear (Clr),
                .Clk (Clk),
                .Sign (nextDir),
                .Magnitude (magLevel));
              
MagnitudeMux #(.Width (Width-1))
             U3 (.in (magLevel),
                 .sel (muxSel),
                 .out (magPwmLevel));
                 
DirectionFF U4 (.NextDir (nextDir),
                .Load (loadDir),
                .Clock (Clk),
                .Clear (Clr),
                .Dir (MotorDirection));
              
reg Zero = 1'b0;

ClosedLoopPWM #(.Width (Width - 1), 
                .Deadband (Deadband), // 1 is minimum
                .InputClockFreq (InputClockFreq))
            U6 (.RequestedSpeed (magPwmLevel),
                .Load (loadMag),
                .EncoderX (EncoderX),
                .EncoderY (EncoderY),
                .PWM (PulseTrain),
                .Stopped (magPwmAtZero), 
                .Clock (Clk),
                .Clear (Clr));
        
//PWM #(.Width (Width-1), .FreeCounter_Width (FreeCounter_Width), .Deadband (Deadband))
//    U6 (.Clk12MHz (Clk),
//        .Clr (Clr),
//        .PWMLoad (loadMag),
//        .RequestedLevel (magPwmLevel),
//        .AtReqLevel (magAtCmndLevel), // PWM is at requested level
//        .PWM (PulseTrain));
        
     
endmodule
