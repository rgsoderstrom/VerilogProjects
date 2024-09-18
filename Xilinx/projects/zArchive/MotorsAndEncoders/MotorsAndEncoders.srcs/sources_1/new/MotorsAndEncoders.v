`timescale 1ns / 1ps

//
// MotorsAndEncoders - top module
//

module MotorsAndEncoders (input  PhaseA1,  // encoder 1
                          input  PhaseB1,
                          input  PhaseA2,  // encoder 2
                          input  PhaseB2,                          
                          output PWM1Out,
                          output PWM2Out,
                          output DataOut,  // 1 bit, to Arduino
                          input  DataIn,   // 1 bit, from Arduino
                          output triggerInterrupt, // 1 bit, to Arduino interrupt
                          input  SampleEnc,
                          input  ShiftOut,
                          input  LoadPWM,
                          input  ShiftIn,
                          input  Clr,       // active high, connected to button 0
                          input  CLK12MHZ);
                          
    wire SSampleEnc;
    wire SShiftOut;
    wire SLoadPWM;
    wire SShiftIn;
    wire [3:0] Motor1Speed;
    wire [3:0] Motor2Speed;
    
    wire Encoder1Half, Encoder2Half;
    
    SyncOneShot 
        SyncOS1 (.trigger (SampleEnc), .clk (CLK12MHZ), .clr (Clr), .Q (SSampleEnc)),
        SyncOS2 (.trigger (ShiftOut),  .clk (CLK12MHZ), .clr (Clr), .Q (SShiftOut)),
        SyncOS3 (.trigger (LoadPWM),   .clk (CLK12MHZ), .clr (Clr), .Q (SLoadPWM)),
        SyncOS4 (.trigger (ShiftIn),   .clk (CLK12MHZ), .clr (Clr), .Q (SShiftIn));

    PWM
        PWM1 (.CLK12MHZ (CLK12MHZ), .Clr (Clr), .Load (SLoadPWM), .Level (Motor1Speed), .AtLevel (PWM1Done), .PWM (PWM1Out)),
        PWM2 (.CLK12MHZ (CLK12MHZ), .Clr (Clr), .Load (SLoadPWM), .Level (Motor2Speed), .AtLevel (PWM2Done), .PWM (PWM2Out)); 

    wire [9:0] Enc1Count;
    wire [9:0] Enc2Count;
    
    assign ClearCount = SSampleEnc | Clr;
    
    ShaftEncoderIF #(.Width (10))
        SE1 (.PhaseA (PhaseA1), .PhaseB (PhaseB1), .Half (Encoder1Half), .CLK12MHZ (CLK12MHZ), .ClearCounter (ClearCount), .ClearDetector (Clr), .Count (Enc1Count)),
        SE2 (.PhaseA (PhaseA2), .PhaseB (PhaseB2), .Half (Encoder2Half), .CLK12MHZ (CLK12MHZ), .ClearCounter (ClearCount), .ClearDetector (Clr), .Count (Enc2Count));
        
    InterruptCtrl
        interupt (.in1 (Encoder1Half), .in2 (Encoder2Half), .in3 (PWM1Done), .in4 (PWM2Done), .clearInterrupt (SSampleEnc), 
                  .Clr (Clr), .Clk (CLK12MHZ), .interrupt (triggerInterrupt));
    
    SerializerPtoS #(.Width1 (10), .Width2 (10))
        ser1 (.Input1 (Enc1Count), .Input2 (Enc2Count), .Input3 (PWM1Done), .Input4 (PWM2Done),
              .Clr (Clr), .Clk (CLK12MHZ),
              .Load (SSampleEnc), .Shift (SShiftOut), .OutputBit (DataOut));
                                              
    SerializerStoP
        ser2 (.DataIn (DataIn), .Shift (SShiftIn), .Clr (Clr), .Clk (CLK12MHZ), .Q1 (Motor1Speed), .Q2 (Motor2Speed));                            

endmodule



