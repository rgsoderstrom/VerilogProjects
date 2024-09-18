
`timescale 1ns / 1ps

module SwitchesToDAC_top (input clk,
                          input sw0,  // slide switch
                          input sw1,
                          input sw2,
                          input sw3,
                          input sw4,
                          input sw5,
                          input sw6,
                          input sw7,
                          
                          output dac_clock,
                          output dac_busy,

                          output dac_csn,  // -- DAC SPI Chip Select
                          output dac_sdi,  // -- DAC SPI MOSI
                          output dac_ldac, // -- DAC SPI Latch enable
                          output dac_sck); // -- DAC SPI CLOCK

       wire trigger;
       reg  zero = 0;
       reg  [9:0] DacInput0 = 0;
       wire [9:0] DacInput1;
       wire [9:0] DacInput;
       wire busy;
       wire load;
       wire chan;
              
       Mercury2_DAC
            U1 (.clk_50MHZ (clk), .trigger (trigger), .channel (chan), .Din (DacInput), .Busy (busy),
                .dac_csn (dac_csn), .dac_sdi (dac_sdi), .dac_ldac (dac_ldac), .dac_sck (dac_sck),
                .dac_clock_copy (dac_clock));
                            
       SwToDAC_controller 
            U2 (.Clk50 (clk), .dac_busy (busy), .load (load), .channel (chan), .dac_trigger (trigger));
            
    assign DacInput1 = 10'h3ff - DacInput0;               
    assign DacInput = chan == 0 ? DacInput0 : DacInput1;
    
    assign dac_busy = busy;
    
                               
    always @ (posedge clk)
	begin
        if (load == 1'B1)
        begin
            DacInput0 [9] <= sw7;
            DacInput0 [8] <= sw6;
            DacInput0 [7] <= sw5;
            DacInput0 [6] <= sw4;
            DacInput0 [5] <= sw3;
            DacInput0 [4] <= sw2;
            DacInput0 [3] <= sw1;
            DacInput0 [2] <= sw0;
            DacInput0 [1] <= 1'B0;
            DacInput0 [0] <= 1'B0;
        end
    end
       
endmodule


