
//
// Counter.v
//

`timescale 1ns / 1ps

module Counter #(parameter Width = 4)
                (input  Change,
                 input  UDbar, // up/down-bar
                 input  Clk,
                 input  Clr,
                 output Half,  // true when counter at half of max, either pos or neg
                 output reg [Width-1:0] Count);
                
    assign Half = (Count [Width-1] != Count [Width-2]);

    initial
        Count = 0;
                             
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
            Count <= 0;
			
        else if (Change == 1'b1)
        begin
            if (UDbar == 1'b1)
                Count <= Count + 1'b1;
            else
                Count <= Count - 1'b1;
        end
    end
                    
endmodule
