/*
    MessageReader 
		- assembles stream of bytes in to a message
		- signals MessageComplete when enough bytes stored	
        - linear buffer for a single message
*/

`timescale 1ns / 1ps

module MessageReader #(parameter AddrWidth = 6)
                      (input  [7:0] Input,    // inputs hard coded to 8-bit bytes
                       input        Write,

                       output  reg             MessageComplete,
                       output  [AddrWidth-1:0] ByteCount,
                       output  [7:0]           MessageID,
                       output  [7:0]           MessageWord, // == Storage [ReadAddr]
                      
                       input [AddrWidth-1:0] ReadAddr,
                      
                       input Clock,
                       input Clear);


    localparam Sync = 8'hAB;
    localparam IdAddr = 1;
    localparam ByteCountAddr = 2;
    localparam HeaderSize = 3;
                      
    localparam Depth = 1 << AddrWidth; 
    reg [7:0] Storage [0:Depth-1];
    
    reg [AddrWidth-1:0] WriteAddr;  
    integer i;

    reg [3:0] state = 0;
    
	initial
	begin
        state = 0;
        WriteAddr = 0;
                        
        for (i=0; i<Depth; i=i+1)
            Storage [i] <= 0;
    end
        
    assign MessageID   = Storage [IdAddr],        // may be invalid if (MessageComplete == false)
           MessageWord = Storage [ReadAddr],      // ditto
           ByteCount   = Storage [ByteCountAddr]; // ditto
                      
    always @ (posedge Clock)
        if (Clear == 1'b1)
            begin
                state <= 0;
                WriteAddr <= 0;
                
                for (i=0; i<Depth; i=i+1)
                    Storage [i] <= 0;
            end
            
        else
            case (state)
                0: if ((Write == 1) && (Input == Sync)) begin Storage [0] <= Input; WriteAddr <= 1; state <= 1; end
                1: if  (Write == 1) begin Storage [WriteAddr] <= Input; WriteAddr <= WriteAddr + 1; state <= 2; end
                2: if ((WriteAddr >= HeaderSize) && (WriteAddr == ByteCount)) state <= 3; else state <= 1;
                3: state <= 0;
                
                default: state <= 0;
            endcase

    //************************************************************************
            
    always @ (*)
        begin
            MessageComplete <= (state == 3);
        end

endmodule



