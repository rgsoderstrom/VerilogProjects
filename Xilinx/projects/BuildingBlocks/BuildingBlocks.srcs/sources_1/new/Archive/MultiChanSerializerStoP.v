`timescale 1ns / 1ps

//
// SerializerStoP - serializer, serial in parallel out
//      - two output channels of same width
//

module SerializerStoP #(parameter Width = 4) 
                       (input DataIn,
                        input Shift,
                        input Clr,  // sync, active high
                        input Clk,  // pos edge trigger
                        output  [Width-1:0] Q1,
                        output  [Width-1:0] Q2);
    
    localparam N = 2 * Width;            
    localparam MSB1 = N - 1;     
    localparam MSB2 = MSB1 - Width;     
         
    reg [N-1:0] accumulator;

    assign Q1 = accumulator [MSB1 : MSB1 - Width + 1];        
    assign Q2 = accumulator [MSB2 : MSB2 - Width + 1];
                                  
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
        begin
            accumulator <= 0;
        end        
        
        else if (Shift == 1'b1)
        begin
            accumulator [N - 1 : 1] <= accumulator [N - 2 : 0];
            accumulator [0] <= DataIn;
        end                
    end
                         
endmodule
