
/*
    firFilter_Testbench.v
*/

`timescale 1ns / 1ps

module firFilter_Testbench;

    localparam ClockFreq  = 50_000_000;
    localparam SampleRate = 25_000; // samples per second
    localparam SignalFreq =  2_500; // Hz 

    localparam CordicDataWidth  = 12;
    localparam SignedDataWidth  = 16;
    localparam FractionBits     = 10;
    
	
	reg  Clock50MHz = 0;
	reg  clr = 0;
	wire ready;
    
    //***********************************************************************
    
    reg [15:0] frequency = SignalFreq / 190;

    // signal oscillator. Unsigned right out of CORDIC. Converted to signed for subsequent operations
    wire        [CordicDataWidth-1:0] unsigned_Signal;
    wire signed [SignedDataWidth-1:0] signed_Signal;
    wire signed [SignedDataWidth-1:0] filteredData;
    
	
  //assign signed_Signal [FractBits-1:0] = unsigned_Signal [CordicDataWidth-1 -: FractionBits];
    assign signed_Signal [8:0] = unsigned_Signal [10:2];
	
    assign signed_Signal [15] = unsigned_Signal [11] ^ 1'b1;    
    assign signed_Signal [14] = unsigned_Signal [11] ^ 1'b1;    
    assign signed_Signal [13] = unsigned_Signal [11] ^ 1'b1;    
    assign signed_Signal [12] = unsigned_Signal [11] ^ 1'b1;    
    assign signed_Signal [11] = unsigned_Signal [11] ^ 1'b1;    
    assign signed_Signal [10] = unsigned_Signal [11] ^ 1'b1;    
    assign signed_Signal [9]  = unsigned_Signal [11] ^ 1'b1;    
	
	
	
	
    
    reg signed [15:0] Sample;
    wire              SampleClock;
    
    ClockDivider #(.Divisor (ClockFreq / SampleRate))
 			   U1 (.FastClock (Clock50MHz),  
                   .Clear     (clr),
                   .SlowClock (),
				   .Pulse     (SampleClock));     // single pulse at SlowClock rate
	
	always @ (posedge Clock50MHz)
	   if (SampleClock == 1)
	       Sample <= signed_Signal;
	       			   
    //***********************************************************************

    Mercury2_CORDIC
        U2 (.clk_50MHz (Clock50MHz), .cor_en (1'b1), .phs_sft (frequency),  .outVal (unsigned_Signal));
        
    firFilter2 //#(.DataWidth (SignedDataWidth))
            U3  (.Clock (Clock50MHz),
                 .Clear (clr),
                 .Ready (ready),
                 .Load  (SampleClock),
                 .InputData    (Sample),  
                 .FilteredData (filteredData));
    
    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");
        //$monitor ($time, " EventCounter.Count = %d, EventCounter.Zero = %d", U1.Count, U1.Zero);
        
        Clock50MHz = 1'b0;
        clr        = 1'b1; // clear is active high

        #50 clr = 0; 
    end

    //
    // clock period
    //
    always
        #10 Clock50MHz <= ~Clock50MHz; //toggle clk 
        
    //
    // test run
    //
//    always begin
//
//    end
        

    //    #400 
    //        $finish;

endmodule
