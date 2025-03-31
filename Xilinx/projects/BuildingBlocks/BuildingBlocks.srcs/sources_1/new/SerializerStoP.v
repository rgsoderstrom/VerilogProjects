`timescale 1ns / 1ps

//
// SerializerStoP - serializer, serial in parallel out
//

module SerializerStoP #(parameter Width = 4) 
                       (input wire DataIn,
                        input wire Shift,
                        input wire Done,   // data source sets this true when entire word has been shifted in
                        
                        input wire Clr,  // sync, active high
                        input wire Clk,  // pos edge trigger
                        
                        output wire Ready, // copy of "Done" input
                        output reg  [Width-1:0] DataOut);
         
    assign Ready = Done;

    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
        begin
            DataOut <= 0;
        end        
        
        else if (Shift == 1'b1)
        begin
            DataOut [Width - 1 : 1] <= DataOut [Width - 2 : 0];
            DataOut [0] <= DataIn;
        end                
    end
                         
endmodule
