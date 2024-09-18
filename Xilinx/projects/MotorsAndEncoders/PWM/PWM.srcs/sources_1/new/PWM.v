/*
    PWM, Ver. 2
		- pulse width modulator. 	
		- Magnitude only
		- skips over dead-band
*/

`timescale 1ns / 1ps

module PWM #(parameter Width = 7,
                       FreeCounter_Width = 18,
					   Deadband = 1)
            (input             Clk12MHz,
             input             Clr,
             input             PWMLoad,
             input [Width-1:0] RequestedLevel,   
             output            AtReqLevel, // PWM is at requested level
             output            PWM);

localparam N = Width; // just a shorter alias

wire [N-1:0] FreeLSBs;     // free-running counter LSBs
wire [N-1:0] CL;           // output of CurrentLevel U/D counter
wire         EnableUD;     // overflow bit of free-running counter
wire [N-1:0] TL;           // TargetLevel, level PWM is transitioning to
wire         CountUp;      // tell CurrentLevel counter to change
wire         CountDown;    // ditto
wire         DelayedLoad;

wire         ILR;  // intermediate level reached;
wire         setTLMS, clrTLMS, TLMS; // Target Level Mux Select;
wire         setCL, clrCL;
wire         setTL, clrTL;
wire         setAL, clrAL;

wire [N-1:0] TLM; // MuxOut
reg  [N-1:0] DeadbandReg = Deadband;

PWM_Controller #(.Width (N), .Deadband (Deadband))
    U1 (.load              (DelayedLoad),
        .targetLevel       (TL),
        .currentLevel      (CL),
        .ILR               (ILR),  

        .clrTLMS (clrTLMS), .setTLMS (setTLMS),
        .clrCL   (clrCL),   .setCL (setCL),
        .clrTL   (clrTL),   .setTL  (),
        .setAL   (setAL),   .clrAL (clrAL),                 
        .Clear (Clr), 
		.Clock (Clk12MHz));

FreeCounter #(.CounterWidth (FreeCounter_Width), .OutputWidth (N)) 
    U2 (.Clk (Clk12MHz), .Clr (Clr), .Overflow (EnableUD), .LSBs (FreeLSBs));
 
Comparator #(.Width (N))
    U3 (.A (FreeLSBs), .B (CL), .Greater (), .Less (PWM), .Equal ());

assign clearCurrent = Clr | clrCL;

UpDownCounter #(.Width (N)) 
    U4 (.Clk (Clk12MHz), .Clr (clrCL), .Enable (EnableUD), .Count (CL), .Up (CountUp), .Down (CountDown),
        .Load (setCL), .Preset (DeadbandReg));

Comparator #(.Width (N))
    U5 (.A (TLM), .B (CL), .Greater (CountUp), .Less (CountDown), .Equal (ILR));       

assign tlrClear = Clr | clrTL;

TargetLevelReg #(.Width (N)) 
    U6 (.Clk (Clk12MHz), .Clr (tlrClear), .Load (PWMLoad), .InputLevel (RequestedLevel), .OutputLevel (TL));
            
Mux2 #(.Width (N))
	U7 (.in0 (DeadbandReg), .in1 (TL), .select (TLMS), .out (TLM));
	
JKFF #(.InitialQ (1))
    U8 (.J (setAL),    .K (clrAL),    .Set (Clr), .Clear (), .Clk (Clk12MHz), .Q (AtReqLevel)),	
    U9 (.J (setTLMS),  .K (clrTLMS),  .Set (Clr), .Clear (), .Clk (Clk12MHz), .Q (TLMS));	
        
FDC u10 (.D (PWMLoad), .C (Clk12MHz), .Q (DelayedLoad), .CLR (Clr));


        
        
endmodule
