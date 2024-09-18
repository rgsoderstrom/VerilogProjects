
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	


`timescale 1ns / 1ps

module ShaftEncoderIF_Testbench;

    reg PhaseA, PhaseB;
    reg clk;
    reg clr;
    reg latch;
            
    localparam W = 8;
                
    wire [W-1:0] count;
    
    ShaftEncoderIF  #(.Width (W), 
                      .PrescalerWidth (2)) 
        sei (.PhaseA (PhaseA), .PhaseB (PhaseB), 
             .LatchedCount (count),
             .LatchCounter (latch),
             .Clock12MHz (clk), .Clear (clr));
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
    
        clk = 1'b0; 
        clr = 1'b1;  // active high
        latch = 1'b0;
        PhaseA = 0;
        PhaseB = 0;
                
        #40 clr = 0;
    end
    
    //
    // clock period
    //
    always
        #5 clk = ~clk; //toggle clk 

    //
    // test run
    //
    integer i;
    
    initial
    begin
        
        #3 
        for (i=0; i<4; i=i+1)
        begin    
            #100  PhaseA = 1;
            #100  PhaseB = 1;
            #100  PhaseA = 0;    
            #100  PhaseB = 0; 
        end
        
        #100 latch = 1; // 16  if PrescalerWidth == 0
        #10  latch = 0;
          
        for (i=0; i<1; i=i+1)
        begin
            #100  PhaseA = 1;
            #100  PhaseB = 1;
            #100  PhaseA = 0;    
            #100  PhaseB = 0;  
        end
        
        #100 latch = 1;  // 4  if PrescalerWidth == 0
        #10  latch = 0;
          
        #100  PhaseB = 1;    
        #100  PhaseA = 1;   
        #100  PhaseB = 0;    
        #100  PhaseA = 0;   
        #100  PhaseB = 1;    
        #100  PhaseA = 1;  
        #100  PhaseB = 0;    
        #100  PhaseA = 0;   
         
        #100 latch = 1;  // -8 if PrescalerWidth == 0
        #10  latch = 0;
          
        #100 $finish;
    end

endmodule


