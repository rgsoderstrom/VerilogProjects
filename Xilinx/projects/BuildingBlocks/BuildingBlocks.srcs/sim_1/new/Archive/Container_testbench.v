
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	


`timescale 1ns / 1ps

module Container_testbench;

    localparam Width = 8;
    
    reg [Width-1:0] A;

    reg Load;
    reg Shift1;
    reg Clear;
    reg CLK;

    wire ReadyToLoad;
    wire firstBit;
    wire lastBit;
    wire outputBit;
    
    
    SerializerPtoS #(.Width (Width))
         ParallelToSerial (.Input (A),
                           .Clr (Clear), // sync, active high
                           .Clk (CLK),   // pos edge triggered
                           .Ready (ReadyToLoad),
                           .Load (Load),
                           .Shift (Shift1),
				           .FirstBit (firstBit),  // true when OutputBit is first bit of Input
				           .LastBit (lastBit),    //  "     "      "     "  last   "   "   "						
                           .OutputBit (outputBit));
                   
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
    
        CLK = 1'b0; 
        Clear = 1'b1;  // active high
        A = 8'b10110001;

        Load = 1'b0;
        Shift1 = 1'b0;
        
        #20 Clear = 0;  // de-assert clear
    end
    
    //
    // clock period
    //
    always
        #5 CLK = ~CLK; //toggle clk 
                   
    initial
    begin      
        #62 Load = 1;
        #10 Load = 0;     
         
		for (integer count=0; count<8; count = count + 1)
		begin
			#40  Shift1 = 1;
			#10  Shift1 = 0;
		end

		A = 8'b10101011;
        #10 Load = 1;
        #10 Load = 0;     
         
		for (integer count=0; count<8; count = count + 1)
		begin
			#40  Shift1 = 1;
			#10  Shift1 = 0;
		end
		
		
    end
                   
endmodule
