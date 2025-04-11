/*
   CounterUEC.v
		- up count only, wraps after Max
*/

`timescale 1ns / 1ps

module CounterUEC #(parameter Width = 8,
                    parameter Max = (1 << Width) - 1)
                   (input  wire            Enable,
				    input  wire            Clr,   // sync, active high
                    input  wire            Clk,   // pos edge triggered
					output reg             AtZero,
					output reg             AtMax,
                    output reg [Width-1:0] Q);

    reg [Width-1:0] Count;
	
//    always @ (*) begin
    always @ (posedge Clk) begin
        Q      = Count;
		AtZero = (Count == 0);
		AtMax  = (Count == Max);
	end
	
	initial
		Count = 0;
		
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
            Count <= 0;
        
        else if (Enable == 1'b1)
			if (AtMax == 1)
				Count <= 0;
			else
				Count <= Count + 1;
    end              
endmodule
	
