
/*
    MessageRouter
*/    

`timescale 1ns / 1ps

module MessageRouter (input [7:0] MessageID,
                      input       MessageValid,
                      output reg  ClearProfile,
                      output reg  LoadProfile,
                      output reg  RunProfile,
                      output reg  StopProfile,
                      output reg  StartCollection,
                      output reg  StopCollection,
                      output reg  BuildCollMsg,
                      output reg  SendCollMsg);
                      
    localparam ClearProfileMsgID    = 1; // these must match Arduino code
    localparam LoadProfileMsgID     = 2;
    localparam RunProfileMsgID      = 3;
    localparam StopProfileMsgID     = 4;
    localparam StartCollectionMsgID = 5;
    localparam StopCollectionMsgID  = 6;
    localparam BuildCollMsgID       = 7;
    localparam SendCollMsgID        = 8;
                          
    always @ (*)
        begin
            ClearProfile = MessageValid && (MessageID == ClearProfileMsgID);
            LoadProfile  = MessageValid && (MessageID == LoadProfileMsgID);
            RunProfile   = MessageValid && (MessageID == RunProfileMsgID);
            StopProfile  = MessageValid && (MessageID == StopProfileMsgID); 
                   
            StartCollection  = MessageValid && (MessageID == StartCollectionMsgID);        
            StopCollection   = MessageValid && (MessageID == StopCollectionMsgID);        
            BuildCollMsg     = MessageValid && (MessageID == BuildCollMsgID);        
            SendCollMsg      = MessageValid && (MessageID == SendCollMsgID);        
        end                                  
endmodule
