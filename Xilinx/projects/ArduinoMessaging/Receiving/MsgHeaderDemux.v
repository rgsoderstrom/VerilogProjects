
/*
    MsgHeaderDemux.v
	  - part of MsgRouter
	  - unpacks the message byte stream received from Arduino
*/

`timescale 1ns / 1ps

module MsgHeaderDemux (input wire Clock,
                       input wire Clear,
                   
                       // serial-to-parallel interface
	  			       input wire [7:0]  MessageByte, // received from serial->parallel
				       input wire        MessageByteReady,
				   
				       // controller inerface
					   output wire  [15:0] SyncWord,
					   output wire  [15:0] MessageID,
					   output wire  [15:0] ByteCount,
					   output wire  [15:0] SequenceNumber,
					   output reg          MessageComplete,
					   
					   // data RAM interface
					   output wire  [7:0] DataByte, // write to data RAM				   
  					   output reg         ClearDataByteAddr, // 
	  				   output reg         WriteDataByte);

localparam WaitForSyncByte1  = 0; // wait for first sync byte
localparam VerifySyncByte2   = 1; // ensure it is followed by correct 2nd byte
localparam WaitForHeaderByte = 2;
localparam GotHeaderByte     = 3;
localparam ClearDataAddr     = 4;
localparam WaitForDataByte   = 5;
localparam GotDataByte       = 6;
localparam MsgComplete       = 7;

localparam SyncByte1 = 8'h34;
localparam SyncByte2 = 8'h12;
localparam HeaderByteCount = 8;

// byte addresses
localparam SyncLowByte  = 0;
localparam SyncHighByte = 1;
localparam ByteCountLowByte  = 2;
localparam ByteCountHighByte = 3;
localparam MsgIdLowByte      = 4;
localparam MsgIdHighByte     = 5;
localparam SeqNumbLowByte    = 6;
localparam SeqNumbHighByte   = 7;

reg [4:0] state = WaitForSyncByte1;

reg [7:0] Memory [0:(HeaderByteCount - 1)]; // 8 bytes of header
reg [15:0] MsgByteCounter = 0;  // count data bytes as they are received. Used as addr reg for 
                                // first 8 bytes written in to local Memory []

// message byte passed through to data RAM. Ignored unless WriteDataByte transitions
assign DataByte = MessageByte;

// message information available to controller
assign SyncWord       = {Memory [SyncHighByte],      Memory [SyncLowByte]};
assign MessageID      = {Memory [MsgIdHighByte],     Memory [MsgIdLowByte]};
assign ByteCount      = {Memory [ByteCountHighByte], Memory [ByteCountLowByte]};
assign SequenceNumber = {Memory [SeqNumbHighByte],   Memory [SeqNumbLowByte]};

wire HeaderOnlyMsg;
assign HeaderOnlyMsg = (ByteCount == HeaderByteCount);

always @ (posedge Clock)
	begin
		if (Clear == 1'b1)
            begin
			    state <= WaitForSyncByte1;
				MsgByteCounter <= 0;
		    end
		    
		else
		begin
			case (state)            
				WaitForSyncByte1:
        			if (MessageByteReady == 1)
        			begin			
    					if (MessageByte == SyncByte1)
	   				    begin
		  				    Memory [0]     <= MessageByte;
						    MsgByteCounter <= 1;
						    state          <= VerifySyncByte2;
					    end
				    end
				    
				//***********************************************
					
				VerifySyncByte2:
        			if (MessageByteReady == 1)
        			begin			
                        if (MessageByte == SyncByte2)
                        begin
                            Memory [MsgByteCounter] <= MessageByte;
                            MsgByteCounter          <= MsgByteCounter + 1;
                            state                   <= WaitForHeaderByte;
                        end
                        else
                        begin
                            state <= WaitForSyncByte1;
                        end
                    end
                
				//***********************************************
					
				WaitForHeaderByte:
	           		if (MessageByteReady == 1)			
					begin
						Memory [MsgByteCounter] <= MessageByte;
						MsgByteCounter <= MsgByteCounter + 1;	
						state <= GotHeaderByte;					
					end

                GotHeaderByte:
						if (MsgByteCounter == HeaderByteCount) // 16'd8)
						begin
							if (HeaderOnlyMsg == 1) state <= MsgComplete;
						    else  			        state <= ClearDataAddr;
						end
						else
						begin
                            state <= WaitForHeaderByte;						
						end                
                				
                ClearDataAddr:
                        state <= WaitForDataByte;
                        
				//***********************************************
					
				WaitForDataByte:
	           		if (MessageByteReady == 1)			
	           		begin
						MsgByteCounter <= MsgByteCounter + 1;
						state <= GotDataByte;	
                    end							

                GotDataByte:
    				begin						
						if (MsgByteCounter == ByteCount)
							state <= MsgComplete;
						else
						    state <= WaitForDataByte;
					end
                					
				//***********************************************
					
				MsgComplete:
					state <= WaitForSyncByte1;
                
				//***********************************************
					
				default: 
					state <= WaitForSyncByte1;
		    endcase
		 end
	end
	
always @ (*)
	begin 
	    ClearDataByteAddr = (state == ClearDataAddr);
		WriteDataByte     = (state == GotDataByte);
		MessageComplete   = (state == MsgComplete);
	end                                                              
endmodule




