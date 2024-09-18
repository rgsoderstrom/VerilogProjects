
/*
    Testbench_2sCompToMag
*/

/*
	Simulation system asserts hard "Clear" for first 100ns
*/	
        
`timescale 1ns / 1ps

module Testbench_2sCompToMag;

localparam Width = 5;

reg  [Width-1:0] twosCompl = 0;
wire [Width-2:0] mag;

TwosCompToMagOnly #(.InputWidth (Width))
                U1 (.TwosCompIn (twosCompl),
                    .Magnitude (mag));

integer i;
    
initial
begin
    for (i=0; i<31; i=i+1)
    begin
        #20 twosCompl = twosCompl + 1;
    end

    #20 $finish;
end


endmodule
