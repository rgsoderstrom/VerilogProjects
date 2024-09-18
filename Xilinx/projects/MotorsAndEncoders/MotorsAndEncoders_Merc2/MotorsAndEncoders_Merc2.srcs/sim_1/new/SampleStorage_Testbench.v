
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	


/*
    SampleStorage_Testbench
*/

`timescale 1ns / 1ps

module SampleStorage_Testbench;

    reg Clear = 0;    
    reg Clock = 0;

    reg [7:0] Counts1 [0:16];
    reg [7:0] Counts2 [0:16];
    integer index = 0, select = 0;
    integer i;
                
    reg  ssWrite = 0;
    reg  ssRead  = 0;
    wire SSWrite;
    wire SSRead;
    
    wire SSFull,  SSEmpty;
    wire [7:0] SSDataOut;
    
    SampleStorage #(.AddrWidth (4))  // FIFO capacity = (2 ^ AddrWidth)
            U1     (.EncCounts1 (Counts1 [select]),
                    .EncCounts2 (Counts2 [select]),
                    .Write     (SSWrite),
                    .Read      (SSRead),
                    .SampleOut (SSDataOut),
                    .Full      (SSFull),
                    .Empty     (SSEmpty),
                    .Clear     (Clear),
                    .Clock     (Clock));

    SyncOneShot 
        U2 (.trigger (ssWrite), .clk (Clock), .clr (Clear), .Q (SSWrite)),
        U3 (.trigger (ssRead),  .clk (Clock), .clr (Clear), .Q (SSRead));
                                
    //
    // test bench initializations
    //    
    initial
    begin
            $display ("module: %m");
//          $monitor ($time, " state %d: %d, %d, %d %d %d",
//                U1.state, U1.Clock12MHz, U1.SRun, U1.SClear, U1.SStop, U1.SLoad);
            
            for (i=0; i<16; i=i+1)
            begin
                Counts1 [i] = 8'h10 + i; 
                Counts2 [i] = 8'h20 + i;
            end
                       
            Counts1 [16] = 0;     
            Counts2 [16] = 0;           

            Clear = 1;
        #50 Clear = 0;
    end

    //
    // clock period
    //
    always
        #5 Clock = ~Clock;  
        
    //
    // test run
    //

    initial
    begin
        
        #112   // wait for "clear" to go away
        
    //******************************************************************

        for (index=0; index<4; index=index+1) // 4 was 8
        begin
            #100 ssWrite <= 1;
            #50  ssWrite <= 0;
            #100 select <= select + 1;
        end

        for (index=0; index<8; index=index+1) // 4 was 8
        begin
            #100 ssRead <= 1;
            #50  ssRead <= 0;
        end

        #300 $finish;
    end
    
endmodule
