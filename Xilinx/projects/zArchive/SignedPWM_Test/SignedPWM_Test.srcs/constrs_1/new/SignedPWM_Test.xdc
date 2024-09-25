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

# modified from mercury2.xdc

# general settings
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# on-board system oscillator
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {Clock50MHz}]
create_clock -period 20 -waveform {0 10} [get_ports { Clock50MHz }];         			# added


# on-board user LEDs
#set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
#set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
#set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports {led[2]}]

# 5V tolerant level shifted I/O
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {PWM1}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {PWM2}]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports {Dir1}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {Dir2}]
#set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {io[4]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {Enc4Y}]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports {Enc4X}]
#set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {io[7]}]
set_property -dict {PACKAGE_PIN A2 IOSTANDARD LVCMOS33}  [get_ports {Enc3Y}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33}  [get_ports {Enc3X}]
#set_property -dict {PACKAGE_PIN B10 IOSTANDARD LVCMOS33} [get_ports {io[10]}]
#set_property -dict {PACKAGE_PIN C8 IOSTANDARD LVCMOS33} [get_ports {io[11]}]
#set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports {io[12]}]
#set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {io[13]}]
set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports {ClearBar}]
#set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS33} [get_ports {io[15]}]
#set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports {io[16]}]
#set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS33} [get_ports {io[17]}]
#set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {io[18]}]
#set_property -dict {PACKAGE_PIN T7 IOSTANDARD LVCMOS33} [get_ports {io[19]}]
#set_property -dict {PACKAGE_PIN K5 IOSTANDARD LVCMOS33} [get_ports {io[20]}]
#set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {io[21]}]
#set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS33} [get_ports {io[22]}]
#set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports {io[23]}]
#set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS33} [get_ports {io[24]}]
#set_property -dict {PACKAGE_PIN D8 IOSTANDARD LVCMOS33} [get_ports {io[25]}]
#set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {io[26]}]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports {Clock1Hz}]
#set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports {io[28]}]
#set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports {io[29]}]
#set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS33} [get_ports {io[30]}]
#set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS33} [get_ports {io[31]}]
#set_property -dict {PACKAGE_PIN L2 IOSTANDARD LVCMOS33} [get_ports {io[32]}]
#set_property -dict {PACKAGE_PIN G5 IOSTANDARD LVCMOS33} [get_ports {io[33]}]
#set_property -dict {PACKAGE_PIN H5 IOSTANDARD LVCMOS33} [get_ports {io[34]}]
#set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {io[35]}]
#set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports {io[36]}]
#set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {io[37]}]
#set_property -dict {PACKAGE_PIN J1 IOSTANDARD LVCMOS33} [get_ports {io[38]}]
#set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {io[39]}]