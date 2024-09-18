/*
    ADC3_Controller - Merc2ADC_Test3 Controller
*/

`timescale 1ns / 1ps

module ADC3_Controller #(parameter ClockFreq = 50_000_000, 
                         parameter Fs = 19150) // sampling frequency
                       (input Clock,        
				        input Clear,

                        input [15:0] RcvdMsgID,
                        input        RcvdMsgComplete,
						
						input [15:0] SampleClockDivisor,  //***********************************
						output reg   dacMuxSel,
                        				        
                        input ADC_Valid,
                        input AllSamplesSent,
                        input SampleMsgSent,
                        input WordAddrMax,
                        
                        output reg SendReadyMsg,    // to message generators
                        output reg SendSamplesMsg,
                        output reg SendAllSentMsg,
                        
                        output reg ADC_Trigger,
                        output reg ClearWriteAddr,
                        output reg IncrWriteAddr,
                        output reg WordWrite,
                        output reg DataMuxSel,
                        output reg DAC_Trigger,
                        output reg ByteAddrClear,
                        output reg ClearSampleMsgCntr,
                        output reg [1:0] OutputMsgSelect,
						output reg       IncrSeqCntr);

    localparam Start = 5'd0;
    localparam Idle  = 5'd1;
    
    localparam Init1  = 5'd2;
    localparam Write1 = 5'd3;
    localparam Delay1 = 5'd4;
    localparam TestWriteAddr1 = 5'd5;
    localparam SendReadyMsg1  = 5'd6;
    localparam NextWriteAddr1 = 5'd7;
   
    localparam Init2     = 5'd8;
    localparam TestADC21 = 5'd9;
    localparam TestADC22 = 5'd10;
    localparam Write2    = 5'd11;
    localparam Delay2    = 5'd12;
    localparam TestWriteAddr2 = 5'd13;
    localparam SamplingOff2   = 5'd14;
    localparam SendReadyMsg2  = 5'd15;
    localparam NextWriteAddr2 = 5'd16;
    
    localparam SendSampleMsg3  = 5'd17;
    localparam WaitForMsgSent3 = 5'd18;
    localparam TestAllSent3    = 5'd19;
    localparam SendAllSentMsg3 = 5'd20;
	
    localparam SetSampleRate1 = 5'd21;
    localparam SetSampleRate2 = 5'd22;
    localparam SetGain1       = 5'd23;
    localparam SetGain2       = 5'd24;
    
    initial begin
        OutputMsgSelect <= 2'b00;
		dacMuxSel <= 0;
    end
    
    wire ClearSampleBuffer = (RcvdMsgID == 16'd100) && (RcvdMsgComplete == 1);
    wire BeginSampling     = (RcvdMsgID == 16'd101) && (RcvdMsgComplete == 1);
    wire SendSamples       = (RcvdMsgID == 16'd102) && (RcvdMsgComplete == 1);
    wire SetGain           = (RcvdMsgID == 16'd103) && (RcvdMsgComplete == 1);
    wire SetSampleRate     = (RcvdMsgID == 16'd104) && (RcvdMsgComplete == 1);
    
	//*************************************************************************
	//
	// SampleClockGenerator - generate pulses at sampling freq Fs
	//
	reg  SampleClock;	
	reg  ADC_Enable = 0;
	
	reg [15:0] SampleClockCounter = 0;
	
	always @ (posedge Clock) begin
		if (SampleClockCounter == SampleClockDivisor)
			SampleClockCounter <= 0;
		else
			SampleClockCounter <= SampleClockCounter + 1;
	end

	always @ (*)
		SampleClock = (SampleClockCounter == SampleClockDivisor);
		
//    ClockDivider #(.Divisor (ClockFreq / Fs))
// 			   U1 (.FastClock (Clock), .Clear (Clear), .SlowClock (), .Pulse (SampleClock)); 



	always @ (*)
		ADC_Trigger <= (SampleClock == 1 && ADC_Enable == 1);
		
	//*************************************************************************
	//
	// State Machine
	//
	reg [4:0] state = Start;
	reg [11:0] delayCounter;
    
	always @ (posedge Clock) begin
		if (Clear == 1)
			state <= Start;
			
		else begin
			case (state)		
				Start: begin state <= Idle; end // loads desired const into DAC
				
				Idle: if (ClearSampleBuffer  == 1) state <= Init1;
					  else if (BeginSampling == 1) state <= Init2;
					  else if (SendSamples   == 1) state <= SendSampleMsg3;
					  else if (SetGain       == 1) state <= SetGain1;
					  else if (SetSampleRate == 1) state <= SetSampleRate1;
				
				//
				// ClearSampleBuffer
				//
				Init1: begin DataMuxSel <= 0; state <= Write1; end
				
				Write1: state <= Delay1;
				Delay1: state <= TestWriteAddr1;
				TestWriteAddr1: if (WordAddrMax == 1) state <= SendReadyMsg1; else state <= NextWriteAddr1;
				SendReadyMsg1:  begin OutputMsgSelect <= 2'h0; state <= Idle; end
				NextWriteAddr1: state <= Write1;
				
				//
				// Take Samples
				//
				Init2: begin 
				           ADC_Enable <= 1; 
						   DataMuxSel <= 1; 
						   state <= TestADC21; 
					   end						   					 

				TestADC21: if (ADC_Valid == 0) state <= TestADC22;
				TestADC22: if (ADC_Valid == 1) state <= Write2;

				
				Write2: state <= Delay2;
				Delay2: state <= TestWriteAddr2;
				TestWriteAddr2: if (WordAddrMax == 1) state <= SamplingOff2; else state <= NextWriteAddr2;
				NextWriteAddr2: state <= TestADC21;
				SamplingOff2:   begin ADC_Enable <= 0; state <= SendReadyMsg2; end
				SendReadyMsg2:  begin OutputMsgSelect <= 2'h0; state <= Idle; end
								
				//
				// Send Samples
				//
				SendSampleMsg3:  begin OutputMsgSelect <= 2'h1; state <= WaitForMsgSent3; end
				WaitForMsgSent3: if (SampleMsgSent == 1) state <= TestAllSent3;
				TestAllSent3:    if (AllSamplesSent == 1) state <= SendAllSentMsg3; else state <= Idle;
				SendAllSentMsg3: begin OutputMsgSelect <= 2'h2; state <= Idle; end
				
				//
				// Set Gain
				//
				SetGain1: begin dacMuxSel <= 1; state <= SetGain2; end
				SetGain2: state <= Idle;
				
				//
				// Set sample rate
				//
				SetSampleRate1: state <= Idle;
				
			endcase
		end
	end
	
	always @ (*) begin
		//LoadDivisor        <= (state == SetSampleRate1);
		DAC_Trigger        <= (state == Start)  || (state == SetGain2);
		ClearWriteAddr     <= (state == Init1)  || (state == Init2);
		ByteAddrClear      <= (state == Init1)  || (state == Init2);
		ClearSampleMsgCntr <= (state == Init1)  || (state == Init2);
		WordWrite          <= (state == Write1) || (state == Write2);
		IncrWriteAddr      <= (state == NextWriteAddr1) || (state == NextWriteAddr2);
		SendSamplesMsg     <= (state == SendSampleMsg3);
		SendAllSentMsg     <= (state == SendAllSentMsg3);

		SendReadyMsg       <= (state == Start) || (state == SendReadyMsg1)  || (state == SendReadyMsg2);
		
		IncrSeqCntr <= SendReadyMsg || SendSamplesMsg || SendAllSentMsg;
	end
	
endmodule




