/*
    MsgSender.v - send a message out of a parallel-to-serial shift register
				- connects to a MsgHeaderGen and optionally a data RAM 
*/

`timescale 1ns / 1ps

module MsgSender  (input Clock,
                   input Clear,
                   
                   output reg   Ready, // ready to send
                   input        Send,
                   output [7:0] OutputByte, // next byte to shift out 

                   input [7:0]  HeaderByte,     // MsgHeaderGen interface                                
                   input        LastHeaderByte, 
                   input [15:0] ByteCount,
                   output reg   ClearHeaderAddr,
                   output reg   NextHeaderAddr,
                   
                   output reg   P2SLoad,       // Parallel to serial shift register
                   input        P2SEmpty,
                   
                   input [7:0]  DataByte,      // Msg data RAM interface                               
                   output reg   ClearDataAddr, 
                   output reg   RamRead);
               
    // state names			   
	localparam Idle              = 0;
	localparam BeginHeader       = 1;
	localparam SelectHeader      = 2;
	localparam SetByteCount      = 3;
	localparam WaitForP2S        = 4;
	localparam LoadHeaderByte    = 5;
	localparam CountDownHdrByte  = 6;
	localparam IsLastHdrByte     = 7;
	localparam NextHdrByte       = 8;
	localparam AreDataBytes      = 9;
	localparam ClearDataByteAddr = 10;
	localparam ReadFirstDataByte = 11;
	localparam IsP2SReady        = 12;
	localparam LoadDataByte      = 13;
	localparam CountDownDataByte = 14;
	localparam TestAllSent       = 15;
	localparam ReadNextDataByte  = 16;
					
	reg [4:0] state = Idle;
	reg [15:0] byteCountDown = 0;
	reg        muxSelect = 0; // select header byte or data byte to output

	assign OutputByte = muxSelect == 0 ? HeaderByte : DataByte;

	initial
	begin
		state = Idle;
	end

	always @ (posedge Clock)
		begin
			if (Clear == 1'b1)
				begin
					state <= Idle;
				end
				
			else
				case (state)
					Idle:              begin if (Send == 1) state <= BeginHeader; end 					
					BeginHeader:       begin state <= SelectHeader; end 					
					SelectHeader:      begin muxSelect <= 0; state <= SetByteCount; end						
					SetByteCount:      begin byteCountDown <= ByteCount; state <= WaitForP2S; end					
					WaitForP2S:        begin if (P2SEmpty == 1) state <= LoadHeaderByte; end					
					LoadHeaderByte:    begin state <= CountDownHdrByte; end					
					CountDownHdrByte:  begin byteCountDown <= byteCountDown - 1; state <= IsLastHdrByte; end
					IsLastHdrByte:     begin if (LastHeaderByte == 1) state <= AreDataBytes; else state <= NextHdrByte; end
					NextHdrByte:       begin state <= WaitForP2S; end
					AreDataBytes:      begin if (byteCountDown == 0) state <= Idle; else state <= ClearDataByteAddr; end
					ClearDataByteAddr: begin state <= ReadFirstDataByte; end
					ReadFirstDataByte: begin muxSelect <= 1; state <= IsP2SReady; end
					IsP2SReady:        begin if (P2SEmpty == 1) state <= LoadDataByte; end
					LoadDataByte:      begin state <= CountDownDataByte; end
					CountDownDataByte: begin byteCountDown <= byteCountDown - 1; state <= TestAllSent; end
					TestAllSent:       begin if (byteCountDown == 0) state <= Idle; else state <= ReadNextDataByte; end
					ReadNextDataByte:  begin state <= IsP2SReady; end
					default:           begin state <= Idle; end
			endcase
		end
		
	always @ (state)
		begin 
			Ready           = (state == Idle);
			ClearHeaderAddr = (state == BeginHeader);
			P2SLoad         = (state == LoadHeaderByte) || (state == LoadDataByte);
			NextHeaderAddr  = (state == NextHdrByte);
			ClearDataAddr   = (state == ClearDataByteAddr);
			RamRead         = (state == ReadFirstDataByte) || (state == ReadNextDataByte);			
		end
                               
                               
endmodule
