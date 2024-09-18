
/*
    Loopback_Ctrl.v - loopback controller
*/    

`timescale 1ns / 1ps

module Loopback_Ctrl #(parameter LoadDataMsgID = 16'd099,      // input data message 
                       parameter RunProcessingMsgID = 16'd101, // command to run processing
                       parameter SendDataMsgID = 16'd102)      // command to send loopback data
                      (input Clock,
                       input Clear,
					   
                       input        MessageComplete,
					   input [15:0] MessageID,
					   
                       output reg RunProcessing,
                       output reg SendReadyMsg,
                       output reg SendDataMsg,
                       output reg IncrSeqCntr,
                       input      ProcessingComplete,
                       output reg MsgMuxSelect,
                       input      RdyMsgSent,
                       input      DataMsgSent);
                       
    localparam Idle  = 0;
    localparam MsgReceived = 1;
    localparam StartProcessing = 2;
    localparam SendDataMessage = 3; // SendDataMessage states
    localparam Sdm2 = 4;
    localparam Sdm3 = 5; 
    localparam Sdm4 = 6;
    localparam ProcessingDone = 7;
    localparam Pd2 = 8;
    localparam Pd3 = 9;
    localparam Pd4 = 10;
              
    reg [3:0] state = Idle;

    initial
    begin
        RunProcessing = 0;
        SendReadyMsg = 0;
        SendDataMsg = 0;
        IncrSeqCntr = 0;
        MsgMuxSelect = 0;
    end                  
         
    always @(posedge Clock)
    begin                       
		if (Clear == 1'b1)
        begin
		    state <= Idle;
        end
		    
		else
		begin
			case (state)            
				Idle: if      (MessageComplete == 1)    state <= MsgReceived;
				      else if (ProcessingComplete == 1) state <= ProcessingDone;
					
				MsgReceived:
					  case (MessageID)
						LoadDataMsgID:      state <= Idle;
						RunProcessingMsgID: state <= StartProcessing;
						SendDataMsgID:      state <= SendDataMessage;						
					    default:            state <= Idle;
					  endcase
					  
				StartProcessing: state <= Idle;
				
				SendDataMessage: state <= Sdm2;
				Sdm2: begin MsgMuxSelect <= 0; state <= Sdm3; end
				Sdm3: state <= Sdm4;
				Sdm4: if (DataMsgSent) state <= Idle;
				
				ProcessingDone: state <= Pd2;
				Pd2: begin MsgMuxSelect <= 1; state <= Pd3; end
				Pd3: state <= Pd4;
				Pd4: if (RdyMsgSent) state <= Idle;
				
				default: state <= Idle;
			endcase
		end    
	end
					   
	always @ (*)
	begin 
	    RunProcessing = (state == StartProcessing);
		SendReadyMsg  = (state == Pd3);
		SendDataMsg   = (state == Sdm3);
		IncrSeqCntr   = (state == SendDataMessage) || (state == ProcessingDone);
	end                                                              

endmodule
