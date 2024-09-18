
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	



/*
    SPWM_Sim 
        - very minimal simulation of signed pulse width modulator
        - signals "done" (20 + Level) clocks after being loaded
*/    

`timescale 1ns / 1ps

module SPWM_Sim #(parameter Width = 8)
                 (input            Load,
                 input [Width-1:0] Level,
                 input             Clock,
                 input             Clear,
                 output reg        Done);
                 
    reg [Width-1:0] Twenty = 20;                 
    reg [Width-1:0] value;
    
    initial
        value = 0;
        
    always @ (*)
        Done = (value == 0);

    always @ (posedge Clock)
    begin
        if (Clear == 1)
            value = 0;
            
        else if (Load == 1)
            value = Level + Twenty;
    
        else if (value != 0)
            value = value - 1;
    end                                 
                 
endmodule


