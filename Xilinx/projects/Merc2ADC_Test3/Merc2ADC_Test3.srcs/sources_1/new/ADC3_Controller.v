/*
    ADC3_Controller - Merc2ADC_Test3 Controller
*/

`timescale 1ns / 1ps

module ADC3_Controller #(parameter ClearSamplesID  = 16'd150,
                         parameter BeginSamplingID = 16'd251,
                         parameter SendSamplesID   = 16'd151,
                         parameter SetGainID       = 16'd252,      
                         parameter SetSampleRateID = 16'd253)
                       (input Clock,        
				        input Clear,

                        input [15:0] RcvdMsgID,
                        input        RcvdMsgComplete,
						
						input [15:0] SampleClockDivisor, 
                        				        
                        input ADC_Valid,
                        input SampleWriteAddrWrapped,
                        
                        output reg SendReadyMsg,    // to message generators
                        output reg SendSamplesMsg,
                        
                        output reg ADC_Trigger,
                        output reg ClearWriteAddr,
                        output reg ClearReadAddr,
                        output reg IncrWriteAddr,
                        output reg SampleWrite,
                        output reg DataMuxSel,
                        output reg DAC_Trigger,
                        output reg [1:0] OutputMsgSelect,
						output reg       IncrSeqCntr);

    localparam Start     = 'd0;
    localparam SendReady = 'd2;
    localparam Idle      = 'd4;
    
    localparam Init1           = 'd6;
    localparam Init1A          = 'd7;
    localparam Write1          = 'd8;
    localparam Write1A         = 'd9;
    localparam NextWriteAddr1  = 'd10;
    localparam NextWriteAddr1A = 'd11;    
    localparam TestWriteAddr1  = 'd12;
    localparam TestWriteAddr1A = 'd13;
              
    localparam Init2           = 'd14;
    localparam Init2A          = 'd15;
    localparam TestADC21       = 'd16;
    localparam TestADC21A      = 'd17;
    localparam TestADC22       = 'd18;
    localparam TestADC22A      = 'd19;
    localparam Write2          = 'd20;
    localparam Write2A         = 'd21;
    localparam NextWriteAddr2  = 'd22;
    localparam NextWriteAddr2A = 'd23;   
    localparam TestWriteAddr2  = 'd24;
    localparam TestWriteAddr2A = 'd25;
    localparam SamplingOff2    = 'd26;
    localparam SamplingOff2A   = 'd27;
    
    localparam SendSampleMsg3  = 'd28;
	
    localparam SetSampleRate1 = 'd29;
    localparam SetSampleRate2 = 'd30;
    localparam SetGain1       = 'd31;
    localparam SetGain2       = 'd32;
    
    initial begin
        OutputMsgSelect <= 2'b00;
    end
    
    wire ClearSampleBuffer = (RcvdMsgID == ClearSamplesID)  && (RcvdMsgComplete == 1);
    wire BeginSampling     = (RcvdMsgID == BeginSamplingID) && (RcvdMsgComplete == 1);
    wire SendSamples       = (RcvdMsgID == SendSamplesID)   && (RcvdMsgComplete == 1);
    wire SetGain           = (RcvdMsgID == SetGainID)       && (RcvdMsgComplete == 1);
    wire SetSampleRate     = (RcvdMsgID == SetSampleRateID) && (RcvdMsgComplete == 1);
	
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
		
	always @ (*)
		ADC_Trigger <= (SampleClock == 1 && ADC_Enable == 1);
		
	//*************************************************************************
	//
	// State Machine
	//
	reg [5:0] state = Start;
	reg [11:0] delayCounter;
    
	always @ (posedge Clock) begin
		if (Clear == 1)
			state <= Start;
			
		else begin
			case (state)		
				Start:     begin state <= SendReady; end 
				SendReady: begin OutputMsgSelect <= 0; state <= Idle; end 
				
				Idle: if (ClearSampleBuffer  == 1) state <= Init1;
					  else if (BeginSampling == 1) state <= Init2;
					  else if (SendSamples   == 1) state <= SendSampleMsg3;
					  else if (SetGain       == 1) state <= SetGain1;
					  else if (SetSampleRate == 1) state <= SetSampleRate1;
				
				//
				// ClearSampleBuffer
				//
				Init1: begin DataMuxSel <= 0; state <= Write1; end
				
				Write1:  state <= Write1A;
				Write1A: state <= NextWriteAddr1;

				NextWriteAddr1:  state <= NextWriteAddr1A;
				NextWriteAddr1A: state <= TestWriteAddr1;
				
				TestWriteAddr1: if (SampleWriteAddrWrapped == 1) state <= SendReady; 
				                else state <= Write1;

				
				//
				// Collect Samples
				//
				Init2: begin ADC_Enable <= 1; DataMuxSel <= 1; state <= TestADC21; end						   					 

				TestADC21: if (ADC_Valid == 0) state <= TestADC22;
				TestADC22: if (ADC_Valid == 1) state <= Write2;
				
  				Write2:    state <= Write2A;
  				Write2A:   state <= NextWriteAddr2;

				NextWriteAddr2:  state <= NextWriteAddr2A;
				NextWriteAddr2A: state <= TestWriteAddr2;

				TestWriteAddr2: if (SampleWriteAddrWrapped == 1) state <= SamplingOff2; else state <= TestADC21;
				SamplingOff2:   begin ADC_Enable <= 0; state <= SendReady; end
								
				//
				// Send Samples
				//
				SendSampleMsg3:  begin OutputMsgSelect <= 2'h1; state <= Idle; end
				
				//
				// Set Gain
				//
				SetGain1: begin /*dacMuxSel <= 1;*/ state <= SetGain2; end
				SetGain2: state <= Idle;
				
				//
				// Set sample rate
				//
				SetSampleRate1: state <= Idle;
				
			endcase
		end
	end
	
	always @ (*) begin
		DAC_Trigger        <= (state == Start)  || (state == SetGain2);		
		ClearWriteAddr     <= (state == Init1)  || (state == Init2);
		ClearReadAddr      <= (state == Init1)  || (state == Init2);		
		SampleWrite        <= (state == Write1) || (state == Write2);		
		IncrWriteAddr      <= (state == NextWriteAddr1) || (state == NextWriteAddr2);
				
		SendSamplesMsg     <= (state == SendSampleMsg3);
		SendReadyMsg       <= (state == SendReady);
		
		IncrSeqCntr <= SendReadyMsg || (state == SendSampleMsg3);
	end
	
endmodule




