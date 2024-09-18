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
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {Clock}]
create_clock -period 20 -waveform {0 10} [get_ports { Clock }];         			# added

# 5V tolerant level shifted I/O
set_property -dict {PACKAGE_PIN C8 IOSTANDARD LVCMOS33} [get_ports {LastBit}]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports {OutputBit}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {FirstBit}]
set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports {InputBitShiftClock}]
set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS33} [get_ports {InputByteDone}]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports {OutputBitShiftClock}]
set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS33} [get_ports {InputBit}]
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {ClearBar}]

#set_property -dict {PACKAGE_PIN B10 IOSTANDARD LVCMOS33} [get_ports {io[10]}]
#set_property -dict {PACKAGE_PIN C8 IOSTANDARD LVCMOS33} [get_ports {io[11]}]
#set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports {io[12]}]
#set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {io[13]}]
#set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports {io[14]}]
#set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS33} [get_ports {io[15]}]
#set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports {io[16]}]
#set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS33} [get_ports {io[17]}]
#set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {io[18]}]
