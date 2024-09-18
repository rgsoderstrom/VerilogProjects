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
create_clock -period 20 -waveform {0 10} [get_ports {Clock50MHz}];


# 5V tolerant level shifted I/O
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {ByteWriteData_Bit}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {ByteWriteData_Shift}]
#set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports {ByteWriteData_Done}]

set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {WordWriteData_Bit}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {WordWriteData_Shift}]
#set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {WordWriteData_Done}]

set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports {WordAddr_Bit}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {WordAddr_Shift}]
#set_property -dict {PACKAGE_PIN A2 IOSTANDARD LVCMOS33} [get_ports {WordAddr_Done}]

set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33}  [get_ports {WordReadData_Load}]
set_property -dict {PACKAGE_PIN B10 IOSTANDARD LVCMOS33} [get_ports {WordReadData_Shift}]

set_property -dict {PACKAGE_PIN C8 IOSTANDARD LVCMOS33}  [get_ports {ByteReadData_Load}]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33}  [get_ports {ByteReadData_Shift}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {ByteReadData_Empty}]

set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports {ByteReadData_FirstBit}]
set_property -dict {PACKAGE_PIN P11 IOSTANDARD LVCMOS33} [get_ports {ByteReadData_LastBit}]
set_property -dict {PACKAGE_PIN T2 IOSTANDARD LVCMOS33} [get_ports  {ByteReadData_Bit}]

set_property -dict {PACKAGE_PIN T4 IOSTANDARD LVCMOS33} [get_ports {WordReadData_Empty}]
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports {WordReadData_FirstBit}]
set_property -dict {PACKAGE_PIN T7 IOSTANDARD LVCMOS33} [get_ports {WordReadData_LastBit}]
set_property -dict {PACKAGE_PIN K5 IOSTANDARD LVCMOS33} [get_ports {WordReadData_Bit}]

set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {ByteWrite}]
set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS33} [get_ports {ByteRead}]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports {ByteAddrClear}]
#set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS33} [get_ports {ByteReadNext}]

set_property -dict {PACKAGE_PIN D8 IOSTANDARD LVCMOS33} [get_ports {WordWrite}]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {WordRead}]

#set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports {Ready}]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports {Clear}]

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
