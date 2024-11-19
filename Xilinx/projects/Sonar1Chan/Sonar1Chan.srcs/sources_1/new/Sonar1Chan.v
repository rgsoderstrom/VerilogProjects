
/*
    Sonar1Chan.v
*/

`timescale 1ns / 1ps

module Sonar1Chan #(parameter RamAddrBits = 12,        // up to (2 ^ RamAddrBits) samples collected
                    parameter MaxSamplesPerMsg = 256,
					parameter ResetCount = 50_000_000)
				   (input Clock50MHz,
			  	    input ClearBar,
					   
                    input InputBit,
                    input InputBitShiftClock,
                    input InputByteDone,
					   
                    output OutputBit,
                    input  OutputBitShiftClock,
                    output LastBit,
                    output FirstBit,
                         
                    //output TP39,
                    //output TP38,
                    //output TP37,
                    //output TP36,
                       
					input  adc_miso, // ADC controls
                    output adc_mosi,
                    output adc_csn,
                    output adc_sck,               
                       
					output dac_csn,  // DAC controls
                    output dac_sdi,  
                    output dac_ldac, 
                    output dac_sck);
					
	// msgs received from PC via Arduino
	localparam ClearSampleBufferID = 'd100;
	localparam BeginSamplingID     = 'd101;
	localparam SendSamplesID       = 'd102;
	localparam ParametersID        = 'd103;
	
	// msgs sent to PC via Arduino
	localparam RdyMsgID    = 'd200;	
	localparam SampleMsgID = 'd201;					

	//*************************************************************************

	// power-on reset
	
	wire Clear;

    PowerOnReset #(.Count (ResetCount))
               U100 (.Clock50MHz (Clock50MHz), .ClearBar (ClearBar), .Clear (Clear));
               
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
