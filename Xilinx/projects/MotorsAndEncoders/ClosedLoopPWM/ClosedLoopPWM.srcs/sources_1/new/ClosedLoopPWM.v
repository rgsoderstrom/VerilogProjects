/*
    ClosedLoopPWM.v
*/    

`timescale 1ns / 1ps

module ClosedLoopPWM #(parameter Width = 7, 
                                 Deadband = 1, // 1 is minimum
                                 InputClockFreq = 12_500_000)
                      (input [Width-1:0] RequestedSpeed,
                       input             Load,
                       input             EncoderX,
                       input             EncoderY,
                       output reg        PWM,
                       output            Stopped, 
                       input             Clock,
                       input             Clear);
        
wire enableUD, latchCount;
reg  CountUp, CountDown;
wire [Width-1:0] freeCount;
wire [Width-1:0] currentLevel;
wire [Width-1:0] tgtCounts;
wire [Width:0]   sEncCounts; // signed 
wire [Width-1:0] uEncCounts; // unsigned magnitude 

wire CL_CLR;
wire fastUD;

CLPWM_PulseGen #(.ClockFreq (InputClockFreq))
             U1 (.Clock (Clock), .Clear (Clear), .LatchCount (latchCount), .EnableUD (enableUD), .FastUD (fastUD));

FreeCounter #(.CounterWidth (Width), .OutputWidth (Width)) 
          U2 (.Clk (Clock), .Clr (Clear), .Overflow (), .LSBs (freeCount));
 
 // replaces Comparator U3
 always @(*)
 begin
    PWM = (freeCount < currentLevel);
 end
    
assign CL_CLR = Clear | ((tgtCounts == 0) & (uEncCounts == 0));

assign fastUD = (tgtCounts - uEncCounts > 7'd5) | (tgtCounts - uEncCounts < -7'd5); 
    
CounterUDD #(.Width (Width), .Deadband (Deadband)) 
         U4 (.Clk (Clock), .Clr (CL_CLR), .Enable (enableUD), .Output (currentLevel), 
             .Up (CountUp), .Down (CountDown), .Zero (Stopped));
  
// replaces Comparator U5
always @(*)
begin
    CountUp   = (tgtCounts > uEncCounts);                       
    CountDown = (tgtCounts < uEncCounts);                       
end

TwosCompToMagOnly #(.InputWidth (Width + 1))
                U6 (.TwosCompIn (sEncCounts), .Magnitude (uEncCounts));

ShaftEncoderIF #(.Width (Width + 1),
                 .PrescalerWidth (2))
             U7 (.PhaseA (EncoderX), .PhaseB (EncoderY), .Clock12MHz (Clock), .Clear (Clear),
                 .LatchCounter (latchCount), .Half (), .LatchedCount (sEncCounts));

//ShaftEncoderIF_Sim #(.Width (Width + 1),
//                     .MaxCount (20),
//                     .AllowNeg (0))
//             U7 (.PhaseA (EncoderX), .PhaseB (EncoderY), .Clock12MHz (Clock), .Clear (Clear),
//                 .LatchCounter (latchCount), .Half (), .LatchedCount (sEncCounts));

TargetLevelReg #(.Width (Width))  
            U10 (.Clk (Clock), .Clr (Clear), .Load (Load), .InputLevel (RequestedSpeed), .OutputLevel (tgtCounts));                                                               

endmodule



