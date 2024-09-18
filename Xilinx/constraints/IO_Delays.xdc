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



# Example specifying I/O timing. 



# general settings
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# on-board system oscillator
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {Clock}]
create_clock -period 20 -waveform {0 10} [get_ports { Clock }];         			# added
#set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports {clk_en}]

# 5V tolerant level shifted I/O
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {Clear}]
set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {Trigger}]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS33} [get_ports {Enable}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS33} [get_ports {Ramp[0]}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports {Ramp[1]}]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports {Ramp[2]}]
set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports {Ramp[3]}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports {Ramp[4]}]
set_property -dict {PACKAGE_PIN A2 IOSTANDARD LVCMOS33} [get_ports {Ramp[5]}]
set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {Ramp[6]}]
set_property -dict {PACKAGE_PIN B10 IOSTANDARD LVCMOS33} [get_ports {Ramp[7]}]
set_property -dict {PACKAGE_PIN C8 IOSTANDARD LVCMOS33} [get_ports {Ramp[8]}]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS33} [get_ports {Ramp[9]}]


# Rising Edge System Synchronous Inputs
#
# A Single Data Rate (SDR) System Synchronous interface is
# an interface where the external device and the FPGA use
# the same clock, and a new data is captured one clock cycle
# after being launched
#
# input      __________            __________
# clock   __|          |__________|          |__
#           |
#           |------> (tco_min+trce_dly_min)
#           |------------> (tco_max+trce_dly_max)
#         __________      ________________    
# data    __________XXXXXX_____ Data _____XXXXXXX
#

set input_clock     Clock;   # Name of input clock
set tco_max         3.000;          # Maximum clock to out delay (external device)
set tco_min         1.000;          # Minimum clock to out delay (external device)
set trce_dly_max    1.000;          # Maximum board trace delay
set trce_dly_min    0.000;          # Minimum board trace delay
#set input_ports     Trigger;  # List of input ports

# Input Delay Constraint
set_input_delay -clock $input_clock -max [expr $tco_max + $trce_dly_max] [get_ports Clear];
set_input_delay -clock $input_clock -min [expr $tco_min + $trce_dly_min] [get_ports Clear];
set_input_delay -clock $input_clock -max [expr $tco_max + $trce_dly_max] [get_ports Trigger];
set_input_delay -clock $input_clock -min [expr $tco_min + $trce_dly_min] [get_ports Trigger];
set_input_delay -clock $input_clock -max [expr $tco_max + $trce_dly_max] [get_ports Enable];
set_input_delay -clock $input_clock -min [expr $tco_min + $trce_dly_min] [get_ports Enable];


# Rising Edge System Synchronous Outputs 
#
# A System Synchronous design interface is a clocking technique in which the same 
# active-edge of a system clock is used for both the source and destination device. 
#
# dest        __________            __________
# clk    ____|          |__________|
#                                  |
#     (trce_dly_max+tsu) <---------|
#             (trce_dly_min-thd) <-|
#                        __    __
# data   XXXXXXXXXXXXXXXX__DATA__XXXXXXXXXXXXX
#

set destination_clock Clock;     # Name of destination clock
set tsu               3.000;            # Destination device setup time requirement
set thd               3.000;            # Destination device hold time requirement
set trce_dly_max      2.000;            # Maximum board trace delay
set trce_dly_min      0.000;            # Minimum board trace delay
#set output_ports      [Ramp[0], Ramp[1], Ramp[2]];   # List of output ports

# Output Delay Constraint
set_output_delay -clock $destination_clock -max [expr $trce_dly_max + $tsu] [get_ports Ramp[*]];
set_output_delay -clock $destination_clock -min [expr $trce_dly_min - $thd] [get_ports Ramp[*]];

# Report Timing Template
# report_timing -to [get_ports $output_ports] -max_paths 20 -nworst 1 -delay_type min_max -name sys_sync_rise_out -file sys_sync_rise_out.txt;
        
        
        

