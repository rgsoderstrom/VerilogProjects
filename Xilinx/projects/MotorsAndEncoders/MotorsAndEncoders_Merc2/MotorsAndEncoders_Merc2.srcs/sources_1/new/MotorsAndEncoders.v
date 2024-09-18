
//
// MotorsAndEncoders - top module, serial input through SPWM outputs
//

`timescale 1ns / 1ps

module MotorsAndEncoders (input Enc3X,
                          input Enc3Y,
                          input Enc4X,
                          input Enc4Y,
                          input InputBit,  
                          input InputShiftClock,
                          input InputByteDone,

                          output PWM1,
                          output Dir1,
                          output PWM2,
                          output Dir2,
                          
                          output TestPoint,
                          
                          output OutputDataBit,
                          input  OutputBitShiftClock,
                          output LastBit,                          
                          output FirstBit,
                                                                             
                          input  ClearBar,    // active low
                          input  Clock50MHz); // 50MHz clock
                          
    localparam InputClockFreq = 32'd50_000_000; // Hardware oscillator freq.
    localparam ClockFreq      = 32'd3_125_000; //  was called SpwmClockFreq

    localparam Ten    = 10;
    localparam Twenty = 20;
               
    wire Clock;
    wire Pulse20Hz;
    wire Pulse10Hz;
    
    wire U1StartCollection;
    wire U1StopCollection;
    wire U1BuildCollMsg;
    wire U1SendCollMsg;
                  
    wire Clear;
    assign Clear = !ClearBar;
    
    ClockDivider #(.Divisor (InputClockFreq /  ClockFreq))
        U9 (.FastClock (Clock50MHz), .Clear (Clear), .Pulse (), .SlowClock (Clock)); 
                     
    ClockDivider #(.Divisor (ClockFreq / Twenty))
        U10 (.FastClock (Clock), .Clear (Clear), .Pulse (Pulse20Hz), .SlowClock ());
                     
    ClockDivider #(.Divisor (ClockFreq / Ten))
        U11 (.FastClock (Clock), .Clear (Clear), .Pulse (Pulse10Hz), .SlowClock (TestPoint));

    Motors #(.InputClockFreq (ClockFreq))
        U1 (.InputBit        (InputBit), 
            .InputShiftClock (InputShiftClock), 
            .InputByteDone   (InputByteDone),                
            
            .Encoder1X (Enc4X), .Encoder1Y (Enc4Y), .Encoder2X (Enc3X), .Encoder2Y (Enc3Y), 
            .PWM1 (PWM1), .Dir1 (Dir1), .PWM2 (PWM2), .Dir2 (Dir2),                          
            .ProfileDone (), 
            
            .StartCollection (U1StartCollection), 
            .StopCollection  (U1StopCollection), 
            .BuildCollMsg    (U1BuildCollMsg),
            .SendCollMsg     (U1SendCollMsg),
            
            .Clear     (Clear), // active high
            .Pulse10Hz (Pulse10Hz),
            .Clock     (Clock));
            
    Encoders // #(.ClockFreq (ClockFreq)) 
        U2 (.X1 (Enc3X), .Y1 (Enc3Y), 
            .X2 (Enc4X), .Y2 (Enc4Y),
            .OutputBit        (OutputDataBit),
            .LastBit          (LastBit),
            .FirstBit         (FirstBit),
            .OutputShiftClock (SOutputBitShiftClock),
            
            .StartCollection (U1StartCollection),
            .StopCollection  (U1StopCollection),
            .BuildCollectionMessage (U1BuildCollMsg),
            .SendCollectionMessage  (U1SendCollMsg),
            .SampleClock (Pulse20Hz),
            .Clear (Clear),
            .Clock (Clock));
            
    SyncOneShot U3 (.trigger (OutputBitShiftClock), .clk (Clock), .clr (Clear), .Q (SOutputBitShiftClock));
                
endmodule
