/*
    Merc2ADC_Test3
		- read and store ADC samples from one channel
		- send to Arduino
		- typical numbers:
			- 1024 samples
			- 16 bits/sample
*/

`timescale 1ns / 1ps

module Merc2ADC_Test3 # (parameter RamAddrBits = 10,        // 2 ^ RamAddrBits samples
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
					   
	//localparam ClearMsgID   = 16'd100; // messages from Arduino -- DEFINED IN ADC3_Controller
	//localparam CollectMsgID = 16'd101;
    //localparam SendMsgID    = 16'd102;
    
    localparam SampleMsgID   = 16'd200; // messages to Arduino  
    localparam ReadyMsgID    = 16'd201;
    localparam AllSentMsgID  = 16'd202; 
	
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
	
	wire [RamAddrBits-1:0] SampleReadAddr;
	wire [15:0]            SampleReadData;
	wire                   SampleRead;
	
	// RAM word write address counter
	wire    SampleWriteAddrWrapped;
	wire    ClearWriteAddr;
	wire    IncrWriteAddr;
	
	// wires for DAC - constant output
	wire DAC_Trigger;
	
	// wires to/from controller
	wire SendReadyMsg;
	wire SendAllSentMsg;
  //wire ReadyMsgSent;
	wire ClearReadAddr;
	wire SendSampleMsg;
  //wire SampleSenderReady;
  //wire AllSamplesSent;
	wire IncrSeqNumber;

	// wires for output message generation
	
	wire [1:0] OutputMsgSelect;
	wire [7:0] RdyMsgByte;
//	wire [7:0] AllSentMsgByte;
	wire [7:0] SampleMsgByte;
	wire       P2SLoad0; //
	wire       P2SLoad1;
//	wire       P2SLoad2;
    assign     LoadOutputByte = P2SLoad0 | P2SLoad1;// | P2SLoad2;
	
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
		
	SyncOneShot U1 (.trigger (InputBitShiftClock),  .clk (Clock), .clr (Clear), .Q (SInputBitShiftClock)),
	            U2 (.trigger (InputByteDone),       .clk (Clock), .clr (Clear), .Q (SInputByteDone)),
	            U3 (.trigger (OutputBitShiftClock), .clk (Clock), .clr (Clear), .Q (SOutputBitShiftClock));
			
	SerializerStoP #(.Width (8)) 
                U4 (.DataIn  (InputBit),
                    .Shift   (SInputBitShiftClock),
                    .Done    (SInputByteDone),
                    .Clr     (Clear),
                    .Clk     (Clock),                        
                    .Ready   (InputByteReady),
                    .DataOut (InputByte));			
			   
	wire WriteByte1, WriteByte2, ClearByteAddr1, ClearByteAddr2;
//	wire dacMuxSel;
//	wire [15:0] dacInputWord;
	wire [15:0] AnalogGain;
	wire [15:0] SampleClockDivisor;
	wire  [7:0] MessageByte;
	 
	MsgRouter2 #(.ID1 (103), // Gain message 
	             .ID2 (104)) // Sample rate message
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
				 .ClearMsg2       (ClearByteAddr2), // sample rate
				 .WriteMsg2       (WriteByte2));
				 
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
				 	 
    ADC3_Controller // #(.Fs (Fs))
                  U6 (.Clock (Clock),        
				      .Clear (Clear),						      
                      .RcvdMsgID       (MessageID),
                      .RcvdMsgComplete (MessageComplete),				      
                      .ADC_Valid          (ADC_Valid),
                    //.AllSamplesSent     (AllSamplesSent),
                    //.SampleMsgSent      (SampleSenderReady),
                      .SampleWriteAddrWrapped	  (SampleWriteAddrWrapped),                      
                      .SendReadyMsg	 	  (SendReadyMsg),  
                      .SendSamplesMsg	  (SendSampleMsg),
                //      .SendAllSentMsg	  (SendAllSentMsg),					                        
                      .ADC_Trigger 		  (ADC_Trigger),
                      .ClearWriteAddr	  (ClearWriteAddr),
                      .IncrWriteAddr	  (IncrWriteAddr),
                      .SampleWrite 		  (SampleWrite),
                      .DataMuxSel		  (DataMuxSel),
                      .DAC_Trigger		  (DAC_Trigger),
                  //  .ByteAddrClear	  (ByteAddrClear),
                      .ClearReadAddr (ClearReadAddr),
                      .OutputMsgSelect    (OutputMsgSelect),
					  .IncrSeqCntr        (IncrSeqNumber),
					  .SampleClockDivisor (SampleClockDivisor));
     
    DualPortRAM2 #(.AddrWidth (RamAddrBits)) 
               U7 (.Clk (Clock),
                   .ByteWriteData (8'h00),
                   .ByteReadData  (),   // ByteReadData valid 3 clocks after ByteRead asserted
                   .ByteWrite     (1'b0),
                   .ByteRead      (1'b0), 
                   .ByteClearAddr (1'b0), 
                   .WordWriteData (SampleWriteData),
                   .WordReadData  (SampleReadData),
                   .WordWriteAddr (SampleWriteAddr),
                   .WordReadAddr  (SampleReadAddr),
                   .WordWrite     (SampleWrite),
                   .WordRead      (SampleRead));
	 
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
                   .Ready     (), //        ?????????????????????????? ready to send, to controller
                   .LoadByte  (P2SLoad0),
				   .MsgByte   (RdyMsgByte));
                   
//	HeaderMsgSender #(.MsgID (AllSentMsgID)) 
//	          U13 (.Clock (Clock),
//                   .Clear (Clear),                       
//                   .Send  (SendAllSentMsg), 
//                   .P2S_Empty (P2S_Empty),
//                   .SeqNumber (NextSeqNumber),
//                   .Ready     (),  //        ?????????????????????????? ready to send, to controller
//                   .LoadByte  (P2SLoad2),
//				   .MsgByte   (AllSentMsgByte));


    SampleMsgSender #(.SampleMsgID      (SampleMsgID),
				      .MaxSamplesPerMsg (MaxSamplesPerMsg),
                      .AddrWidth        (RamAddrBits))  // SampleRAM has up to 2^AddrWidth samples to be send
				  U14 (.Clock50MHz    (Clock),        
 				       .Clear         (Clear),					   
				       .ClearReadAddr (ClearReadAddr), // assert once prior to sending first msg of a batch
					   .Ready         (), //SampleSenderReady),  // ready to send a message
					   .LoadAndSend   (SendSampleMsg),      // load samples and send one message
					//   .AllSent     (), // (AllSamplesSent),     // true when all sample data has been sent
							 
					   .SeqNumber (NextSeqNumber),
							 
					   .SampleWord     (SampleReadData), 
					   .SampleReadAddr (SampleReadAddr),
					   .SampleRead     (SampleRead),
					   .SampleCount    (SampleCount), // total number to send
						
					   .P2S_Empty  (P2S_Empty), // output serializer can accept a byte
					   .LoadByte   (P2SLoad1), 
					   .MsgByteOut (SampleMsgByte));
                                                     
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
				 .Din     (AnalogGain [9:0]), // (dacInputWord [9:0]), // (10'd500), 
				 .Busy    (),
				 .dac_csn  (dac_csn),
				 .dac_sdi  (dac_sdi), 
				 .dac_ldac (dac_ldac), 
				 .dac_sck  (dac_sck));		
endmodule

