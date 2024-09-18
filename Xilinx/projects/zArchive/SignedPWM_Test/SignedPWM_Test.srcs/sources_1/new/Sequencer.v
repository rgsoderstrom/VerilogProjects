/*
    Sequencer - for signed PWM test
*/

`timescale 1ns / 1ps

module Sequencer (input  Clock50MHz,  // 50 MHz
                  input  ClearBar,   // active low
                  output PWM1,
                  output Dir1,
                  output PWM2,
                  output Dir2,
                  input  Enc3X,
                  input  Enc3Y,
                  input  Enc4X,
                  input  Enc4Y,
                  output Clock1Hz); // io 27

    localparam InputClockFreq = 32'd50_000_000; // Hardware oscillator freq.
    localparam SpwmClockFreq  = 32'd3_125_000;
    //localparam SpwmClockFreq  = 32'd2_500_000;
    	                       
    wire Clear;
    wire ClockSPWM; 
	wire Pulse1Hz;
		
    reg  Load1;
	wire SLoad1;
    reg  [7:0] Level1;
	
    reg  Load2;
	wire SLoad2;
    reg  [7:0] Level2;
    
    reg  [31:0] seconds;

    assign Clear = !ClearBar;
    
    initial 
    begin
        Load1  <= 0;
        Level1 <= 8'd0;
        Load2  <= 0;
        Level2 <= 8'd0;
    end
                       
    ClockDivider #(.Divisor (InputClockFreq / SpwmClockFreq))
	           U1 (.FastClock (Clock50MHz),   // Mercury 2 clock, 50Mhz
                   .Clear (Clear),            // active high
                   .Pulse (),
                   .SlowClock (ClockSPWM)); 
                     
    ClockDivider #(.Divisor (SpwmClockFreq))
               U2 (.FastClock (ClockSPWM), 
                   .Clear (Clear),          
                   .Pulse (Pulse1Hz),
                   .SlowClock (Clock1Hz));
                   
    SignedPWM #(.Width (8), .InputClockFreq (SpwmClockFreq), .Deadband (10)) // was db = 45, 55 
            Z3 (.SignedLevel (Level1),  // twos complement
                .Load (SLoad1),
                .Clk (ClockSPWM),
                .Clr (Clear),
                .PulseTrain (PWM1),
                .MotorDirection (Dir1),
                .Stopped (),
                .EncoderX (Enc4X), 
                .EncoderY (Enc4Y)),
                                      
            Z4 (.SignedLevel (Level2),
                .Load (SLoad2),
                .Clk (ClockSPWM),
                .Clr (Clear),
                .PulseTrain (PWM2),
                .MotorDirection (Dir2),
                .Stopped (),
                .EncoderX (Enc3X), 
                .EncoderY (Enc3Y));
				  
    SyncOneShot U5 (.trigger (Load1), // pos edge trigger
                    .clk (ClockSPWM),
                    .clr (Clear),
                    .Q (SLoad1));

    SyncOneShot U6 (.trigger (Load2),
                    .clk (ClockSPWM),
                    .clr (Clear),
                    .Q (SLoad2));
	
    initial 
    begin
        seconds <= 32'd0;
    end
    
    always @ (posedge ClockSPWM)
    begin
        if (Clear == 1'b1)
            seconds <= 32'd0;

        else if (Pulse1Hz)
        begin
            if (seconds < 59)
                seconds <= seconds + 32'd1;
            else        
                seconds <= 32'd0;
        end
    end    
    
    always @ (posedge ClockSPWM)  
    begin
        if (Pulse1Hz)
            case (seconds) 
                1:  begin Level1 <=  8'd127; Load1 <= 1; end // work well with db == 1
               30:  begin Level1 <= -8'd127; Load1 <= 1; end

//               40:  begin Level2 <= -8'd100; Load2<= 1; end
//               45:  begin Level2 <= -8'd100; Load1<= 1; end
//               50:  begin Level2 <=  8'd100; Load2<= 1; end
            
                default: begin Load1 <= 0; Load2 <= 0; end
            endcase        
        end                                      
endmodule
