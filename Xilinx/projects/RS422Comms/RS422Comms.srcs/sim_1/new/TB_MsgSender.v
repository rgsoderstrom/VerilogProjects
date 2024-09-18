/*
    TB_MsgSender.v 
        - testbench MsgSender
        - models Arduino shifting messages out to FPGA
*/
    
`timescale 1ns / 1ps

module TB_MsgSender #(parameter M = 2)
                     (input Clock,         
                      input [7:0] MessageByte,
                      output [M-1:0] Index, // MessageByte = fileBytes [Index]
                      input          Send,
                      output         Done,
                      output         Busy,
                      output         MsgBit,
                      output         BitShiftClock,
                      output         ByteDone);
         
    reg [9:0] Count; // = (RunProcMsgByteStream [5] << 8) + RunProcMsgByteStream [4];
                      
                          
endmodule
