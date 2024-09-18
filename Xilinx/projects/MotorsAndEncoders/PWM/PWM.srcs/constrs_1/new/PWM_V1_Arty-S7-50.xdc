
##
## PWM_V1_Arty-S7-50.xdc
##


## Clock Signals
# set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33 } [get_ports { CLK12MHZ }]; #IO_L13P_T2_MRCC_15 Sch=uclk
# create_clock -add -name sys_clk_pin -period 83.333 -waveform {0 41.667} [get_ports { CLK12MHZ }];
#set_property -dict { PACKAGE_PIN R2    IOSTANDARD SSTL135 } [get_ports { CLK100MHZ }]; #IO_L12P_T1_MRCC_34 Sch=ddr3_clk[200]
#create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5.000}  [get_ports { CLK100MHZ }];

##
## switches - mapped to "Level" input
##
# set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS33 } [get_ports { Level[0] }]; #IO_L20N_T3_A19_15 Sch=sw[0]
# set_property -dict { PACKAGE_PIN H18   IOSTANDARD LVCMOS33 } [get_ports { Level[1] }]; #IO_L21P_T3_DQS_15 Sch=sw[1]
# set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { Level[2] }]; #IO_L21N_T3_DQS_A18_15 Sch=sw[2]
# set_property -dict { PACKAGE_PIN M5    IOSTANDARD SSTL135 }  [get_ports { Level[3] }]; #IO_L6N_T0_VREF_34 Sch=sw[3]

## 
## digital IO - mapped to PWM output
##
# set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { PWM }];       #IO_L13N_T2_MRCC_14 Sch=ck_io[4]
# set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { Enable }];    #IO_L14P_T2_SRCC_14 Sch=ck_io[5]
# set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { Direction }]; #IO_L14N_T2_SRCC_14 Sch=ck_io[6]

##
## Buttons
##
# set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { Clr }]; #IO_L18N_T2_A23_15 Sch=btn[0]
# set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { Load }]; #IO_L19P_T3_A22_15 Sch=btn[1]


## Configuration options, can be used for all designs
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

## SW3 is assigned to a pin M5 in the 1.35v bank. This pin can also be used as
## the VREF for BANK 34. To ensure that SW3 does not define the reference voltage
## and to be able to use this pin as an ordinary I/O the following property must
## be set to enable an internal VREF for BANK 34. Since a 1.35v supply is being
## used the internal reference is set to half that value (i.e. 0.675v). Note that
## this property must be set even if SW3 is not used in the design.
set_property INTERNAL_VREF 0.675 [get_iobanks 34]

