
/*
    Sonar1Chan.v
*/

`timescale 1ns / 1ps

module Sonar1Chan #(parameter RamAddrBits = 12,        // up to (2 ^ RamAddrBits) samples collected
                    parameter MaxSamplesPerMsg = 256,
					parameter PowerOnResetCount = 50_000_000)
				   (input wire Clock50MHz,
			  	    input wire ClearBar,
					   
                    input wire InputBit,
                    input wire InputBitShiftClock,
                    input wire InputByteDone,
					   
                    output wire OutputBit,
                    input  wire OutputBitShiftClock,
                    output wire LastBit,
                    output wire FirstBit,
                         
                    output wire TP39,
                    output wire TP38,
                    //output TP37,
                    //output TP36,
                       
					input  wire adc_miso, // ADC controls
                    output wire adc_mosi,
                    output wire adc_csn,
                    output wire adc_sck,               
                       
					output wire dac_csn,  // DAC controls
                    output wire dac_sdi,  
                    output wire dac_ldac, 
                    output wire dac_sck);
					
	// msgs received from PC via Arduino
	localparam ClearSampleBufferID = 'd150;
	localparam BeginSamplingID     = 'd351;
	localparam SendSamplesID       = 'd151;
	localparam ParametersID        = 'd352;
	
	// msgs sent to PC via Arduino
	localparam RdyMsgID    = 'd100;	
	localparam SampleMsgID = 'd301;					

	//*************************************************************************

	// power-on reset
	
	wire Clear;

    PowerOnReset #(.Count (PowerOnResetCount))
               U100 (.Clock50MHz (Clock50MHz), .ClearBar (ClearBar), .Clear (Clear));
			   
    // generate 10Hz ping trigger for initial tests
	wire PingTrigger;
	
	assign PingTrigger = 0;
	
	ClockDivider #(.Divisor (50_000_000 / 10))
 			 U200 (.FastClock (Clock50MHz),  
                   .Clear (1'b0),
                   .SlowClock (),
				 //.Pulse (PingTrigger)); // single pulse at SlowClock rate
				   .Pulse ()); 

	// stretch ping trigger for easier display
	PulseStretcher U201 (.Clock50MHz (Clock50MHz),
                         .trigger    (PingTrigger),
                         .extended   (TP39));

	//*************************************************************************

	localparam DacWidth = 10;
		
    wire [7:0] InputMsgByte;
    wire       InputMsgByteReady;
    wire [7:0] OutputMsgByte;
    wire       LoadOutputMsgByte;
    wire       P2S_Empty;
    
    wire [7:0]  MsgDataByte;
    wire        ClearParamsWriteAddr;
    wire        ParamsWrite;
    wire        ParamsMsgComplete;
    wire        InputMsgComplete;
    wire [15:0] InputMsgID;
    
    wire [15:0] SampleClockDivisor;
    wire [15:0] PingFrequency;
    wire [15:0] PingDuration;
    wire [15:0] BlankingLevel;
    wire [15:0] RampStartingLevel;
    wire [15:0] RampStoppingLevel;
	wire [15:0] RampRateClockDivisor;
	wire [31:0] PaddedRampRateClockDivisor;
	assign      PaddedRampRateClockDivisor [15:0]  = RampRateClockDivisor;
	assign      PaddedRampRateClockDivisor [31:16] = 16'b0;
    
    wire SendRdyMsg;
    wire SendSampleMsg;
    wire SampleMsgPrep;
    wire BeginPingSequence;
    wire RampBeginning;
    wire ClearSampleBuffer;
    wire BeginSampling;
    wire ADC_Busy;
    
    wire [7:0]           SampleByteData;
    wire                 SampleByteRead;
    wire [RamAddrBits:0] SampleCount; // one more than RAM address width
	
	assign TP38 = ADC_Busy;
    
	//*************************************************************************************

	ArduinoSerial U1 (.Clock (Clock50MHz),        
			  	      .Clear (Clear),
					  .InputByte      (InputMsgByte),
					  .InputByteReady (InputMsgByteReady),
					  .OutputByte     (OutputMsgByte),
					  .LoadOutputByte (LoadOutputMsgByte),
					  .P2S_Empty      (P2S_Empty),
                      .InputBit       (InputBit),
                      .InputBitShiftClock  (InputBitShiftClock),
                      .InputByteDone       (InputByteDone),
                      .OutputBit           (OutputBit),
                      .OutputBitShiftClock (OutputBitShiftClock),
                      .LastBit             (LastBit),
                      .FirstBit            (FirstBit));

	//*************************************************************************************

	MsgRouter2 #(.ID1 (ParametersID))
             U2 (.Clock (Clock50MHz),     
                 .Clear (Clear),
			 	 .MessageByte 	   (InputMsgByte),
				 .MessageByteReady (InputMsgByteReady),
                 .SyncWord          (),
                 .MessageID 		(InputMsgID),
                 .ByteCount 		 (),
                 .SequenceNumber  (),
			     .MessageComplete (InputMsgComplete),
				 .DataByte         (MsgDataByte),
				 .ClearMsg1    	 (ClearParamsWriteAddr),
				 .WriteMsg1   	 (ParamsWrite), 
				 .Msg1Complete	 (ParamsMsgComplete), 
				 .ClearMsg2    (),
				 .WriteMsg2    (),
				 .Msg2Complete ());

	//*************************************************************************************

	MsgSenders_S1C #(.AddrWidth        (RamAddrBits),
				     .MaxSamplesPerMsg (MaxSamplesPerMsg),
                     .RdyMsgID         (RdyMsgID),
					 .SampleMsgID      (SampleMsgID))
                 U3 (.Clock (Clock50MHz),     
                     .Clear (Clear),					 
					 .SendReadyMsg   (SendRdyMsg),
                     .SendSampleMsg  (SendSampleMsg),
                     .SampleMsgPrep  (SampleMsgPrep),
                     .SampleByte     (SampleByteData),
                     .SampleByteRead (SampleByteRead),
                     .SampleCount    (SampleCount),                                         
                     .OutputByte     (OutputMsgByte),
                     .LoadOutputByte (LoadOutputMsgByte),
                     .P2S_Empty      (P2S_Empty));

	//*************************************************************************************

	Sonar1Chan_Params U4 (.Clock50MHz  (Clock50MHz),						  
						  .MsgByte     (MsgDataByte),
						  .NewMessage  (ClearParamsWriteAddr),
						  .WriteByte   (ParamsWrite),
						  .MsgComplete (ParamsMsgComplete),
						  .SampleClockDivisor (SampleClockDivisor),
						  .RampStartingLevel  (RampStartingLevel),
						  .RampStoppingLevel  (RampStoppingLevel),
						  .BlankingLevel      (BlankingLevel),    
						  .RampRateClockDivisor (RampRateClockDivisor),
						  .PingFrequency        (PingFrequency),
						  .PingDuration         (PingDuration));

	//*************************************************************************************

    SonarDAC U5 (.Clock50MHz (Clock50MHz), 	               
				 .BeginSequence (BeginPingSequence),
				 .RampBeginning (RampBeginning),
                 .Frequency     (PingFrequency),
				 .PingDuration  (PingDuration),
				 .BlankingLevel        (BlankingLevel     [DacWidth-1:0]),
			     .RampStartingLevel    (RampStartingLevel [DacWidth-1:0]),
			     .RampStoppingLevel    (RampStoppingLevel [DacWidth-1:0]),
				 .RampRateClockDivisor (PaddedRampRateClockDivisor),
				 .dac_csn  (dac_csn),
				 .dac_sdi  (dac_sdi),
				 .dac_ldac (dac_ldac),
				 .dac_sck  (dac_sck));

	//*************************************************************************************

	Sonar1Chan_Controller #(.ClearSampleBufferID (ClearSampleBufferID),
                            .BeginSamplingID     (BeginSamplingID),
							.SendSamplesID       (SendSamplesID),
							.ParametersID        (ParametersID))
						U6 (.Clock50MHz (Clock50MHz),
						    .Clear      (Clear),
							.ForcePing  (PingTrigger),
							.InputMsgComplete  (InputMsgComplete),
							.InputMsgID        (InputMsgID),
							.SendRdyMsg        (SendRdyMsg),
							.SendSampleMsg     (SendSampleMsg),
							.SampleMsgPrep     (SampleMsgPrep),
							.ADC_Busy          (ADC_Busy),
							.ClearSampleBuffer (ClearSampleBuffer),
							.BeginSampling     (BeginSampling),
							.BeginPingSequence (BeginPingSequence),
							.RampBeginning     (RampBeginning));

	//*************************************************************************************

	SonarADC1 #(.RamAddrBits (RamAddrBits))
            U7 (.Clock50MHz (Clock50MHz), 	
  	  	        .Clear (Clear),
				.ByteReadData   (SampleByteData),
				.SampleByteRead (SampleByteRead),
				.ByteAddrClear  (SampleMsgPrep),
				.ClearSampleBuffer  (ClearSampleBuffer),
				.BeginSampling      (BeginSampling),
				.Busy               (ADC_Busy),
				.SampleCount        (SampleCount),				   
				.SampleClockDivisor (SampleClockDivisor),                       
				.adc_miso (adc_miso), 
                .adc_mosi (adc_mosi),
                .adc_csn  (adc_csn),
                .adc_sck  (adc_sck));
endmodule
