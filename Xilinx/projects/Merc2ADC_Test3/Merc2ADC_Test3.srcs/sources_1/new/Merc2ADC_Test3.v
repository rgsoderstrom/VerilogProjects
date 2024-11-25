/*
    Merc2ADC_Test3
		- read and store ADC samples from one channel
		- send to Arduino
*/

`timescale 1ns / 1ps

module Merc2ADC_Test3 # (parameter RamAddrBits = 12,        // 2 ^ RamAddrBits samples
                         parameter MaxSamplesPerMsg = 256,  // does not have to be a power of 2
                         parameter ResetCount  = 50_000_000,
                         parameter ClockFreq   = 50_000_000,
                         parameter DefaultFs   = 4096,
                         parameter DefaultGain = 12)
                        (input Clock,        
			  	         input ClearBar,
					   
                         input InputBit,
                         input InputBitShiftClock,
                         input InputByteDone,
					   
                         output OutputBit,
                         input  OutputBitShiftClock,
                         output LastBit,
                         output FirstBit,
                         
                         output TP39,
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
	    
    localparam SampleMsgID   = 16'd201; // messages to Arduino  
    localparam ReadyMsgID    = 16'd100;
 
	localparam ClearSamplesID  = 16'd150; // messages from Arduino
	localparam BeginSamplingID = 16'd251;
	localparam SendSamplesID   = 16'd151;
	localparam SetGainID       = 16'd252;    
	localparam SetSampleRateID = 16'd253;	
	
	//********************************************************************	
	
	// wires for input serializer
    wire SInputBitShiftClock;
	wire SInputByteDone;
	wire [7:0] InputByte;
	wire       InputByteReady;
	
	// wires from msg router
	wire        MessageComplete;
	wire [15:0] MessageID;
	
	// wires for output serializer	
	wire       LoadOutputByte;
    wire       SOutputBitShiftClock;
	wire [7:0] OutputMsgByte;
	wire       P2S_Empty;

	// wires for A/D converter
	wire [9:0] Sample;
	wire       ADC_Trigger;
	wire       ADC_Valid;
	
	// wires from ADC to RAM
	wire [15:0] PaddedSample; 
	assign      PaddedSample [9:0] = Sample;
	assign      PaddedSample [15:10] = 6'b0;
		
	// wires for Sample RAM
	wire [RamAddrBits:0]   SampleCount;
	wire [RamAddrBits-1:0] SampleWriteAddr; 
	wire [15:0]            SampleWriteData;		
	wire       			   SampleWrite;
	wire                   DataMuxSel;
	
	// RAM byte interface to message sender
	wire       ByteAddrClear;
	wire [7:0] ByteReadData;
	wire       SampleByteRead;
	
	// RAM word write address counter
	wire    SampleWriteAddrWrapped;
	wire    ClearWriteAddr;
	wire    IncrWriteAddr;
	
	// wires for DAC - constant output
	wire DAC_Trigger;
	
	// wires to/from controller
	wire SendReadyMsg;
	wire SendAllSentMsg;
	wire SendSampleMsg;
	wire IncrSeqNumber;

	// wires for output message generation
	
	wire [1:0] OutputMsgSelect;
	wire [7:0] RdyMsgByte;
	wire [7:0] SampleMsgByte;
	wire       P2SLoad0; //
	wire       P2SLoad1;
    assign     LoadOutputByte = P2SLoad0 | P2SLoad1;
	
	//*************************************************************************

	// power-on reset
	wire Clear;
    PowerOnReset #(.Count (ResetCount))
               U100 (.Clock50MHz (Clock), .ClearBar (ClearBar), .Clear (Clear));
               
    PulseStretcher #(.Count (10))
               U101 (.Clock50MHz (Clock), .trigger (ADC_Trigger), .extended (TP39));
		
//    PulseStretcher #(.Count (8000))
//               U102 (.Clock50MHz (Clock), .trigger (ADC_Valid), .extended (TP38));
		
	// Message Sequence Number Counter
    wire [15:0] SequenceCounter;
	wire [15:0] NextSeqNumber = SequenceCounter + 1;
	    
    CounterUEC #(.Width (16))
           U103 (.Enable (IncrSeqNumber), .Clr (Clear), .Clk (Clock), .AtZero (), .AtMax (), .Q (SequenceCounter));

	//*************************************************************************
		
	SyncOneShot U1 (.trigger (InputBitShiftClock),  .clk (Clock), .clr (0/*Clear*/), .Q (SInputBitShiftClock)),
	            U2 (.trigger (InputByteDone),       .clk (Clock), .clr (0/*Clear*/), .Q (SInputByteDone)),
	            U3 (.trigger (OutputBitShiftClock), .clk (Clock), .clr (0/*Clear*/), .Q (SOutputBitShiftClock));
			
	SerializerStoP #(.Width (8)) 
                U4 (.DataIn  (InputBit),
                    .Shift   (SInputBitShiftClock),
                    .Done    (SInputByteDone),
                    .Clr     (Clear),
                    .Clk     (Clock),                        
                    .Ready   (InputByteReady),
                    .DataOut (InputByte));			
			   
	wire WriteByte1, WriteByte2, ClearByteAddr1, ClearByteAddr2;

	wire [15:0] AnalogGain;
	wire [15:0] SampleClockDivisor;
	wire  [7:0] MessageByte;
	 
	MsgRouter2 #(.ID1 (SetGainID), 
	             .ID2 (SetSampleRateID))
             U5 (.Clock (Clock),
                 .Clear (Clear),
			 	 .MessageByte      (InputByte),
				 .MessageByteReady (InputByteReady),
                 .SyncWord (),
                 .MessageID (MessageID),
                 .ByteCount (),
                 .SequenceNumber (),
			     .MessageComplete (MessageComplete),
				 .DataByte        (MessageByte),
				 .ClearMsg1       (ClearByteAddr1), // gain
				 .WriteMsg1       (WriteByte1),
				 .Msg1Complete    (),
				 .ClearMsg2       (ClearByteAddr2), // sample rate
				 .WriteMsg2       (WriteByte2),
				 .Msg2Complete    ());
				 
				 // Message word
	MessageWord #(.BytesPerWord (2), 
	              .Default (DefaultGain))
            U51  (.Clock (Clock),                   
				  .ClearAddr (ClearByteAddr1),
				  .WriteByte (WriteByte1),
				  .DataByte  (MessageByte),
				  .DataWord  (AnalogGain));				 
				 
				 // Message word
	MessageWord #(.BytesPerWord (2),
	              .Default (ClockFreq / DefaultFs - 1))
            U52  (.Clock (Clock),                   
				  .ClearAddr (ClearByteAddr2),
				  .WriteByte (WriteByte2),
				  .DataByte  (MessageByte),
				  .DataWord  (SampleClockDivisor));
				 	 
    ADC3_Controller #(.ClearSamplesID  (ClearSamplesID),
	                  .BeginSamplingID (BeginSamplingID),
	                  .SendSamplesID   (SendSamplesID),
	                  .SetGainID       (SetGainID),
	                  .SetSampleRateID (SetSampleRateID))
                  U6 (.Clock (Clock),        
				      .Clear (Clear),						      
                      .RcvdMsgID              (MessageID),
                      .RcvdMsgComplete        (MessageComplete),				      
                      .ADC_Valid              (ADC_Valid),
                      .SampleWriteAddrWrapped (SampleWriteAddrWrapped),                      
                      .SendReadyMsg	 	  (SendReadyMsg),  
                      .SendSamplesMsg	  (SendSampleMsg),
                      .ADC_Trigger 		  (ADC_Trigger),
                      .ClearWriteAddr	  (ClearWriteAddr),
                      .IncrWriteAddr	  (IncrWriteAddr),
                      .SampleWrite 		  (SampleWrite),
                      .DataMuxSel		  (DataMuxSel),
                      .DAC_Trigger		  (DAC_Trigger),
                      .ClearReadAddr      (ByteAddrClear),
                      .OutputMsgSelect    (OutputMsgSelect),
					  .IncrSeqCntr        (IncrSeqNumber),
					  .SampleClockDivisor (SampleClockDivisor));
         
    DualPortRAM2 #(.AddrWidth (RamAddrBits)) 
               U7 (.Clk (Clock),
                   .ByteWriteData (8'h00),
                   .ByteWrite     (1'b0),

                   .ByteReadData  (ByteReadData),   // ByteReadData valid 3 clocks after ByteRead asserted
                   .ByteRead      (SampleByteRead), 
                   .ByteClearAddr (ByteAddrClear), 
                   
                   .WordWriteData (SampleWriteData),
                   .WordWriteAddr (SampleWriteAddr),
                   .WordWrite     (SampleWrite),

                   .WordReadData  (),    
                   .WordReadAddr  ('d0),
                   .WordRead      (0));
				   
				   
    SampleMsgSenderV3 #(.SampleMsgID      (SampleMsgID),
				       .MaxSamplesPerMsg (MaxSamplesPerMsg),
                       .AddrWidth        (RamAddrBits))  // SampleRAM has up to 2^AddrWidth samples to be send
				  U14 (.Clock50MHz    (Clock),        
 				       .Clear         (Clear),					   
				       .PrepareToSend (ByteAddrClear), // assert once prior to sending first msg of a batch
					   .Ready         (),              // ready to send a message
					   .Send          (SendSampleMsg), // load samples and send one message
							 
					   .SeqNumber (NextSeqNumber),
							 
					   .SampleByte     (ByteReadData), 
					   .SampleByteRead (SampleByteRead),
					   .SampleCount    (SampleCount), // total number to send
						
					   .P2S_Empty  (P2S_Empty), // output serializer ready to accept a byte
					   .LoadByte   (P2SLoad1), 
					   .MsgByteOut (SampleMsgByte));
                                                     				   				  	
    Mux2 #(.Width (16))
		 U8 (.in0    (16'h0),        // write 0 to clear RAM
             .in1    (PaddedSample),
 			 .select (DataMuxSel),
	         .out    (SampleWriteData));

	CounterUEC #(.Width (RamAddrBits + 1))
            U9  (.Enable (IncrWriteAddr),
				 .Clr    (ClearWriteAddr),
                 .Clk    (Clock), 
				 .AtZero (),
				 .AtMax  (),
                 .Q      (SampleCount));  

    assign SampleWriteAddr        = SampleCount [RamAddrBits-1:0];
    assign SampleWriteAddrWrapped = SampleCount [RamAddrBits] == 1;

	SerializerPtoS #(.Width (8))
                U10 (.Input (OutputMsgByte),
                     .Clr   (Clear),
                     .Clk   (Clock),
                     .Load  (LoadOutputByte),
                     .Shift (SOutputBitShiftClock),
				     .Empty (P2S_Empty),
				     .FirstBit  (FirstBit),
				     .LastBit   (LastBit),
                     .OutputBit (OutputBit));

    Mux4 U11 (.in0  (RdyMsgByte),
              .in1  (SampleMsgByte),
              .in2  (), // AllSentMsgByte),
              .in3  (8'h00),
 			  .select (OutputMsgSelect),
	          .out    (OutputMsgByte));
	 
	HeaderMsgSender #(.MsgID (ReadyMsgID))   
	          U12 (.Clock (Clock),
                   .Clear (Clear),                       
                   .Send  (SendReadyMsg), 
                   .P2S_Empty (P2S_Empty),
                   .SeqNumber (NextSeqNumber),
                   .Ready     (),
                   .LoadByte  (P2SLoad0),
				   .MsgByte   (RdyMsgByte));
                   
  //Mercury2_ADC_Sim 
    Mercury2_ADC 
				U15	(.clock   (Clock),
                     .trigger (ADC_Trigger),
                     .channel (3'b000),
                     .Dout    (Sample),   
                     .OutVal  (ADC_Valid), 
                     .diffn   (1'b1),        
                     .adc_miso (adc_miso),
                     .adc_mosi (adc_mosi), 
                     .adc_cs   (adc_csn), 
                     .adc_clk  (adc_sck));

  //Mercury2_DAC_Sim 
    Mercury2_DAC 
			U16 (.clk_50MHZ (Clock),
				 .trigger (DAC_Trigger),
				 .channel (1'b1),   
				 .Din     (AnalogGain [9:0]),
				 .Busy    (),
				 .dac_csn  (dac_csn),
				 .dac_sdi  (dac_sdi), 
				 .dac_ldac (dac_ldac), 
				 .dac_sck  (dac_sck));		
endmodule

