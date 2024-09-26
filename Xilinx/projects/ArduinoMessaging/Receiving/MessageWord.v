
/*
    MessageWord.v
	  - Get data from a message with a single data word
	  - Connect input to a MsgRouter
*/

`timescale 1ns / 1ps

module MessageWord #(parameter BytesPerWord = 4,
                     parameter Default = 0)
                    (input  Clock,                   
					 input ClearAddr,
					 input WriteByte,
					 input  [7:0]  DataByte,
					 output [8 * BytesPerWord - 1:0] DataWord);

    localparam NumberBits = 8 * BytesPerWord;
 	localparam AddrBits = $clog2 (NumberBits);
    reg  [AddrBits-1:0] MSB = 7;

	reg [8 * BytesPerWord - 1:0] DataByteSet = Default;
	assign DataWord = DataByteSet;

    always @(posedge Clock)
    begin
		if (ClearAddr == 1)
			MSB <= 7;
			
		else if (WriteByte == 1)
		begin
			DataByteSet [MSB-:8] <= DataByte;
			MSB <= MSB + 8;
		end
    end
endmodule




