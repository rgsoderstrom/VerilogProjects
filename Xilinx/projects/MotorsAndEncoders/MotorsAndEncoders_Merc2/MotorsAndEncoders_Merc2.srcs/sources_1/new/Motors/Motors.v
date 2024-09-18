
/*
    Motors.v 
        - container for DC motor control logic
        - includes logic to receive and decode input messages
*/

`timescale 1ns / 1ps

module Motors #(parameter InputClockFreq =  32'd3_125_000)
              (input InputBit,  
               input InputShiftClock,
               input InputByteDone,
               
               input Encoder1X,
               input Encoder1Y,
               input Encoder2X,
               input Encoder2Y,
                          
               output PWM1,
               output Dir1,
               output PWM2,
               output Dir2,
                          
               output ProfileDone,
               output StartCollection,
               output StopCollection,
               output BuildCollMsg,
               output SendCollMsg,
                                       
               input  Clear,     // active high
               input  Pulse10Hz,
               input  Clock); 

    localparam SW = 8;  // Speed width
    localparam DW = 8;  // Duration width
                                                                                                                                                                                           
    wire [7:0] U1InputByte;
    wire       U1InputByteReady;
        
    wire       U2MessageComplete;
    wire [7:0] U2MessageID, U2MessageWord;
    wire [5:0] U2ByteCount;
    
    wire [SW-1:0] U4Speed;
    wire [DW-1:0] U4Duration;
    wire [5:0]    U4ReadAddr;    
    wire U4Load1, U4Load2;
               
    wire U5Load, U5ProfileDone;
    wire [SW-1:0] U5Level;               
               
    wire U6Load, U6ProfileDone;
    wire [SW-1:0] U6Level;               
               
    wire U7Stopped, U8Stopped;
                   
    wire SInputShiftClock, SInputByteDone;
                       
    assign ProfileDone = U5ProfileDone & U6ProfileDone;               
                                            
    SyncOneShot U11 (.trigger (InputShiftClock), // pos edge trigger
                     .clk (Clock),
                     .clr (Clear),            // async, active high
                     .Q (SInputShiftClock));  // pos pulse, one clock period long

    SyncOneShot U12 (.trigger (InputByteDone), // pos edge trigger
                     .clk (Clock),
                     .clr (Clear),            // async, active high
                     .Q (SInputByteDone));    // pos pulse, one clock period long


    SerializerStoP #(.Width (8)) 
                 U1 (.DataIn  (InputBit),
                     .Shift   (SInputShiftClock),
                     .Done    (SInputByteDone),   // data source sets this true when entire word has been shifted in
                     .Clr     (Clear),            // sync, active high
                     .Clk     (Clock),            // pos edge trigger
                     .Ready   (U1InputByteReady), // copy of "Done" input
                     .DataOut (U1InputByte));
               
    MessageReader U2 (.Input           (U1InputByte),
                      .Write           (U1InputByteReady),
                      .MessageComplete (U2MessageComplete),
                      .MessageID       (U2MessageID),
                      .ByteCount       (U2ByteCount),
                      .MessageWord     (U2MessageWord), // == Storage [ReadAddr]
                      .ReadAddr        (U4ReadAddr),
                      .Clock (Clock),
                      .Clear (Clear));
    
    MessageRouter U3 (.MessageID    (U2MessageID),
                      .MessageValid (U2MessageComplete),
                      .ClearProfile (U3ClearProfile),
                      .LoadProfile  (U3LoadProfile),
                      .RunProfile   (U3RunProfile),
                      .StopProfile  (U3StopProfile),
                      .StartCollection (StartCollection),
                      .StopCollection  (StopCollection),
                      .BuildCollMsg (BuildCollMsg),
                      .SendCollMsg  (SendCollMsg));
             
    ProfileLoader U4 (.LoadProfile  (U3LoadProfile),
                      .MessageByte  (U2MessageWord),
                      .ReadAddr     (U4ReadAddr),
                      .Speed        (U4Speed),  // actually velocity, 2's complement
                      .Duration     (U4Duration),
                      .MsgByteCount (U2ByteCount),                      
                      .Load1  (U4Load1),
                      .Load2  (U4Load2),
                      .Clear  (Clear),
                      .Clock  (Clock));

    SingleMotorController #(.SpeedWidth (SW), .DurationWidth (DW))
            U5 (.SpeedIn      (U4Speed),    // velocity, 2's complement, will be converted to sign-magnitude
                .DurationIn   (U4Duration),
                .LoadSegment  (U4Load1),
                .ClearProfile (U3ClearProfile),
                .RunProfile   (U3RunProfile),
                .StopProfile  (U3StopProfile),
                .ProfileDone  (U5ProfileDone),
                .PwmLoad      (U5Load),
                .PwmLevel     (U5Level),
                .PwmStopped   (U7Stopped),
                .Clear      (Clear), // active high
                .Pulse10Hz  (Pulse10Hz),
                .Clock      (Clock)),
                
            U6 (.SpeedIn      (U4Speed),    // velocity, 2's complement, will be converted to sign-magnitude
                .DurationIn   (U4Duration),
                .LoadSegment  (U4Load2),
                .ClearProfile (U3ClearProfile),
                .RunProfile   (U3RunProfile),
                .StopProfile  (U3StopProfile),
                .ProfileDone  (U6ProfileDone),
                .PwmLoad      (U6Load),
                .PwmLevel     (U6Level),
                .PwmStopped   (U8Stopped),
                .Clear     (Clear), // active high
                .Pulse10Hz (Pulse10Hz),
                .Clock     (Clock));
                
    SignedPWM #(.Width (SW), .InputClockFreq (InputClockFreq), .Deadband (20))
            U7 (.SignedLevel (U5Level),  // twos complement
                .Load (U5Load),
                .Clk (Clock),
                .Clr (Clear),
                .PulseTrain (PWM1),
                .MotorDirection (Dir1),
                .Stopped (U7Stopped),
                .EncoderX (Encoder1X), .EncoderY (Encoder1Y)),
                 
            U8 (.SignedLevel (U6Level),  // twos complement
                .Load (U6Load),
                .Clk (Clock),
                .Clr (Clear),
                .PulseTrain (PWM2),
                .MotorDirection (Dir2),
                .Stopped (U8Stopped),
                .EncoderX (Encoder2X), .EncoderY (Encoder2Y));
endmodule
