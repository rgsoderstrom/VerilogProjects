/*
    Loopback_Processing.v
        - adds a constant to each memory word
*/

`timescale 1ns / 1ps

module Loopback_Processing #(parameter AddrBits = 6,
                             parameter DataBits = 16)
                            (input Clock,
                             input Clear,
                            
                             input  Run,
                             output reg Busy, // level, high while running
                             output reg Done, // pulse, one clock period wide when finished

                             output reg [DataBits-1:0] WriteData,
                             output reg                WriteCycle,
                             output reg [AddrBits-1:0] WriteAddr,
                         
                             input      [DataBits-1:0] ReadData, // Memory [WordAddr] after ReadCycle
                             output reg                ReadCycle,
                             output reg [AddrBits-1:0] ReadAddr);

    localparam Idle       = 4'd0;
	localparam Init       = 4'd1;
	localparam DoRead     = 4'd2;
	localparam ReadDelay  = 4'd3;
	localparam AddConst   = 4'd4;
	localparam DoWrite    = 4'd5;
	localparam WriteDelay = 4'd6;
	localparam NextAddr   = 4'd7;
	localparam TestDone   = 4'd8;
	localparam SetDone    = 4'd9;
    
    reg [3:0] state;
	
	localparam ReadDelayCount = 2;
	localparam WriteDelayCount = 2;
	
	reg [2:0] DelayCounter;
    
    initial
    begin
      state <= Idle;
    end
           
    always @(posedge Clock)
    begin
        if (Clear == 1)
        begin
          state <= Idle;
        end

        else begin
			case (state)
				Idle: 	   begin if (Run == 1) state <= Init; end
				Init:      begin ReadAddr <= 0; WriteAddr <= 0; state <= DoRead; end
				DoRead:    begin state <= ReadDelay; DelayCounter <= ReadDelayCount; end
				ReadDelay: begin if (DelayCounter == 0) state <= AddConst; else DelayCounter <= DelayCounter - 1; end
				AddConst:  begin WriteData <= ReadData + 16'h0102; state <= DoWrite; end
				DoWrite:   begin state <= WriteDelay; DelayCounter <= WriteDelayCount; end
				WriteDelay:begin if (DelayCounter == 0) state <= NextAddr; else DelayCounter <= DelayCounter - 1; end
				NextAddr:  begin ReadAddr <= ReadAddr + 1; WriteAddr <= WriteAddr + 1; state <= TestDone; end
				TestDone:  begin state <= (ReadAddr == 0 ? SetDone : DoRead); end
			    SetDone:   begin state <= Idle; end
			    
                default: state <= Idle;                  
            endcase                            
        end
	end

    always @(*)
    begin
        Busy       = (state != Idle);
		ReadCycle  = (state == DoRead);
        WriteCycle = (state == DoWrite);
        Done       = (state == SetDone);    
    end
                     
endmodule





