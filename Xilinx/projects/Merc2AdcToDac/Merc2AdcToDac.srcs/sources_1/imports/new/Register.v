
/*
    Register 
        - used in "Encoders" simulations, in place of SerializerP2S, to verify logic up to
          the output SerializerP2S shift register  
		  
		- also used as general register, with GetNext and Empty not used
*/    

`timescale 1ns / 1ps

module Register #(parameter Width = 8)
                 (input [Width-1:0]  Input,
                  input              Clr,   // sync, active high
                  input              Clk,   // pos edge triggered
                  input              Load,
  				  output reg         Empty,     // ready to load,
                  output reg [Width-1:0] Output,
                  input              GetNext);

    reg [Width-1:0] DataRegister;
    
    always @ (*)
        Output = DataRegister;
              
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
        begin
            DataRegister <= 0;
            Empty <= 1;
        end
        
        else if (Load == 1'b1)
        begin
            DataRegister <= Input;
            Empty <= 0;
        end
        
        else if (GetNext == 1'b1)
        begin
            Empty <= 1;
        end
    end              
endmodule
