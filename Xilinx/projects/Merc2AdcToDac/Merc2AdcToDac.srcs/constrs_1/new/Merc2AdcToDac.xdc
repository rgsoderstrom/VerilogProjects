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

#
# Modified
#


# general settings
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# on-board system oscillator
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {Clock50MHz}]
create_clock -period 20 -waveform {0 10} [get_ports {Clock50MHz}];

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

