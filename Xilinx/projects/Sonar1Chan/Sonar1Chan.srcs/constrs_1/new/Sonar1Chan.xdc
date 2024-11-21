#      __  ____                 _   __                
#    /  |/  (_)_____________  / | / /___ _   ______ _
#   / /|_/ / / ___/ ___/ __ \/  |/ / __ \ | / / __ `/
#  / /  / / / /__/ /  / /_/ / /|  / /_/ / |/ / /_/ / 
# /_/  /_/_/\___/_/   \____/_/ |_/\____/|___/\__,_/  
#                                                  
# Mercury 2 User Constraints File
# Revision 0.B
# Copyright (c) 2019 MicroNova, LLC
# www.micro-nova.com

# general settings
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# on-board system oscillator
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {Clock50MHz}]
create_clock -period 20 -waveform {0 10} [get_ports { Clock50MHz }];         			# added

# 5V tolerant level shifted I/O
set_property -dict {PACKAGE_PIN C8 IOSTANDARD LVCMOS33} [get_ports {LastBit}]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports {OutputBit}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {FirstBit}]
set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports {InputBitShiftClock}]
set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS33} [get_ports {InputByteDone}]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports {OutputBitShiftClock}]
set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS33} [get_ports {InputBit}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {ClearBar}]

# was io [36] - [39]
#set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports {TP36}]
#set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {TP37}]
set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {TP38}]
set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {TP39}]


# DAC interface
set_property -dict {PACKAGE_PIN K12 IOSTANDARD LVCMOS33} [get_ports {dac_sdi}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {dac_ldac}]
set_property -dict {PACKAGE_PIN N13 IOSTANDARD LVCMOS33} [get_ports {dac_sck}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {dac_csn}]

# ADC interface
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {adc_miso}]
set_property -dict {PACKAGE_PIN J16 IOSTANDARD LVCMOS33} [get_ports {adc_mosi}]
set_property -dict {PACKAGE_PIN P10 IOSTANDARD LVCMOS33} [get_ports {adc_sck}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {adc_csn}]

