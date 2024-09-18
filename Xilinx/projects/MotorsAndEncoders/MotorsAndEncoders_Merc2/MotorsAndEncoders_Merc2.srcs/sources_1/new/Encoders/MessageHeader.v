
//
// MessageHeader
//   - Header block for one message type
//

`timescale 1ns / 1ps

module MessageHeader #(parameter DataWidth = 8,                        
                       parameter MsgID = 1,
                       parameter ByteCount = 0)
                      (output [DataWidth-1:0] DataOut,
                        
                       output Empty, // false after NewHeader
					              // true when all header bytes have been read
                        
                       input  ReadNext,
                       input  NewHeader,
                        
                       input  Clear,
                       input  Clock);                

    localparam SyncByte  = 8'hab;

    localparam SyncByteIndex  = 0;
    localparam MsgIdIndex     = 1;
    localparam ByteCountIndex = 2;
    localparam SequenceIndex  = 3;
    localparam HeaderSize     = 4;

    reg [DataWidth-1:0] headerStore [0:HeaderSize-1];
    reg [DataWidth-1:0] Sequence = 1;                            
    
    reg [2:0] WriteAddr = 0;
    reg [2:0] ReadAddr  = 0;
    
    assign Empty   = (WriteAddr == ReadAddr);
    assign DataOut = headerStore [ReadAddr];

    always @ (posedge Clock)
        if (Clear == 1'b1)
            begin
                Sequence  <= 1;
                ReadAddr  <= 0;
                WriteAddr <= 0;
            end

        else if (NewHeader == 1'b1)
            begin
                Sequence <= Sequence + 1;
                headerStore [SyncByteIndex]  <= SyncByte;
                headerStore [MsgIdIndex]     <= MsgID;
                headerStore [ByteCountIndex] <= ByteCount;
                headerStore [SequenceIndex]  <= Sequence;
                ReadAddr  <= 0;
                WriteAddr <= HeaderSize;
            end

        else if (ReadNext == 1'b1)
            begin
                ReadAddr <= ReadAddr + 1;
            end                                                                 
endmodule
