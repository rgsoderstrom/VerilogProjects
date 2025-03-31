/*
    SonarADC1_Controller.v
*/

`timescale 1ns / 1ps

module SonarADC1_Controller (input wire Clock50MHz,        
				             input wire Clear,

    						 input wire [15:0] SampleClockDivisor,
       
                             input  wire ADC_Valid,
                             output reg  ADC_Trigger,
                        
							 input wire      SampleWriteAddrWrapped,
							 input wire      ClearSampleBuffer,
							 input wire      BeginSampling,
							 
							 output reg Busy,
							 
                             output reg ClearWriteAddr,
                             output reg IncrWriteAddr,
                             output reg SampleWrite,
                             output reg DataMuxSel);
                             
    localparam Start     = 'd0;
    localparam Idle      = 'd1;
    
    localparam Init1           = 'd2;
    localparam Write1          = 'd3;
    localparam Write1A         = 'd4;
    localparam NextWriteAddr1  = 'd5;
    localparam NextWriteAddr1A = 'd6;    
    localparam TestWriteAddr1  = 'd7;
    localparam ClearBusy       = 'd8;
              
    localparam Init2           = 'd9;
    localparam TestADC21       = 'd10;
    localparam TestADC22       = 'd11;
    localparam Write2          = 'd12;
    localparam Write2A         = 'd13;
    localparam NextWriteAddr2  = 'd14;
    localparam NextWriteAddr2A = 'd15;   
    localparam TestWriteAddr2  = 'd16;
    localparam SamplingOff     = 'd17;

	reg [5:0] state = Start;
	
	initial	begin
	   Busy <= 0;
	   DataMuxSel <= 0;
	end
	
	//*************************************************************************
	//
	// SampleClockGenerator - generate pulses at sampling freq Fs
	//
	reg  SampleClock;	
	reg  ADC_Enable = 0;
	
	reg [15:0] SampleClockCounter = 0;
	
	always @ (posedge Clock50MHz) begin
		if (SampleClockCounter == SampleClockDivisor)
			SampleClockCounter <= 0;
		else
			SampleClockCounter <= SampleClockCounter + 1;
	end

	always @ (*)
		SampleClock <= (SampleClockCounter == SampleClockDivisor);
		
	always @ (*)
		ADC_Trigger <= (SampleClock == 1 && ADC_Enable == 1);
		
	//*************************************************************************
	//
	// State Machine
	//
    
	always @ (posedge Clock50MHz) begin
		if (Clear == 1)
			state <= Start;
			
		else begin
			case (state)		
				Start: state <= Idle;
				
				Idle: if (ClearSampleBuffer  == 1) state <= Init1;
					  else if (BeginSampling == 1) state <= Init2;
				
				//
				// ClearSampleBuffer
				//
				Init1: begin 
							Busy <= 1;
							DataMuxSel <= 0; 
							state      <= Write1; 
					   end
				
				Write1:  state <= Write1A;
				Write1A: state <= NextWriteAddr1;

				NextWriteAddr1:  state <= NextWriteAddr1A;
				NextWriteAddr1A: state <= TestWriteAddr1;
				
				TestWriteAddr1: if (SampleWriteAddrWrapped == 1) state <= ClearBusy; 
				                else state <= Write1;

				ClearBusy: begin Busy <= 0; state <= Idle; end
				
				//
				// Collect Samples
				//
				Init2: begin 
							Busy <= 1;
							ADC_Enable <= 1; 
							DataMuxSel <= 1; 
							state      <= TestADC21; 
					   end						   					 

				TestADC21: if (ADC_Valid == 0) state <= TestADC22;
				TestADC22: if (ADC_Valid == 1) state <= Write2;
				
  				Write2:  state <= Write2A;
  				Write2A: state <= NextWriteAddr2;

				NextWriteAddr2:  state <= NextWriteAddr2A;
				NextWriteAddr2A: state <= TestWriteAddr2;

				TestWriteAddr2: if (SampleWriteAddrWrapped == 1) state <= SamplingOff; else state <= TestADC21;
				SamplingOff:    begin 
									Busy <= 0;
									ADC_Enable <= 0; 
									state      <= Idle; 
								end
			endcase
		end
	end
	
	always @ (*) begin
		ClearWriteAddr <= (state == Init1)  || (state == Init2);
		SampleWrite    <= (state == Write1) || (state == Write2);		
		IncrWriteAddr  <= (state == NextWriteAddr1) || (state == NextWriteAddr2);
	end
	
endmodule
