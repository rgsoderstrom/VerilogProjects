/*
	Sonar1Chan_Params.v - parse parameters message
*/

`timescale 1ns / 1ps

module Sonar1Chan_Params #(parameter WW = 16) // WordWidth = 16 bits
                         (input wire Clock50MHz,
						  
						  input wire [7:0] MsgByte,       // from MsgRouter
						  input wire       NewMessage,    //   "
						  input wire       WriteByte,     //   "
						  input wire       MsgComplete,   //   "
						  
						  // ADC sample rate
						  output reg [WW-1:0] SampleClockDivisor,

					 	  // DAC1 TVG parameters 
						  output reg [WW-1:0] RampStartingLevel, // = InitialVoltage  * CountsPerVolt;  
						  output reg [WW-1:0] RampStoppingLevel, // = FinalVoltage    * CountsPerVolt;  
						  output reg [WW-1:0] BlankingLevel,     // = BlankingVoltage * CountsPerVolt;
						  output reg [WW-1:0] RampRateClockDivisor, // = 50e6 / RampRate;
					    //output reg [31:0]  RampRateClockDivisor, // = 50e6 / RampRate;
						 						 
    					  // DAC0 ping parameters 
						  output reg [WW-1:0] PingFrequency, // (FreqInHz / 190), see CORDIC.vhd
						  output reg [WW-1:0] PingDuration); // in clocks, duration at max level 
    
	// default values
	localparam _SampleClockDivisor   = 50_000_000 / 100_000;
	localparam _PingFrequency        = 40_200 / 190;        // (FreqInHz / 190), see CORDIC.vhd
	localparam _PingDuration         = 0.001 * 50_000_000;  // in clocks, duration at max level                 
	localparam _CountsPerVolt        = 1024 / 2.048;
	localparam _BlankingLevel        = 0.025 * _CountsPerVolt; // = BlankingVoltage * CountsPerVolt;
	localparam _RampStartingLevel    = 0.25  * _CountsPerVolt; // = InitialVoltage  * CountsPerVolt;                  
	localparam _RampStoppingLevel    = 1.25  * _CountsPerVolt; // = FinalVoltage    * CountsPerVolt;   
	localparam _RiseTime             = 0.020;                 // ramp start-to-stop time in seconds
	localparam _RampRate             = (_RampStoppingLevel - _RampStartingLevel) / _RiseTime;
	localparam _RampRateClockDivisor = 50_000_000 / _RampRate; // = 50e6 / RampRate;

	initial begin
		SampleClockDivisor   = _SampleClockDivisor;
		RampStartingLevel    = _RampStartingLevel;
		RampStoppingLevel    = _RampStoppingLevel;
		BlankingLevel        = _BlankingLevel;
		RampRateClockDivisor = _RampRateClockDivisor;
		PingFrequency        = _PingFrequency;
		PingDuration         = _PingDuration;
	end
	
	localparam PRAW = 3; // parameter RAM addr width
	
	reg  [PRAW-1:0] ParamReadAddr = 0;
	wire [15:0]     ParamReadData;
	reg             ParamRead;
	
    DualPortRAM2 #(.AddrWidth (PRAW)) 
               U1 (.Clk (Clock50MHz),
			   
                   .ByteClearAddr (NewMessage), 
                   .ByteWriteData (MsgByte),
                   .ByteWrite     (WriteByte),

                   .ByteReadData  (),
                   .ByteRead      (1'b0), 

                   .WordWriteAddr ('d0),
                   .WordWriteData ('d0),
                   .WordWrite     ('d0),

                   .WordReadAddr  (ParamReadAddr),
                   .WordReadData  (ParamReadData),
                   .WordRead      (ParamRead));
				   
    localparam Idle  = 'd0;				   
    localparam Clear = 'd1;				   
    localparam Read1 = 'd2;				   
    localparam Read2 = 'd3;				   
    localparam Read3 = 'd4;				   
    localparam Write = 'd5;				   
    localparam Test  = 'd6;	
    localparam Incr  = 'd7;				   

	localparam LastAddr = 3'd6;
	
	reg [2:0] state = Idle;

	always @(posedge Clock50MHz) begin
		case (state)
			Idle:  if (MsgComplete == 1) state <= Clear;
			Clear: begin ParamReadAddr <= 0; state <= Read1; end
			Read1: state <= Read2;
			Read2: state <= Read3;
			Read3: state <= Write;
			Write: state <= Test;
			Test:  begin if (ParamReadAddr == LastAddr) state <= Idle; else state <= Incr; end
			Incr:  begin ParamReadAddr <= ParamReadAddr + 1; state <= Read1; end
			
			default: state <= Idle;	
		endcase
	end
	
	always @ (*) begin
		ParamRead <= (state == Read1);
	end

	always @(posedge Clock50MHz) begin
	//always @(*) begin
		if (state == Write) begin
			case (ParamReadAddr)
				0: SampleClockDivisor    <= ParamReadData;
				1: RampStartingLevel     <= ParamReadData;
				2: RampStoppingLevel	 <= ParamReadData;
				3: BlankingLevel	 	 <= ParamReadData;
				4: RampRateClockDivisor	 <= ParamReadData;
				5: PingFrequency		 <= ParamReadData;
				6: PingDuration			 <= ParamReadData;
				default: 	;
			endcase
		end
	end
	
endmodule




