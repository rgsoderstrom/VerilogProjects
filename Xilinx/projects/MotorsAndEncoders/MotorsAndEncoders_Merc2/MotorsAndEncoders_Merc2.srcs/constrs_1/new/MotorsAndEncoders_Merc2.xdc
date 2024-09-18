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
create_clock -period 20 -waveform {0 10} [get_ports { Clock50MHz }];

# 5V tolerant level shifted I/O
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {PWM1}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {PWM2}]
#set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports {io[2]}]
#set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {io[3]}]
#set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {io[4]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {Enc4Y}]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports {Enc4X}]
#set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {io[7]}]
set_property -dict {PACKAGE_PIN A2 IOSTANDARD LVCMOS33}  [get_ports {Enc3Y}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33}  [get_ports {Enc3X}]

set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports {Dir1}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {Dir2}]
set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports {ClearBar}]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports {InputByteDone}]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports {InputShiftClock}]
set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports {InputBit}]
set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS33} [get_ports {LastBit}]
set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS33} [get_ports {OutputBitShiftClock}]
set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports {OutputDataBit}]
set_property -dict {PACKAGE_PIN G5 IOSTANDARD LVCMOS33} [get_ports {FirstBit}]
set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {TestPoint}]
