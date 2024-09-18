/*
    DualPortRAM.v 
        - byte reads and writes for message data IO
        - Word (1,2 or 4 bytes) reads and writes for processing
			
		- Byte read/write
		    - sequential access
    			- address counter starts at 0
	       		- increment once per read or write
			       - incr on write is automatic, for read incr must be commanded
	
		- Word read/write
			- random access

        - parameters    
			- L2Width = log2 (number of bytes per word)
                = 0 for  8 bit words
                = 1 for 16 bit words
                = 2 for 32 bit words
            - L2Depth = log2 (number of words stored)
			    = 5 for 32 words
				= 10 for 1024 words
*/

`timescale 1ns / 1ps

module DualPortRAM #(parameter L2Width = 1, // see above
                     parameter L2Depth = 5) // see above 
                    (input Clk,
                         
					 // byte access
                     input      [7:0] ByteWriteData,
                     input            ByteWriteCycle, // writes data and then incr byte address
                         
                     output     [7:0] ByteReadData, // always Memory [ByteAddr]
                     input            IncrByteAddr, // only use for "byte read". Writes incr automatically
                         
					 input            ClearByteAddr, // common to read & write
				     output           LastAddr,      // true when readiing or writing last byte
						 
					 // word access
                     input      [8 * (1 << L2Width)-1:0] WordWriteData,
                     input                               WordWriteCycle,
                     input      [L2Depth-1:0]            WordWriteAddr,
                         
                     output     [8 * (1 << L2Width)-1:0] WordReadData, // always Memory [WordAddr]
                     input      [L2Depth-1:0]            WordReadAddr);
						                     
	localparam Width = 1 << L2Width; // number of bytes per word
	localparam Depth = 1 << L2Depth; // number of words stored
    localparam ByteCount = Width * Depth; // number of bytes stored  
	
    reg [(8 * Width)-1:0] Memory [0:Depth-1];

	reg [(L2Depth + L2Width) - 1 : 0] ByteAddrCounter;
    assign LastAddr = ByteAddrCounter == Depth * Width - 1;
                     
    wire [L2Depth - 1 : 0] ByteAccessWord = ByteAddrCounter >> L2Width;
    wire [1:0]             ByteAccessByte = ByteAddrCounter & (Width - 1);

    assign ByteReadData = Memory [ByteAccessWord][(8 * (ByteAccessByte + 1) - 1) -: 8];
    assign WordReadData = Memory [WordReadAddr];

	initial
    begin
        ByteAddrCounter <= 0;
    end
    
    always @ (posedge Clk)
      begin
        if (ClearByteAddr == 1'b1)
        begin
            ByteAddrCounter <= 0;
        end

        else if (WordWriteCycle == 1'b1)
        begin
           Memory [WordWriteAddr] <= WordWriteData;
        end
      
        else if (IncrByteAddr == 1'b1)
        begin
			ByteAddrCounter <= ByteAddrCounter + 1;
        end

        else if (ByteWriteCycle == 1'b1)
        begin
		    Memory [ByteAccessWord][(8 * (ByteAccessByte + 1) - 1) -: 8] <= ByteWriteData;
			ByteAddrCounter <= ByteAddrCounter + 1;
        end		
      end
endmodule



