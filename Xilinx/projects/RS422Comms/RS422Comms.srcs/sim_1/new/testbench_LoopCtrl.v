
/*
    testbench_LoopCtrl
*/    

`timescale 1ns / 1ps

module testbench_LoopCtrl;

    localparam LoadDataMsgID = 16'd123;
    localparam RunProcMsgID  = 16'd456;
    localparam SendDataMsgID = 16'd789;
    
    reg  Clock = 0;
	reg  Clear = 0;
	
	reg MessageComplete = 0;
	wire SMessageComplete;	
	reg [15:0] MsgID = SendDataMsgID;

    reg ProcessingComplete = 0;
    wire SProcessingComplete;
    
    reg  DataMsgSent = 0;
    wire SDataMsgSent;
    reg  RdyMsgSent = 0;
    wire SRdyMsgSent;

    wire RunProcessing;
    wire SendReadyMsg;
    wire SendDataMsg;
    wire IncrSeqCntr;
    wire MsgMuxSelect;

    
    Loopback_Ctrl #(.LoadDataMsgID (LoadDataMsgID), .RunProcessingMsgID (RunProcMsgID), .SendDataMsgID (SendDataMsgID))
                U1 (.Clock (Clock),
                    .Clear (Clear),
					.MessageComplete (SMessageComplete),
					.MessageID (MsgID),
					.RunProcessing (RunProcessing),
                    .SendReadyMsg (SendRdyMsg),
                    .SendDataMsg (SendDataMsg),
                    .IncrSeqCntr (IncrSeqCntr),
                    .ProcessingComplete (SProcessingComplete),
                    .MsgMuxSelect (MsgMuxSelect),
                    .RdyMsgSent (SRdyMsgSent),
                    .DataMsgSent (SDataMsgSent));

	SyncOneShot U2 (.trigger (MessageComplete), .clk (Clock), .clr (Clear), .Q (SMessageComplete)),
	            U3 (.trigger (ProcessingComplete), .clk (Clock), .clr (Clear), .Q (SProcessingComplete)),
	            U4 (.trigger (DataMsgSent), .clk (Clock), .clr (Clear), .Q (SDataMsgSent)),
	            U5 (.trigger (RdyMsgSent), .clk (Clock), .clr (Clear), .Q (SRdyMsgSent));
	
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
    //    $monitor ($time, " state %d, msgByte 0x%h, WriteByte %h", U1.state, U1.MessageByte, U1.WriteDataByte);
                            
            Clear = 1;
        #50 Clear = 0;
    end

    //
    // clock period
    //
    always
        #5 Clock = ~Clock;  
        
    //
    // test run
    //

    initial
    begin
//      #123 MessageComplete = 1;
//	    #30  MessageComplete = 0;	
//      #200 DataMsgSent = 1;
//	    #30  DataMsgSent = 0;
	
        #123 ProcessingComplete = 1;
	    #30  ProcessingComplete = 0;
	    #200 RdyMsgSent = 1;
	    #30  RdyMsgSent = 0;
	
    //	#500 $finish;
	end
endmodule
