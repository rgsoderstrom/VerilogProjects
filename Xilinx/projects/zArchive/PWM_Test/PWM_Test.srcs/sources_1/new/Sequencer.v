/*
    Sequencer - for PWM test
*/




// see Sequencer.v for SignedPWM for necessary changes





`timescale 1ns / 1ps

module Sequencer #(parameter ClockDiv2 = 32'd12_500_000) // 12.5MHz -> 1PPS, real hardware
                  (input  Clock50MHz,  // 50 MHz
                   input  ClearBar,   // active low
                   output PWM1,
                   output reg Done1,
                   output PWM2,
                   output Done2);

    localparam ClockDiv1 = 4;              // 50MHz -> 12.5MHz
  //localparam ClockDiv2 = 32'd12_500_000; // 12.5MHz -> 1PPS, real hardware
  //localparam ClockDiv2 = 32'd12;         // 12.5MHz -> 1PPS, simulations
	         
	localparam W1 = 7;
	localparam W2 = 18;
	              
    wire Clear;
    wire Clock12MHz; // actually 12.5MHz
	wire Pulse1Hz;
	
	
    reg  Load1;
	wire SLoad1;
    reg  [W1-1:0] Level1;
	
    reg  Load2;
	wire SLoad2;
    reg  [W1-1:0] Level2;
    
    reg  [31:0] seconds; // good
    //reg  [5:0] seconds; // causes warnings

    assign Clear = !ClearBar;
    
    initial 
    begin
        Load1  <= 0;
        Level1 <= 0;
        Load2  <= 0;
        Level2 <= 0;
    end
                       
    ClockDivider #(.Divisor (ClockDiv1))
	           U1 (.FastClock (Clock50MHz),   // Mercury 2 clock, 50Mhz
                   .Clear (Clear),            // active high
                   .Pulse (),
                   .SlowClock (Clock12MHz)); 
                     
    ClockDivider #(.Divisor (ClockDiv2))
               U2 (.FastClock (Clock12MHz), 
                   .Clear (Clear),          
                   .Pulse (Pulse1Hz),
                   .SlowClock ());
                     
                     
                     
    PWM #(.InputLevel_Width (W1), .FreeCounter_Width (W2))
        Z3 (.CLK12MHZ (Clock12MHz),
            .Clr (Clear),
            .Load (SLoad1),
            .Level (Level1), // unsigned   
            .AtLevel (), // (Done1),                     // PWM is at requested level
            .PWM (PWM1)),
                     
        Z4 (.CLK12MHZ (Clock12MHz),
            .Clr (Clear),
            .Load (SLoad2),
            .Level (Level2), // unsigned   
            .AtLevel (Done2),                     // PWM is at requested level
            .PWM (PWM2));
                     
                     
    SyncOneShot U5 (.trigger (Load1), // pos edge trigger
                    .clk (Clock12MHz),
                    .clr (Clear),
                    .Q (SLoad1));

    SyncOneShot U6 (.trigger (Load2),
                    .clk (Clock12MHz),
                    .clr (Clear),
                    .Q (SLoad2));

	
    initial 
        seconds <= 32'd0;
    
    always @ (posedge Pulse1Hz)
    begin
        if (Clear == 1'b1)
            seconds <= 32'd0;
    
        else begin
            case (seconds)  // motor 1 
                0:  begin Done1 = 1; Level1 <=  'd100; Load1<= 1; end
                30: begin Done1 = 0; Level1 <=  'd0; Load1<= 1; end
            
                default: Load1 <= 0;
            endcase        
        
            case (seconds) // motor 2
                0:  begin Level2 <= 'd127; Load2<= 1; end
                30:  begin Level2 <= 'd0;  Load2<= 1; end
            
                default: Load2 <= 0;
            endcase        
        
            seconds <= seconds + 32'd1;
            
            if (seconds == 32'd60)
                seconds <= 32'd0;
        end              
    end
                                      
endmodule
