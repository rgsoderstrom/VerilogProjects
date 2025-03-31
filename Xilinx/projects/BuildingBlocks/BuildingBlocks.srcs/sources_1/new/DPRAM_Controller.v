/*
	DPRAM_Controller
		- part of all DualPortRAMx.v
*/

`timescale 1ns / 1ps

module DPRAM_Controller (input  wire    Clk,
						 input  wire    ByteWrite,
                         input  wire    ByteRead,
                         input  wire    WordWrite,                         
                         input  wire    WordRead,
						 output reg IncrByteAddr,
						 output reg WordMuxSel,
						 output reg [1:0] AddrMuxSel,
						 output reg LoadReadByteMux,
						 output reg LoadByte,
						 output reg MemWrite,
						 output reg MemRead);

    // states
    localparam Idle = 4'b0;

    localparam BW1 = 4'h1; // byte write
    localparam BW2 = 4'h2;
    
    localparam BR1 = 4'h3; // byte read
    localparam BR2 = 4'h4;
    localparam BR3 = 4'h5;
    
    localparam WW  = 4'h6; // word write
    localparam WR  = 4'h7; // word read
                
    reg [3:0] State = Idle;
    
    initial begin
        WordMuxSel = 0;
        AddrMuxSel = 2'b0;
    end    
    
    always @(posedge Clk) begin
        case (State)
			Idle: begin
				    if (ByteWrite == 1) begin
                       AddrMuxSel <= 2'b0;
					   WordMuxSel <= 0;
					   State <= BW1;
					end
					
					else if (ByteRead == 1) begin
                       AddrMuxSel <= 2'b0;
					   WordMuxSel <= 0;
					   State <= BR1;
					end
					
					else if (WordWrite == 1) begin
                        AddrMuxSel <= 2'd2;
                        WordMuxSel <= 1;
                        State <= WW;
		 	       end
					
					else if (WordRead == 1) begin 
                        AddrMuxSel <= 2'd1;
                        State <= WR;
				    end					
				  end
			
			//********************************************
			
			BW1: State <= BW2;
			BW2: State <= Idle;
			
			BR1: State <= BR2;
			BR2: State <= BR3;
			BR3: State <= Idle;
			
			WR: State <= Idle;
			WW: State <= Idle;
				  
			default: State <= Idle;        
        endcase    
    end

    always @(*) begin
		IncrByteAddr    <= (State == BR3) || (State == BW2);
		LoadByte        <= (State == BW1);
		LoadReadByteMux <= (State == BR2);
		MemWrite        <= (State == WW) || (State == BW2);
		MemRead         <= (State == WR) || (State == BR1);    
    end    
endmodule
