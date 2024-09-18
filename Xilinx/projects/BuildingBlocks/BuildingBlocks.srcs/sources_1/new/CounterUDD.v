/*
   CounterUDD.v
		- up / down count
		- dead band
		- enable
		- clear
*/

`timescale 1ns / 1ps

module CounterUDD #(parameter Width = 8, 
                              Deadband = 1)
                   (input  Enable,
                    input  Up,
                    input  Down,
				    input  Clr,   // sync, active high
                    input  Clk,   // pos edge triggered
					output Zero,
                    output reg [Width-1:0] Output);

	localparam Max = (1 << Width) - 1;
	
    reg [Width-1:0] Count;
	
    always @ (*)
        Output = Count;
	
	assign Zero = (Count == 0);
	
	initial
		Count = 0;
		
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
            Count <= 0;
        
        else if (Enable == 1'b1)
        begin
			if (Up == 1)
			begin
				if (Count == 0)
					Count <= Deadband;
				else if (Count < Max)
					Count <= Count + 1;
			end
			
			else if (Down == 1'b1)
			begin
				if (Count == Deadband)
					Count <= 0;
				else if (Count > 0)
					Count <= Count - 1;			
			end
		end
    end              
endmodule
	
