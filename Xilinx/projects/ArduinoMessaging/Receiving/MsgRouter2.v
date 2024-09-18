
/*
    MsgRouter2.v
	  - Two memory interfaces, for two different data messages
*/

`timescale 1ns / 1ps

module MsgRouter2 #(parameter ID1 = 16'd101,
                    parameter ID2 = 16'd102)
                   (input Clock,
                    input Clear,
                   
                    // serial-to-parallel interface
			 	    input [7:0]  MessageByte, // received from serial->parallel
				    input        MessageByteReady,
				   
				    // controller interface
                    output  [15:0] SyncWord,
                    output  [15:0] MessageID,
                    output  [15:0] ByteCount,
                    output  [15:0] SequenceNumber,
			        output         MessageComplete,
				   
				    // data RAM interface
				    output  [7:0] DataByte, // write to data RAM				   
					
				    output reg ClearMsg1,
				    output reg WriteMsg1, 
					
				    output reg ClearMsg2,
				    output reg WriteMsg2);

	wire ClearAddr;
	wire WriteData;
	
	MsgHeaderDemux U1 (.Clock (Clock), .Clear (Clear), 
	                   .MessageByte (MessageByte), .MessageByteReady (MessageByteReady),
                       .SyncWord (SyncWord), .MessageID (MessageID), .ByteCount (ByteCount), .SequenceNumber (SequenceNumber),
                       .MessageComplete (MessageComplete), .DataByte (DataByte),
					   .ClearDataByteAddr (ClearAddr), .WriteDataByte (WriteData));

//    assign ClearMsg1 = ClearAddr & (MessageID == ID1);
//    assign WriteMsg1 = WriteData & (MessageID == ID1);
//    assign ClearMsg2 = ClearAddr & (MessageID == ID2);
//    assign WriteMsg2 = WriteData & (MessageID == ID2);

    always @(posedge Clock)
    begin
        ClearMsg1 = ClearAddr & (MessageID == ID1);
        WriteMsg1 = WriteData & (MessageID == ID1);
        ClearMsg2 = ClearAddr & (MessageID == ID2);
        WriteMsg2 = WriteData & (MessageID == ID2);
    end
    
endmodule




