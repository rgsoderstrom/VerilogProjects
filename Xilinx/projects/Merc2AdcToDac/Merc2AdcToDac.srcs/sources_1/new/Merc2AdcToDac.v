//*********************************************************************************
// 
// Merc2AdcToDac - Mercury 2, connect ADCs to DACs
// 

`timescale 1ns / 1ps
       
module Merc2AdcToDac #(parameter ClockDivisor = 50_000_000 / 25_000,
                       parameter ADC_Delay = 12'd500)
                      (input  Clock50MHz,
              //       input  Clear, // testbench only
                       
                       input  adc_miso, // ADC controls
                       output adc_mosi,
                       output adc_csn,
                       output adc_sck,               

//                       output SampleClock_tp,
//                       output adcTrigger_tp,
//                       output adcDataValid_tp,
                       
                       output dac_csn,  // DAC controls
                       output dac_sdi,  
                       output dac_ldac, 
                       output dac_sck);
                      
    reg Clear = 0; // for real implementation                      

    wire adcTrigger;
    wire dacTrigger;
    wire dacChannel;
    wire adcDataValid;
    wire dacBusy;
    wire dacMuxSelect;
    wire filterReady;
    wire filterLoad;
            
    wire [9:0] adcDout;
	wire [9:0] filterOut;
    wire [9:0] dacInput;
    wire [9:0] adc2sComp;
    wire [9:0] filterOB;

//    assign adcTrigger_tp = adcTrigger;
//    assign dacTrigger_tp = dacTrigger;
//    assign adcDataValid_tp = adcDataValid;
//    assign dacBusy_tp = dacBusy;
//    assign filterReady_tp = filterReady;
//    assign adcData_tp = adcDout [9:5];

	
    //Mercury2_ADC_Sim
      Mercury2_ADC
                   U1  (.clock (Clock50MHz),
                        .trigger   (adcTrigger),
                        .diffn    (1'b1), // 1 for single ended
                        .channel  (3'b010),  
                        .Dout     (adcDout),
                        .OutVal   (adcDataValid),
                        .adc_miso (adc_miso),
                        .adc_mosi (adc_mosi),
                        .adc_cs   (adc_csn),
                        .adc_clk  (adc_sck));
    
      //Mercury2_DAC_Sim  
        Mercury2_DAC
                     U2  (.clk_50MHZ (Clock50MHz), 
                          .trigger  (dacTrigger), 
                          .channel  (dacChannel), 
                          .Din      (dacInput), 
                          .Busy     (dacBusy),
                          .dac_csn  (dac_csn), 
                          .dac_sdi  (dac_sdi), 
                          .dac_ldac (dac_ldac), 
                          .dac_sck  (dac_sck));
                                                    
       AdcToDac_Controller #(.ClockDivisor (ClockDivisor), .ADC_Delay (ADC_Delay))
                         U3 (.Clock50MHz (Clock50MHz),
                             .Clear (Clear),
                             .adcTrigger (adcTrigger),
                             .dacTrigger (dacTrigger),
                             .dacChannel (dacChannel),
                   //        .adcDataValid (adcDataValid),
                             .dacBusy      (dacBusy),
                             .dacMuxSelect (dacMuxSelect),
                             .filterReady (filterReady),
                             .filterLoad  (filterLoad),
                             .sampleClock_tp ()); //SampleClock_tp));
                            
		Mux2 #(.Width (10))
		   U4 (.in0    (adcDout),  
               .in1    (filterOB),
			   .select (dacMuxSelect),
	           .out    (dacInput));
			  
		firFilter1 #(.DataWidth (10))
                 U5 (.Clock (Clock50MHz),
                     .Load  (filterLoad),
                     .Ready (filterReady),
                     .Clear (Clear),
                     .InputData (adc2sComp),  
                     .FilteredData (filterOut));
                     
        OffsetBin2TwosComp #(.Width (10)) U6 (.offsetBinary (adcDout), .twosCompl (adc2sComp));                     
        TwosComp2OffsetBin #(.Width (10)) U7 (.twosCompl (filterOut), .offsetBinary (filterOB));   
        
endmodule



