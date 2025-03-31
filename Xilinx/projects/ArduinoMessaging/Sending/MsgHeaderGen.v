
/*
	MsgHeaderGen.v - build the header part of a message that also contains data
*/

`timescale 1ns / 1ps

module MsgHeaderGen #(parameter ID = 16'h1, 
                      parameter ByteCount = 16'h8) 
			         (input wire Clk,
                      input wire ClearAddr,
                      input wire NextAddr,
                      input wire  [15:0] SequenceNumber, // typically counts up for each msg sent
                      output reg  [15:0] MsgByteCount,   // for entire message, header & data
                      output wire        LastReadByte,   // AddrCounter == LastAddress
                      output wire [7:0]  HeaderByte);    // Memory [AddrCounter]
					  
    reg [7:0] Memory [0:7];
	reg [2:0] AddrCounter = 0;

	assign LastReadByte = (AddrCounter == 7);
	assign HeaderByte   = Memory [AddrCounter];
	
	initial
	begin
		Memory [0] <= 8'h34;   // sync word
		Memory [1] <= 8'h12;   
		Memory [2] <= ByteCount [7:0];  // byte count
		Memory [3] <= ByteCount [15:8];
		Memory [4] <= ID [7:0]; // message ID
		Memory [5] <= ID [15:8];
		Memory [6] <= 0; //InitialSeqNumb [7:0];   // sequence number
		Memory [7] <= 0; //InitialSeqNumb [15:8];
		MsgByteCount <= ByteCount;
	end
	
    always @ (posedge Clk)
    begin
      if (ClearAddr == 1'b1)
      begin			
        AddrCounter <= 0;
		Memory [6] <= SequenceNumber [7:0];
		Memory [7] <= SequenceNumber [15:8];
      end
        
      else if (NextAddr == 1'b1)
      begin
        AddrCounter <= AddrCounter + 1'b1;
      end
	end
endmodule
					  
