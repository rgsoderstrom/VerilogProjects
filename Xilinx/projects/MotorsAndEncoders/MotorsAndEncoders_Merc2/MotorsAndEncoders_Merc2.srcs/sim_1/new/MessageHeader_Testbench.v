
/*
 	remember 100ns hard "Clear" on sim start
*/

/*
    MessageHeader_Testbench.v
*/
    
`timescale 1ns / 1ps

module MessageHeader_Testbench;

    wire [7:0] dataOut;
    wire empty;
    
    reg   ReadNext = 0;
    reg   NewHeader = 0;
    wire  readNext;
    wire  newHeader;
    
    reg  Clear = 0;
    reg  Clock = 0;
    
    integer i;
    
    MessageHeader #(.DataWidth (8),                        
                    .MsgID (8'h45),
                    .ByteCount (8'h67))
                U1 (.DataOut (dataOut),                        
                    .Empty (empty),
                    .ReadNext (readNext),
                    .NewHeader (newHeader),
                    .Clear (Clear),
                    .Clock (Clock));    
                    
    SyncOneShot 
        U2 (.trigger (NewHeader), .clk (Clock), .clr (Clear), .Q (newHeader)),
        U3 (.trigger (ReadNext),  .clk (Clock), .clr (Clear), .Q (readNext));
                                


    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
       // $monitor ($time, " state %d: %d %d %d",
             //   U1.state,  profileDone, U1.PwmLoad, U1.U4.Count);
                        
        Clear = 1'b1;
        #50 Clear = 0;  // clear is active high
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
        
        for (i=0; i<3; i=i+1)
        begin
            #50 NewHeader = 1;
            #20 NewHeader = 0;
            
            #50 ReadNext = 1;
            #20 ReadNext = 0;
            
            #50 ReadNext = 1;
            #20 ReadNext = 0;
            
            #50 ReadNext = 1;
            #20 ReadNext = 0;
        end
        
        #300 $finish;

    end
    
endmodule
