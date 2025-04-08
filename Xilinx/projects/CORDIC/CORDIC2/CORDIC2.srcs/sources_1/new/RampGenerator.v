/*
    RampGenerator
        - make the time-varying gain (TVG) ramp for sonar receiver
        - see Visio documentation
*/  

// this was replaced by RampCounter.v for CORDIC3 and later  

`timescale 1ns / 1ps

module RampGenerator #(parameter Width = 10,              // bits, matches DAC
                                 ClockFrequency = 50e6,   // Hz
                                 DelayTime = 0.005,      // seconds
                                 BlankingVoltage = 0.1,  // volts
                                 InitialVoltage  = 0.25, // "
                                 FinalVoltage = 1.25,    // "
                                 RampTime = 0.030)       // seconds 
                        (input  Clock,
                         input  Clear,
                         input  Trigger,
                         input  Enable,
                         output [Width-1:0] Ramp);
                         
    localparam VoltsPerCount    = 2.048 / 1023; // determined by DAC hardware
    localparam BlankingCounts   = BlankingVoltage / VoltsPerCount;    
    localparam InitialCounts    = InitialVoltage / VoltsPerCount;
    localparam FinalCounts      = FinalVoltage / VoltsPerCount;    
    localparam RampCounts       = FinalCounts - InitialCounts;
    localparam RampRate         = RampCounts / RampTime;                          
    localparam StartDelayClocks = DelayTime * ClockFrequency;
    localparam ClockDivisor     = ClockFrequency / RampRate;
    
    localparam Idle       = 3'd0;
    localparam StartDelay = 3'd1;
    localparam Delay      = 3'd2;
    localparam StartRamp  = 3'd3;
    localparam RampUp     = 3'd4;
    
    reg [Width-1:0] RampFinal = FinalCounts; // need this in a reg so I can compare to it
        
    reg [Width-1:0] RampCounter; // 
    assign Ramp = RampCounter;
    
    reg [19:0]      DelayCounter;  // 
    reg [2:0] State;
    
    reg  RampStep;
    reg  RampCount;
    reg  RampLoadBlanking;
    reg  RampLoadInitial;    
    reg  DelayLoad;
    reg  DelayCountdown;
            
    //***************************************************************
    
    initial
      begin
        RampCounter <= 0;
        DelayCounter <= 0;
        State <= 0;
      end
        
    //***************************************************************
    
    // pull ClockDivider.v logic in.

//    ClockDivider #(.Divisor (ClockDivisor)) 
// 			   U1 (.FastClock (Clock),  
//                 .Clear (1'b0),     // active high
//                 .SlowClock (),  // (FastClock / Divisor), 50% duty cycle
//				   .Pulse (RampStep));
				   
    reg [31:0] RampRateCount;
       
    initial
        RampRateCount = ClockDivisor - 1;
    
    always @ (*)            
	   RampStep = (RampRateCount == 0);
	
    always @ (posedge Clock) 
        begin
            if (Clear == 1'b1)
                RampRateCount <= ClockDivisor - 1;
            
            else if (RampRateCount == 0)
                RampRateCount <= ClockDivisor - 1;
                
            else
                RampRateCount <= RampRateCount - 1'b1;
        end
    
    //***************************************************************
    
    // Delay Counter
    
    always @ (posedge Clock)
        begin
            if (Clear == 1)
            begin
                DelayCounter <= 0;
            end
            
            else if (DelayLoad)
            begin
                DelayCounter <= StartDelayClocks;
            end
            
            else if (DelayCountdown)
            begin
                if (DelayCounter != 0)
                    DelayCounter <= DelayCounter - 1;
            end    
        end
            
    //***************************************************************
    
    // Ramp Counter
    
    always @ (posedge Clock)
        begin
            if (Clear == 1)
            begin
                RampCounter <= 0;
            end
            
            else if (RampLoadBlanking)
            begin
                RampCounter <= BlankingCounts;
            end
            
            else if (RampLoadInitial)
            begin
                RampCounter <= InitialCounts;
            end
            
            else if (RampCount == 1)
            begin
                if (RampCounter != RampFinal) 
                    RampCounter <= RampCounter + 1;
            end    
        end
                
    //***************************************************************
    
    always @ (posedge Clock)
        begin
            if (Clear == 1)
            begin
                State <= 0;
            end
            
            else if (Enable == 1)
            begin
                if (Trigger == 1) 
                begin 
                    State <= 1; 
                end
                
                else
                begin
                    case (State)
                        Idle:       if (Trigger == 1) State <= StartDelay;                    
                        StartDelay: State <= Delay;                                    
                        Delay:      if (DelayCounter == 0) State <= StartRamp;                    
                        StartRamp:  State <= RampUp;                                        
                        RampUp:     if (RampCounter == RampFinal) State <= Idle;
    
                        default: State <= Idle;
                    endcase
                end
            end
        end
	
    always @ (*)
        begin
            RampCount        <= (State == RampUp && RampStep == 1);
            RampLoadBlanking <= (State == StartDelay);
            RampLoadInitial  <= (State == StartRamp);    
            DelayLoad        <= (State == StartDelay);
            DelayCountdown   <= (State == Delay);
        end    
endmodule

