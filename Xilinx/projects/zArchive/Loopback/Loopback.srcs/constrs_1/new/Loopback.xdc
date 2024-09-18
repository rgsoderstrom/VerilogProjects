##
## Loopback, Arduino => FPGA => Arduino
##

## This file is a general .xdc for the Arty S7-50 Rev. E
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock Signals
set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33 } [get_ports { CLK12MHZ }]; #IO_L13P_T2_MRCC_15 Sch=uclk
create_clock -add -name sys_clk_pin -period 83.333 -waveform {0 41.667} [get_ports { CLK12MHZ }];

set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { DataOut  }]; #IO_0_15            Sch=ck_a[0]
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33 } [get_ports { ShiftOut }]; #IO_L4P_T0_15       Sch=ck_a[1]
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports { LoadOut  }]; #IO_L4N_T0_15       Sch=ck_a[2]
set_property -dict { PACKAGE_PIN C13   IOSTANDARD LVCMOS33 } [get_ports { DataIn   }]; #IO_L6P_T0_15       Sch=ck_a[3]
set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVCMOS33 } [get_ports { ShiftIn  }]; #IO_L6N_T0_VREF_15  Sch=ck_a[4]
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { LoadHR   }]; #IO_L11P_T1_SRCC_15 Sch=ck_a[5]

## Misc. ChipKit Ports
set_property -dict { PACKAGE_PIN C18   IOSTANDARD LVCMOS33 } [get_ports { Clr }]; #IO_L11N_T1_SRCC_15

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
