`timescale 1ns / 1ps

//
// SerializerPtoS - Parallel to Serial
//      - 4 input channels, can be different widths
//

module SerializerPtoS #(parameter Width1 = 4, 
                                  Width2 = 4, 
								  Width3 = 4,
								  Width4 = 4,
                                  Width5 = 1,
                                  Width6 = 1)
                       (input [Width1-1:0] Input1,
                        input [Width2-1:0] Input2,
                        input [Width3-1:0] Input3,
                        input [Width4-1:0] Input4,
                        input [Width5-1:0] Input5,
                        input [Width6-1:0] Input6,
                        input              Clr,   // sync, active high
                        input              Clk,   // pos edge triggered
                        input              Load,
                        input              Shift,
                        output             OutputBit);
    
    localparam N = Width1 + Width2 + Width3 + Width4 + Width5 + Width6;
    
    localparam MSB1 = N - 1;
    localparam MSB2 = MSB1 - Width1;
    localparam MSB3 = MSB2 - Width2;
    localparam MSB4 = MSB3 - Width3;
    localparam MSB5 = MSB4 - Width4;
    localparam MSB6 = MSB5 - Width5;

    localparam LSB1 = MSB1 - Width1 + 1;
    localparam LSB2 = MSB2 - Width2 + 1;
    localparam LSB3 = MSB3 - Width3 + 1;
    localparam LSB4 = MSB4 - Width4 + 1;
    localparam LSB5 = MSB5 - Width5 + 1;
    localparam LSB6 = MSB6 - Width6 + 1;

    reg [N-1:0] Content;
		
    assign OutputBit = Content [MSB3]; // [MSB1];
		
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
        begin
            Content <= 0;
        end
        
        else if (Load == 1'b1)
        begin
            Content [MSB1 : LSB1] <= Input1;
            Content [MSB2 : LSB2] <= Input2;
            Content [MSB3 : LSB3] <= Input3;
            Content [MSB4 : LSB4] <= Input4;             
            Content [MSB5 : LSB5] <= Input5;             
            Content [MSB6 : LSB6] <= Input6;             
        end
        
        else if (Shift == 1'b1)
        begin
            Content <= (Content << 1); 
        end
    end  
endmodule




