
/*
    DualPortRAM2.v 
		- 2 bytes/word		
*/

`timescale 1ns / 1ps

module DualPortRAM2 #(parameter AddrWidth = 10) 
                     (input      Clk,
					  
 					  // byte access
                      input      [7:0] ByteWriteData,
                      output reg [7:0] ByteReadData,   // ByteReadData valid 3 clocks after ByteRead asserted
                      input            ByteWrite,
                      input            ByteRead, 
                      input            ByteClearAddr,
                         
					  // word access
                      input      [15:0] WordWriteData,
                      output     [15:0] WordReadData,  // WordReadData valid 2 clocks after WordReadAsserted
                      input      [AddrWidth-1:0] WordWriteAddr,
                      input      [AddrWidth-1:0] WordReadAddr,
                      input                      WordWrite,
                      input                      WordRead);
		
    localparam DataWidth = 16;
	localparam WordCount = 1 << AddrWidth;
	
    reg  [DataWidth-1:0] Memory [0:WordCount-1];
	wire MemoryRead;
	wire MemoryWrite;
	reg  [AddrWidth : 0] ByteAddrCounter;
	
	wire IncrByteAddr;
	wire LoadByte;
	wire LoadReadByteMux;
	wire WordMuxSel;
	wire [1:0] AddrMuxSel;
	
	reg  [AddrWidth-1:0] MemoryAddr; 
	reg  [DataWidth-1:0] WordIn;
	reg  [DataWidth-1:0] WordOut;
	reg  [DataWidth-1:0] WordFromBytes;
	
	assign WordReadData = WordOut;

	// Initializations
	initial
    begin
        ByteAddrCounter <= 0;
        WordOut <= 0;
    end

	// Byte Address Counter
    always @ (posedge Clk) begin
        if      (ByteClearAddr == 1) ByteAddrCounter <= 0;
        else if (IncrByteAddr == 1)  ByteAddrCounter <= ByteAddrCounter + 1;
    end
	
	//********************************************************************
	
	// Addr Mux
    always @ (*) begin
		case (AddrMuxSel)
			2'b00: MemoryAddr = ByteAddrCounter [AddrWidth:1];
			2'b01: MemoryAddr = WordReadAddr;
			2'b10: MemoryAddr = WordWriteAddr;
			default: MemoryAddr = 0;
		endcase
	end
	
	//********************************************************************

	// ReadByte Mux
    always @ (posedge Clk) begin
        if (LoadReadByteMux == 1)
        begin
            case (ByteAddrCounter [0])
                1'b0: ByteReadData <= WordOut [7:0];
                1'b1: ByteReadData <= WordOut [15:8];
                default: ByteReadData <= 0;
            endcase
		end
	end
	
	//********************************************************************

	// Word Mux
	
    always @ (*) begin
		case (WordMuxSel)
			1'b0: WordIn = WordFromBytes;
			1'b1: WordIn = WordWriteData;
			default: WordIn = 0;
		endcase
	end
	
	//********************************************************************

	// Word from bytes register
    always @ (posedge Clk) begin
	    if (LoadByte == 1) begin				
			case (ByteAddrCounter [0])
				1'b0: WordFromBytes [7:0]  <= ByteWriteData;
				1'b1: WordFromBytes [15:8] <= ByteWriteData;
				default: WordFromBytes <= 0;
			endcase
		end
	end
	
	//********************************************************************

	// Memory
    always @ (posedge Clk) begin
		if (MemoryRead  == 1) WordOut <= Memory [MemoryAddr];
		if (MemoryWrite == 1) Memory [MemoryAddr] <= WordIn;
	end
	
	//********************************************************************
	
    DPRAM_Controller U1 (.Clk (Clk),
					     .ByteWrite (ByteWrite),
                         .ByteRead  (ByteRead),
                         .WordWrite (WordWrite),                         
                         .WordRead  (WordRead),
						 .IncrByteAddr    (IncrByteAddr),
						 .WordMuxSel      (WordMuxSel),
						 .AddrMuxSel      (AddrMuxSel),
						 .LoadByte        (LoadByte),
						 .LoadReadByteMux (LoadReadByteMux),
						 .MemWrite        (MemoryWrite),
						 .MemRead         (MemoryRead));	
endmodule



