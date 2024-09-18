/*
    CLPWM_PulseGen.v
*/
    
`timescale 1ns / 1ps

module CLPWM_PulseGen #(parameter ClockFreq = 3_125_000)
                      (input Clock,
                       input Clear,
                       input FastUD,
                       output LatchCount, // 20Hz (or very close)
                       output EnableUD);  //

localparam NumbCounterStates = 12;
localparam MotorChangeRate = 2;  // speed "hunts" if greater than 2 
                       
wire Pulse240Hz;
reg  [3:0] Count;
reg EN;

ClockDivider #(.Divisor (ClockFreq / 240))
 	       U1 (.FastClock (Clock), .Clear (Clear), .SlowClock (), .Pulse (Pulse240Hz));
 	       			   
assign LC  = (Count == 0);		   
assign EN1 = (Count == 1);
assign EN2 = (Count == 1) | (Count == 7);
assign EN3 = (Count == 1) | (Count == 5) | (Count == 9);
assign EN4 = (Count == 1) | (Count == 4) | (Count == 7) | (Count == 10);
assign EN6 = (Count == 1) | (Count == 3) | (Count == 5) | (Count == 7) | (Count == 9) | (Count == 11);

always @ (*)
    begin
        if (FastUD == 1)
        begin
            if      (MotorChangeRate == 1) EN = EN1;
            else if (MotorChangeRate == 2) EN = EN2;
            else if (MotorChangeRate == 3) EN = EN3;
            else if (MotorChangeRate == 4) EN = EN4;
            else if (MotorChangeRate == 6) EN = EN6;
            else EN = EN1;
        end
        else
            EN = EN1;
    end
    
SyncOneShot 
        U4 (.trigger (LC), .clk (Clock), .clr (Clear), .Q (LatchCount)),
        U5 (.trigger (EN), .clk (Clock), .clr (Clear), .Q (EnableUD));
    
initial 
    Count = 0;
  
always @ (posedge Clock)
begin
        if (Pulse240Hz)
        begin
            if (Count == NumbCounterStates - 1)
                Count <= 0;
            else
                Count <= Count + 1;        
        end
end
                          
endmodule
