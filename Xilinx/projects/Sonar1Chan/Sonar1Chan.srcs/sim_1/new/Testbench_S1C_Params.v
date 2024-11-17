/*
    Testbench_Top - for top-level ADC3_Test
*/

`timescale 1ns / 1ps

module Testbench_S1C_Params;
    reg  Clock = 0;

	reg [7:0] MsgByte;
	reg       ByteAddrClear = 0;
	reg       ByteWrite     = 0;
	reg       MsgComplete   = 0;

	wire [15:0] SampleClockDivisor;
	wire [15:0] RampStartingLevel;
	wire [15:0] RampStoppingLevel;
	wire [15:0] BlankingLevel;
	wire [15:0] RampRateClockDivisor;
	wire [15:0] PingFrequency;
	wire [15:0] PingDuration;
	
	Sonar1Chan_Params U1 (.Clock50MHz           (Clock),
						  .MsgByte              (MsgByte),
						  .ByteAddrClear        (ByteAddrClear),
						  .ByteWrite            (ByteWrite),
						  .MsgComplete          (MsgComplete),
						  .SampleClockDivisor   (SampleClockDivisor),
						  .RampStartingLevel    (RampStartingLevel), 
						  .RampStoppingLevel    (RampStoppingLevel), 
						  .BlankingLevel        (BlankingLevel),     
						  .RampRateClockDivisor (RampRateClockDivisor),
						  .PingFrequency        (PingFrequency), 
						  .PingDuration         (PingDuration)); 

	//*************************************************

    //
    // test bench initializations
    //    
	
	reg  [7:0] MessageBytes [0:13];
	
    initial
    begin
        MessageBytes [0]  = 8'h01;  MessageBytes [1]  = 8'h02;  MessageBytes [2]  = 8'h03; MessageBytes [3]  = 8'h04; 
		MessageBytes [4]  = 8'h05;  MessageBytes [5]  = 8'h06;  MessageBytes [6]  = 8'h07; MessageBytes [7]  = 8'h08; 
        MessageBytes [8]  = 8'h09;  MessageBytes [9]  = 8'h0a;  MessageBytes [10] = 8'h0b; MessageBytes [11] = 8'h0c; 
		MessageBytes [12] = 8'h0d;  MessageBytes [13] = 8'h0e;
    end		

    initial
    begin
        $display ("module: %m");
    //    $monitor ($time, " state %d, msgByte 0x%h, WriteByte %h", U1.state, U1.MessageByte, U1.WriteDataByte);
                            
    end
    		         
    //
    // clock period
    //
    always
        #10 Clock = ~Clock;  
        

    integer i;
		
    initial
    begin
		#103 ByteAddrClear <= 1;
		#20  ByteAddrClear <= 0;
				
		//******************************************
		//
		// Load message bytes
		//
        for (i=0; i<14; i=i+1)
        begin
			#80 MsgByte <= MessageBytes [i];                    
			#80 ByteWrite <= 1'b1;
			#20 ByteWrite <= 1'b0;
        end

		#10 MsgComplete <= 1'b1;
		#20 MsgComplete <= 1'b0;
		
		//***********************************************************
		
		#100 ByteAddrClear <= 1;
		#20  ByteAddrClear <= 0;
		
		#10_000 MessageBytes [0] = 8'haa;
		#50     MessageBytes [6] = 8'hbb;
		#50     MessageBytes [13] = 8'hcc;
		
        for (i=0; i<14; i=i+1)
        begin
			#80 MsgByte <= MessageBytes [i];                    
			#80 ByteWrite <= 1'b1;
			#20 ByteWrite <= 1'b0;
        end

		#10 MsgComplete <= 1'b1;
		#20 MsgComplete <= 1'b0;
		
		
		#20_000 $finish;    
    end
	

endmodule








