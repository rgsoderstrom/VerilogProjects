`timescale 1ns / 1ps

module TwosCompToSignMag #(parameter Width = 5)
                          (input [Width-1:0] TwosCompIn,
                           input Load,
                           input Clear,
                           input Clk,
                           output reg Sign,
                           output reg [Width-2:0] Magnitude);
                           
    localparam mask = (1 << Width - 1) - 1;
                               
    always @ (posedge Clk)
    begin
        if (Clear == 1'b1)
        begin
            Sign <= 0;
            Magnitude <= 0;
        end
        
        else if (Load == 1)
        begin
            if (TwosCompIn [Width-1] == 1'b1) // sign bit set
            begin
                Sign <= 1'b1;
                Magnitude <= (TwosCompIn [Width-2:0] ^ mask) + 1;
            end
                
            else
            begin
                Sign <= 1'b0;
                Magnitude <= TwosCompIn [Width-2:0];
            end
        end                    
    end

endmodule
