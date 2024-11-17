/*
    SonarADC1 - ADC interface for single channel SONAR
*/

`timescale 1ns / 1ps

module SonarADC1# (parameter RamAddrBits = 12)
                  (input Clock50MHz,
			  	   input Clear,
				   
				   output [7:0] ByteReadData,
				   input        SampleByteRead,
				   input        ByteAddrClear,
				   
				   input ClearSampleBuffer,
				   input BeginSampling,
				   output     Busy, // was reg
				   output     [RamAddrBits:0] SampleCount,
				// output reg [RamAddrBits:0] SampleCount,
				   
				   input [15:0] SampleClockDivisor,
                       
				   input  adc_miso, // ADC controls
                   output adc_mosi,
                   output adc_csn,
                   output adc_sck);
				   
				   
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
				U1 (.clock   (Clock50MHz),
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
	   U2 (.in0    (16'h0),        // selected to write 0 to clear RAM
           .in1    (PaddedSample),
 		   .select (DataMuxSel),
	       .out    (SampleWriteData));
	       
    DualPortRAM2 #(.AddrWidth (RamAddrBits)) 
               U3 (.Clk (Clock50MHz),
			   
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
            U4  (.Enable (IncrWriteAddr),
				 .Clr    (ClearWriteAddr),
                 .Clk    (Clock50MHz), 
				 .AtZero (),
				 .AtMax  (),
                 .Q      (SampleCount));  

    assign SampleWriteAddr        = SampleCount [RamAddrBits-1:0];
    assign SampleWriteAddrWrapped = SampleCount [RamAddrBits] == 1;

	SonarADC1_Controller U5 (.Clock50MHz (Clock50MHz),        
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