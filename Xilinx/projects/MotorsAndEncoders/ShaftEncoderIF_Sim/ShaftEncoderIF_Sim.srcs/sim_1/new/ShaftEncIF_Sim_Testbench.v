
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	



/*
    ShaftEncIF_Sim_Testbench
*/    

`timescale 1ns / 1ps

module ShaftEncIF_Sim_Testbench;

    reg Clock = 0, Clear = 1;
    reg countUp = 0;
    reg countDown = 0;
    reg latchCounter;
    wire half;
    wire [7:0] Count;
    
    ShaftEncoderIF_Sim #(.Width (8),
                         .MaxCount (8'd10),
                         .AllowNeg (0))
                      U1 (.PhaseA (countUp),
                          .PhaseB (countDown),
                          .Clock12MHz (Clock),
                          .Clear (Clear), // active high
                          .LatchCounter (latchCounter),
                          .Half (half),
                          .LatchedCount (Count));
                              //
    // test bench initializations
    //    
    
    initial
    begin
        $display ("module: %m");
        latchCounter  = 1'b0;
        #50 Clear = 0;  
    end
    
    //
    // clock period
    //
    always
        #5 Clock = ~Clock; //toggle clk 
        

    //
    // test run
    //
    integer i;
    
    initial
    begin
        #55
        
        countUp = 1;
        countDown = 0;
        
        for (i=0; i<12; i=i+1)
        begin
            #50 latchCounter = 1'b1;
            #10 latchCounter = 1'b0;                
        end
        
        
        countUp = 0;
        countDown = 0;
        
        for (i=0; i<4; i=i+1)
        begin
            #50 latchCounter = 1'b1;
            #10 latchCounter = 1'b0;                
        end
        
        countUp = 0;
        countDown = 1;
        
        for (i=0; i<25; i=i+1)
        begin
            #50 latchCounter = 1'b1;
            #10 latchCounter = 1'b0;                
        end
        
        #50 $finish;
    end
                              

endmodule
