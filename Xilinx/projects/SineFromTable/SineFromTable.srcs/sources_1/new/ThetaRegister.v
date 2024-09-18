
/*
    ThetaRegister 
*/    

`timescale 1ns / 1ps

module ThetaRegister #(parameter Width = 8)
                      (input [Width-1:0]  Input,
                       input              Clr,   // sync, active high
                       input              Clk,   // pos edge triggered
                       input              Load,
                       output reg [Width-1:0] Output);

    reg [Width-1:0] DataRegister;
    
    always @ (*)
        Output = DataRegister;
              
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
        begin
            DataRegister <= 0;
        end
        
        else if (Load == 1'b1)
        begin
            DataRegister <= Input;
        end
    end              
endmodule
