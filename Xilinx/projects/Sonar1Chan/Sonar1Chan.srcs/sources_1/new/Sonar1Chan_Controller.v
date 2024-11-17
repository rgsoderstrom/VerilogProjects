/*
	Sonar1Chan_Controller.v
*/

`timescale 1ns / 1ps

module Sonar1Chan_Controller #(parameter ClearSampleBufferID = 'd100,
                               parameter BeginSamplingID     = 'd101,
							   parameter SendSamplesID       = 'd102,
							   parameter ParametersID        = 'd103)
							 (input Clock50MHz,
						   // input Clear,
							  
							// message router
							  input InputMsgComplete,
							  input [15:0] InputMsgID,
							  
							// message senders
							  output reg SendRdyMsg,
							  output reg SendSampleMsg,
							  output reg SampleMsgPrep,

							// SonarADC1 module
							  input      ADC_Busy,
							  output reg ClearSampleBuffer,
							  output reg BeginSampling,
							  
						    // SonarDAC
							  output reg BeginPingSequence);

	localparam PowerOn       = 'd0;
	localparam SendReady     = 'd1;
	localparam Idle          = 'd2;
	localparam MsgSwitch     = 'd3;
	localparam ClearSamples  = 'd4;
	localparam Wait1         = 'd5;
	localparam Wait2         = 'd6;
	localparam Prepare       = 'd7;
	localparam BeginPing    = 'd8;
	localparam Send          = 'd9;
	
	reg [3:0] state = PowerOn;
	
	always @ (posedge Clock50MHz) begin
		case (state)
		    PowerOn:   state <= Idle;
			SendReady: state <= Idle;
			
			Idle: if (InputMsgComplete == 1) state <= MsgSwitch;
			
			MsgSwitch: case (InputMsgID)
							ClearSampleBufferID: state <= ClearSamples;
							BeginSamplingID:     state <= BeginPing;
							SendSamplesID:       state <= Send;
							ParametersID:        state <= SendReady;
							default:             state <= Idle;
					   endcase
								
			ClearSamples: state <= Wait1;
			Wait1: if (ADC_Busy == 1) state <= Wait2;
			Wait2: if (ADC_Busy == 0) state <= Prepare;
			
			Prepare: state <= SendReady;
			
			BeginPing: state <= Wait1;
			
			Send: state <= Idle;
			
			default: state <= Idle;
		endcase
	end
	
	always @ (*) begin
		SendRdyMsg    <= (state == SendReady);	
		SendSampleMsg <= (state == BeginSampling);	
		SampleMsgPrep <= (state == Prepare);
		ClearSampleBuffer <= (state == ClearSamples);	
		BeginSampling     <= (state == BeginPing); 
		BeginPingSequence <= (state == BeginPing); 
	end

endmodule