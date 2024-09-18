
/*
    MessageWord16.v
	  - Get data from a message with a single 16 bit data word
	  - Connect input to a MsgRounter
*/


// NOT TESTED


`timescale 1ns / 1ps

module MessageWord16 (input         Clock,                   
					  input         ClearAddr,
					  input         WriteByte,
					  input  [7:0]  DataByte,
					  output [15:0] DataWord);

	reg        Address = 0; 
	reg [15:0] DataByteSet = 0;
	assign DataWord = DataByteSet;

    always @(posedge Clock)
    begin
		if (ClearAddr == 1)
			Address <= 0;
			
		else if (WriteByte == 1)
		begin
			case (Address)
				0: DataByteSet   [7:0] <= DataByte;
				1: DataByteSet  [15:8] <= DataByte;
				default: Address <= 0;
			endcase
			
			Address <= Address + 1;
		end
    end
    
endmodule
