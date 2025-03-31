`timescale 1ns / 1ps

//
// SerializerPtoS - Parallel to Serial
//

module SerializerPtoS #(parameter Width = 8)
                       (input wire [Width-1:0] Input,
                        input wire             Clr,   // sync, active high
                        input wire             Clk,   // pos edge triggered
                        input wire             Load,
                        input wire             Shift,
						
						output wire            Empty,     // ready to load,
						output wire            FirstBit,  // true when OutputBit is first bit of Input
						output wire            LastBit,   //  "     "      "     "  last   "   "   "						
                        output wire            OutputBit);

    localparam MSB = Width - 1;
	
    reg [Width-1:0] DataShiftRegister;
    reg [Width-1:0] FirstBitShiftRegister;
    reg [Width-1:0] LastBitShiftRegister;

    assign Empty     = (LastBitShiftRegister == 0);
    assign OutputBit = DataShiftRegister     [MSB];
    assign FirstBit  = FirstBitShiftRegister [MSB];
    assign LastBit   = LastBitShiftRegister  [MSB];
		
    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
        begin
            DataShiftRegister <= 0;
            FirstBitShiftRegister <= 0;
            LastBitShiftRegister <= 0;
        end
        
        else if (Load == 1'b1)
        begin
            DataShiftRegister <= Input;
            FirstBitShiftRegister <= (1 << MSB);
            LastBitShiftRegister <= 1;
        end
        
        else if (Shift == 1'b1)
        begin
            DataShiftRegister     <= (DataShiftRegister << 1); 
            FirstBitShiftRegister <= (FirstBitShiftRegister << 1); 
            LastBitShiftRegister  <= (LastBitShiftRegister << 1); 
        end
    end  
endmodule




