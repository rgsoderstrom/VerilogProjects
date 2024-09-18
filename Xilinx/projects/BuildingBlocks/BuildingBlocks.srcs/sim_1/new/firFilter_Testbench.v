
/*
    firFilter_Testbench.v
*/

`timescale 1ns / 1ps

module firFilter_Testbench;

    localparam DataWidth = 10;
    
	reg  clk = 0;
	reg  clr = 0;
	wire ready;
	reg  load = 0;
	wire sLoad;
    reg  signed [DataWidth-1:0] inputData = 0; // -1 * 10'd5; // 10'h3f6;
    wire signed [DataWidth-1:0] filteredData;
    
    reg signed [DataWidth-1:0] SineTable [0:24];
    reg [4:0] TableIndex = 0;
     
    initial
    begin
        SineTable [0]  = 10'h000;  
        SineTable [1]  = 10'h07f;  
        SineTable [2]  = 10'h0f6;  
        SineTable [3]  = 10'h15e;  
        SineTable [4]  = 10'h1b0;  
        SineTable [5]  = 10'h1e6;  
        SineTable [6]  = 10'h1fe;  
        SineTable [7]  = 10'h1f6;  
        SineTable [8]  = 10'h1cf;  
        SineTable [9]  = 10'h18a;  
        SineTable [10] = 10'h12c;  
        SineTable [11] = 10'h0bc;  
        SineTable [12] = 10'h040;  
        SineTable [13] = 10'h3c0;  
        SineTable [14] = 10'h344;  
        SineTable [15] = 10'h2d4;  
        SineTable [16] = 10'h276;  
        SineTable [17] = 10'h231;  
        SineTable [18] = 10'h20a;  
        SineTable [19] = 10'h202;  
        SineTable [20] = 10'h21a;  
        SineTable [21] = 10'h250;  
        SineTable [22] = 10'h2a2;  
        SineTable [23] = 10'h30a;  
        SineTable [24] = 10'h381;  
    end

    SyncOneShot U1 (.trigger (load), .clk (clk), .clr (clr), .Q (sLoad));
        
    firFilter1 #(.DataWidth (DataWidth))
            U2  (.Clock (clk),
                 .Clear (clr),
                 .Ready (ready),
                 .Load (sLoad),
                 .InputData (inputData),  
                 .FilteredData (filteredData));

    //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");
        //$monitor ($time, " EventCounter.Count = %d, EventCounter.Zero = %d", U1.Count, U1.Zero);
        
        clk   = 1'b0;
        clr   = 1'b1; // clear is active high

        #50 clr = 0; 
    end

    //
    // clock period
    //
    always
        #5 clk <= ~clk; //toggle clk 
        
    //
    // test run
    //
    integer i;
    
    initial
    #202  // wait for initialization to end and start between clock edges
    
    begin
        for (i=0; i<70; i=i+1)
        begin                             
            inputData = SineTable [TableIndex]; #50;
            load = 1; #50;   // allow enough clocks for "ready" to go high between loads
            load = 0; #180;

            TableIndex = TableIndex + 1;
            
            if (TableIndex > 24)
                TableIndex = TableIndex - 25;
        end
        

        #400 
            $finish;
    end
endmodule
