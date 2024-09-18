/*
    ProfileLoader
*/    

`timescale 1ns / 1ps

module ProfileLoader (input       LoadProfile,
                      input [7:0] MessageByte,
                      input [5:0] MsgByteCount,
                       
                      output reg [5:0] ReadAddr, // was 4:0
                      output reg [7:0] Speed,  // actually velocity, 2's complement
                      output reg [7:0] Duration,
                      output reg       Load1,
                      output reg       Load2,
                      
                      input Clear,
                      input Clock);
    
    localparam firstDataAddr = 3;
        
    reg [3:0] state = 0;
            
	initial
	begin
        state = 0;
    end
        
    always @ (posedge Clock)
        if (Clear == 1'b1)
            begin
                state <= 0;
            end
                        
        else case (state)  
            0: if (LoadProfile == 1) begin state <= 1; ReadAddr <= firstDataAddr; end
            
            1: begin Speed <= MessageByte; ReadAddr <= ReadAddr + 1; state <= 2; end 

            2: begin Duration <= MessageByte; ReadAddr <= ReadAddr + 1; state <= 3; end 

            3: state <= 4;
            
            4: begin Speed <= MessageByte; ReadAddr <= ReadAddr + 1; state <= 5; end 

            5: begin Duration <= MessageByte; ReadAddr <= ReadAddr + 1; state <= 6; end 

            6: state <= 7;
            
            7: if (ReadAddr < MsgByteCount) state <= 1; else state <= 0;             
        endcase
    
    always @ (*)
        begin
            Load1 = (state == 3);
            Load2 = (state == 6);        
        end
    
endmodule
