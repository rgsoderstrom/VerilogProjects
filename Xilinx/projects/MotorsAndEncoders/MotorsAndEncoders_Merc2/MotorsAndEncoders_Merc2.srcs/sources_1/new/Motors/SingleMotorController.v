
/*
    SingleMotorController
*/

`timescale 1ns / 1ps

module SingleMotorController #(parameter SpeedWidth = 8,
                               parameter DurationWidth = 8) 
                              (input [SpeedWidth-1:0]    SpeedIn,    // velocity, 2's complement, will be converted to sign-magnitude
                               input [DurationWidth-1:0] DurationIn,

                               input LoadSegment,
                               input ClearProfile,
                               input RunProfile,
                               input StopProfile,
                               
                               output ProfileDone,
                               
                               output reg              PwmLoad,
                               output [SpeedWidth-1:0] PwmLevel,
                               input                   PwmStopped,
    
                               input Clear, // active high
                               input Pulse10Hz,
                               input Clock);
                        
    assign PwmDone = 1; // no longer implemented by signed PWM                        
    localparam FIFO_AddrWidth = 5; // allow 32 entries

    reg [SpeedWidth-1:0] ZeroSpeed = 0;
    reg ZeroBit = 1'b0;
    
    //************************************************************
        
    reg  FIFO_read;
    wire FIFO_empty;                               
    wire TimerDone, SpeedSelect;    
    reg  TimerLoad;
    wire TimerEnable;
    
    reg  ProfileDoneJ, ProfileDoneK;
    reg  TimerEnableJ, TimerEnableK;
    reg  SpeedSelectJ, SpeedSelectK;
    
    wire [SpeedWidth-1:0] SpeedOut;
    wire [DurationWidth-1:0] DurationOut;
    
    assign FIFO_clear = Clear | ClearProfile;
    
    //************************************************************
                               
    FIFO1 #(.DataWidth (SpeedWidth), .AddrWidth (FIFO_AddrWidth))
        U1 (.Clk (Clock), .Clr (FIFO_clear), .Empty (FIFO_empty), .Full (), .WriteData  (SpeedIn), .ReadData (SpeedOut),
            .NumberStored (), .WriteCycle (LoadSegment), .ReadCycle  (FIFO_read));  
    
    FIFO1 #(.DataWidth (DurationWidth), .AddrWidth (FIFO_AddrWidth))
        U2 (.Clk (Clock), .Clr (FIFO_clear), .Empty (), .Full (), .WriteData  (DurationIn), .ReadData (DurationOut),
            .NumberStored (), .WriteCycle (LoadSegment), .ReadCycle  (FIFO_read));  
        
    Mux2 #(.Width (SpeedWidth))
        U3 (.in0 (ZeroSpeed), .in1 (SpeedOut), .select (SpeedSelect), .out (PwmLevel));

    EventCountDown #(.Width (DurationWidth)) 
 				 U4 (.LoadValue (DurationOut), .Load   (TimerLoad), .Enable (TimerEnable), .Event  (Pulse10Hz),
                     .Clear  (Clear), .Clock  (Clock), .AtZero (TimerDone));
               		
    JKFF #(.InitialQ (1))
       U5 (.J (ProfileDoneJ), .K (ProfileDoneK), .Clk (Clock), .Set (Clear), .Clear (ZeroBit), .Q (ProfileDone));
      
    JKFF #(.InitialQ (0))
       U6 (.J (TimerEnableJ), .K (TimerEnableK), .Clk (Clock), .Set (ZeroBit), .Clear (Clear), .Q (TimerEnable)),
       U7 (.J (SpeedSelectJ), .K (SpeedSelectK), .Clk (Clock), .Set (ZeroBit), .Clear (Clear), .Q (SpeedSelect));
      
//**********************************************************************************
        
    reg [3:0] state;
    
    initial
        state = 0;
        
    always @ (posedge Clock)
        begin
            if (Clear == 1'b1)
                    state = 0;
              
            else if (StopProfile == 1'b1)
                    state = 10;
              
            else
                begin
                    case (state)
                        0:  if (RunProfile == 1) state = 1;
                        1:  if (FIFO_empty == 1) state = 10; else state = 2;
                        2:  state = 3;
                        3:  state = 4;
                        4:  state = 5;
                        5:  state = 6;
                        6:  if (PwmDone == 1) state = 7;
                        7:  state = 8;
                        8:  if (TimerDone == 1) state = 9;
                        9:  state = 1;
                        10: state = 11;
                        11: state = 12;
                        12: if (PwmStopped == 1) state = 13;
                        13: state = 0;
                        
                        default: state = 0;
                    endcase
                end
        end

    //************************************************************************
            
    always @ (*)
        begin
            SpeedSelectJ <= (state == 2);
            ProfileDoneK <= (state == 3);                       
            FIFO_read    <= (state == 4);
            TimerLoad    <= (state == 5);
            PwmLoad      <= (state == 5 || state == 11);
            TimerEnableJ <= (state == 7); 
            TimerEnableK <= (state == 9); 
            SpeedSelectK <= (state == 10);
            ProfileDoneJ <= (state == 13);           
        end
                            		
endmodule

