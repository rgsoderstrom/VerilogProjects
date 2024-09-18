/*
   CounterUEC.v
		- up count only, wraps after max
		- enable
		- clear
*/

`timescale 1ns / 1ps

module CounterUEC #(parameter Width = 8)
                   (input                  Enable,
				    input                  Clr,   // sync, active high
                    input                  Clk,   // pos edge triggered
                    output reg [Width-1:0] Output);

    reg [Width-1:0] Count;
	
    always @ (*)
        Output = Count;
	
	initial
		Count = 0;
		
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
            Count <= 0;
        
        else if (Enable == 1'b1)
            Count <= Count + 1;
    end              
endmodule
	
