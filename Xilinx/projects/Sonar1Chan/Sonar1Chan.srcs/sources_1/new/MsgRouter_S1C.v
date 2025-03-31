
/*
    MsgRouter_S1C.v
	  - Message router for Sonar1Chan.
*/

`timescale 1ns / 1ps

module MsgRouter_S1C #(parameter ID1 = 16'd101,
                       parameter ID2 = 16'd102,
                       parameter ID3 = 16'd103,
                       parameter ID4 = 16'd104,
                       parameter ID5 = 16'd105,
                       parameter ID6 = 16'd106,
                       parameter ID7 = 16'd107)
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
				     output reg WriteMsg2,
					
				     output reg ClearMsg3,
				     output reg WriteMsg3,
					
				     output reg ClearMsg4,
				     output reg WriteMsg4,
					
				     output reg ClearMsg5,
				     output reg WriteMsg5,
					
				     output reg ClearMsg6,
				     output reg WriteMsg6,
					
				     output reg ClearMsg7,
				     output reg WriteMsg7);

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
        ClearMsg3 = ClearAddr & (MessageID == ID3);
        WriteMsg3 = WriteData & (MessageID == ID3);
        ClearMsg4 = ClearAddr & (MessageID == ID4);
        WriteMsg4 = WriteData & (MessageID == ID4);
        ClearMsg5 = ClearAddr & (MessageID == ID5);
        WriteMsg5 = WriteData & (MessageID == ID5);
        ClearMsg6 = ClearAddr & (MessageID == ID6);
        WriteMsg6 = WriteData & (MessageID == ID6);
        ClearMsg7 = ClearAddr & (MessageID == ID7);
        WriteMsg7 = WriteData & (MessageID == ID7);
    end    
endmodule




