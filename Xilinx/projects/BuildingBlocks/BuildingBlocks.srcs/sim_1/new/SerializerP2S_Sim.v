
/*
    SerializerP2S_Sim 
        - used in simulations, in place of SerializerP2S, to verify logic up to
          the output SerializerP2S shift register  
*/    

`timescale 1ns / 1ps

module SerializerP2S_Sim #(parameter Width = 8)
                          (input [Width-1:0]  Input,
						   input              Clr,   // sync, active high
						   input              Clk,   // pos edge triggered
                           input              Load,
  				           output             Empty,     // ready to load,
                           output reg [Width-1:0] Output,
                           input              GetNext);
 
    localparam DelayClocks = 8; // number of clock cycles to shift data out
    
    reg [3:0] DelayCounter = 4'h0; // emulate Serializer delay    
    reg [Width-1:0] DataRegister;
    
    assign Empty = (DelayCounter == 0);
    
    always @ (*)
        Output = DataRegister;

    always @ (posedge Clk)
        if (DelayCounter != 0)
            DelayCounter <= DelayCounter - 1;
                          
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
        begin
            DelayCounter <= 0;
            DataRegister <= 0;
        end
        
        else if (Load == 1'b1)
        begin
            DelayCounter <= DelayClocks;
            DataRegister <= Input;
        end
        
        else if (GetNext == 1'b1) // NOT USED
        begin
            DelayCounter <= 0;
        end
    end              
endmodule
