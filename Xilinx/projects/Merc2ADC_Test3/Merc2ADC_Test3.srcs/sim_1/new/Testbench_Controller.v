/*
    Testbench_Controller.v
*/    

`timescale 1ns / 1ps

module Testbench_Controller;

	// registers to drive Controller inputs
    reg  Clock = 0;
    reg  Clear = 0;

	reg ClearSampleBuffer = 0; // from MsgRouter, indicate a particular command received
	reg BeginSampling = 0;
	reg SendSamples = 0;

    wire ADC_Valid;
    reg AllSamplesSent = 0;
    reg MsgSent = 0;
    reg WordAddrMax; // = 0;
    
    // wires for Controller outputs
    wire SendReadyMsg;
    wire SendSamplesMsg;
    wire SendAllSentMsg;                     
    wire ADC_Trigger;
    wire ClearWriteAddr;
    wire IncrWriteAddr;
    wire WordWrite;
    wire DataMuxSel;
    wire DAC_Trigger;
    wire ByteAddrClear;
    wire ClearSampleMsgCntr;
    
    wire [9:0] Dout; // ADC
    localparam RamAddrWidth = 5; // 10
    
    ADC3_Controller #(.ClockFreq (50_000_000), 
                      .Fs (50_000_000 / 64)) // (19150)) // sampling frequency
                  U1 (.Clock (Clock),        
				      .Clear (Clear),
				      
				      // inputs
				      .ClearSampleBuffer (ClearSampleBuffer), 
				      .BeginSampling     (BeginSampling),
				      .SendSamples       (SendSamples),

                      .ADC_Valid      (ADC_Valid),
                      .AllSamplesSent (AllSamplesSent),
                      .MsgSent        (MsgSent),
                      .WordAddrMax    (WordAddrMax),
                      
                      // outputs
                      .SendReadyMsg   (SendReadyMsg),    // to message generators
                      .SendSamplesMsg (SendSamplesMsg),
                      .SendAllSentMsg (SendAllSentMsg),
                      
                      .ADC_Trigger    (ADC_Trigger),
                      .ClearWriteAddr (ClearWriteAddr),
                      .IncrWriteAddr  (IncrWriteAddr),
                      .WordWrite      (WordWrite),
                      .DataMuxSel     (DataMuxSel),
                      .DAC_Trigger    (DAC_Trigger),
                      .ByteAddrClear  (ByteAddrClear),
                      .ClearSampleMsgCntr (ClearSampleMsgCntr));

    Mercury2_ADC_Sim U2 (.clk_50MHZ (Clock),     // -- 50MHz onboard oscillator
                         .trigger (ADC_Trigger),       // -- assert to write Din to ADC
                         .channel (3'b000), // -- 0..7
                         .Dout (Dout),      // -- data out
                         .OutVal (ADC_Valid),    // -- output valid
                         .difn (1),          // -- select single ended or differential
                         .adc_miso (0),
                         .adc_mosi (), 
                         .adc_cs (), 
                         .adc_clk ());                         
    //
    // WordAddrCounter                         
    //    
    wire [RamAddrWidth-1:0] WordAddress;
    
    CounterUEC #(.Width (RamAddrWidth))
             U3 (.Enable (IncrWriteAddr),
			 	 .Clr    (ClearWriteAddr),
                 .Clk    (Clock),
                 .Output (WordAddress));

    always @ (*) begin
        WordAddrMax <= &WordAddress;
    end
    
//    P2S_Register U4 (input [Width-1:0]  Input,
//                     input              Clr,   // sync, active high
//                     input              Clk,   // pos edge triggered
//                     input              Load,
//  				     output             Empty,     // ready to load,
//                     output reg [Width-1:0] Output,
//                     input              GetNext);
    

    //******************************************************************                         


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
        #10 Clock = ~Clock;  
        
    //
    // test run
    //
    initial
    begin
//		#100 SendSamples = 1;
//		#20  SendSamples = 0;
//		#100 BeginSampling = 1;
//		#20  BeginSampling = 0;
		#100 ClearSampleBuffer = 1;
		#20  ClearSampleBuffer = 0;
		
	
   //   #3000 $finish;
	end



endmodule
