/*
    SonarADC1 - ADC interface for single channel SONAR
*/

`timescale 1ns / 1ps

module SonarADC1# (parameter RamAddrBits = 12)
                  (input wire Clock50MHz,
			  	   input wire Clear,
				   
				   output wire [7:0] ByteReadData,
				   input  wire       SampleByteRead,
				   input  wire       ByteAddrClear,
				   
				   input  wire ClearSampleBuffer,
				   input  wire BeginSampling,
				   output wire Busy, // was reg
				   output wire [RamAddrBits:0] SampleCount,
				// output reg [RamAddrBits:0] SampleCount,
				   
				   input wire [15:0] SampleClockDivisor,
                       
				   input  wire adc_miso, // ADC controls
                   output wire adc_mosi,
                   output wire adc_csn,
                   output wire adc_sck);
				   
				   
    wire [15:0] 		   SampleWriteData;
	wire [RamAddrBits-1:0] SampleWriteAddr;
	wire 				   SampleWrite;
	wire                   SampleWriteAddrWrapped;
	
	wire IncrWriteAddr;
	wire ClearWriteAddr;
	wire ADC_Valid;
	wire ADC_Trigger;
	wire DataMuxSel;
	
	//********************************************************************************
                
    wire [9:0] Sample;
                             
  //Mercury2_ADC_Sim 
    Mercury2_ADC 
			   ADC (.clock   (Clock50MHz),
                    .trigger (ADC_Trigger),
                    .channel (3'b000),
                    .Dout    (Sample),   
                    .OutVal  (ADC_Valid), 
                    .diffn   (1'b1),        
                    .adc_miso (adc_miso),
                    .adc_mosi (adc_mosi), 
                    .adc_cs   (adc_csn), 
                    .adc_clk  (adc_sck));

	// wires from ADC to RAM
	wire [15:0] PaddedSample; 
	assign      PaddedSample [9:0] = Sample;
	assign      PaddedSample [15:10] = 6'b0;
	
    Mux2 #(.Width (16))
	 Mux2 (.in0    (16'h0),        // selected to write 0 to clear RAM
           .in1    (PaddedSample),
 		   .select (DataMuxSel),
	       .out    (SampleWriteData));
	       
    DualPortRAM2 #(.AddrWidth (RamAddrBits)) 
              RAM (.Clk (Clock50MHz),
			   
                   .ByteClearAddr (ByteAddrClear), 

                   .ByteWriteData (8'h00),
                   .ByteWrite     (1'b0),

                   .ByteReadData  (ByteReadData),
                   .ByteRead      (SampleByteRead), 

                   .WordWriteAddr (SampleWriteAddr),
                   .WordWriteData (SampleWriteData),
                   .WordWrite     (SampleWrite),

                   .WordReadAddr  ('d0),
                   .WordReadData  (),
                   .WordRead      (1'b0));
                   
	CounterUEC #(.Width (RamAddrBits + 1))
      SampCntr  (.Enable (IncrWriteAddr),
				 .Clr    (ClearWriteAddr),
                 .Clk    (Clock50MHz), 
				 .AtZero (),
				 .AtMax  (),
                 .Q      (SampleCount));  

    assign SampleWriteAddr        = SampleCount [RamAddrBits-1:0];
    assign SampleWriteAddrWrapped = SampleCount [RamAddrBits] == 1;

	SonarADC1_Controller 
			  	   Adc_Ctrl (.Clock50MHz (Clock50MHz),        
				             .Clear (Clear),

    						 .SampleClockDivisor (SampleClockDivisor),
       
                             .ADC_Valid   (ADC_Valid),
                             .ADC_Trigger (ADC_Trigger),
                        
							 .SampleWriteAddrWrapped (SampleWriteAddrWrapped),
							 .ClearSampleBuffer 	 (ClearSampleBuffer),
							 .BeginSampling          (BeginSampling),
							 
							 .Busy (Busy),
							 
                             .ClearWriteAddr (ClearWriteAddr),
                             .IncrWriteAddr  (IncrWriteAddr),
                             .SampleWrite    (SampleWrite),
                             .DataMuxSel     (DataMuxSel));
	                          
endmodule