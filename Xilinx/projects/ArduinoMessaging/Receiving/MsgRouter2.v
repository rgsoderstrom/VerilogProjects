
/*
    MsgRouter2.v
	  - Two memory interfaces, for two different data messages
*/

`timescale 1ns / 1ps

module MsgRouter2 #(parameter ID1 = 16'd101,
                    parameter ID2 = 16'd102)
                   (input wire Clock,
                    input wire Clear,
                   
                    // serial-to-parallel interface
			 	    input wire [7:0]  MessageByte, // received from serial->parallel
				    input wire        MessageByteReady,
				   
				    // controller interface
                    output wire  [15:0] SyncWord,
                    output wire  [15:0] MessageID,
                    output wire  [15:0] ByteCount,
                    output wire  [15:0] SequenceNumber,
			        output wire         MessageComplete,
				   
				    // data RAM interface
				    output wire  [7:0] DataByte, // write to data RAM				   
					
				    output reg ClearMsg1,
				    output reg WriteMsg1, 
				    output reg Msg1Complete, 
					
				    output reg ClearMsg2,
				    output reg WriteMsg2,
					output reg Msg2Complete);

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
        ClearMsg1    <= ClearAddr       & (MessageID == ID1);
        WriteMsg1    <= WriteData       & (MessageID == ID1);
		Msg1Complete <= MessageComplete & (MessageID == ID1);
		
        ClearMsg2    <= ClearAddr       & (MessageID == ID2);
        WriteMsg2    <= WriteData       & (MessageID == ID2);
		Msg2Complete <= MessageComplete & (MessageID == ID2);
    end
    
endmodule




