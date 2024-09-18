
/*
    MessageReader_Testbench
*/

`timescale 1ns / 1ps

module MessageReader_Testbench;

    reg Clr = 0;    
    reg Clk = 0;

    reg [7:0] nextWriteWord = 8'd0;
    reg write = 0;
    
    wire msgComplete;
    wire [7:0] msgID;
    wire [7:0] msgWord;
    
    reg [4:0] readAddr = 5'b00000;
    wire [4:0] byteCount;
    
    MessageReader U1 (.Input (nextWriteWord), 
                      .Write (write),
                      .MessageComplete (msgComplete),
                      .ByteCount (byteCount),
                      .MessageID (msgID),
                      .MessageWord (msgWord), 
                      .ReadAddr (readAddr),
                      .Clock (Clk),
                      .Clear (Clr));

    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
       // $monitor ($time, " state %d: %d %d %d",
             //   U1.state,  profileDone, U1.PwmLoad, U1.U4.Count);
                        
        Clr = 1'b1;
        #50 Clr = 0;  // clear is active high
    end
    
    //
    // clock period
    //
    always
        #5 Clk = ~Clk;  
        
    //
    // test run
    //

    initial
    begin
        #62   // wait for "clear" to go away
        nextWriteWord = 8'hAB;
        #50 write = 1;
        #10 write = 0;

        #10 nextWriteWord = 8'h12;  // ID
        #50 write = 1;
        #10 write = 0;

        #10 nextWriteWord = 8'h05; // byte count
        #50 write = 1;
        #10 write = 0;

        #10 nextWriteWord = 8'h11;
        #50 write = 1;
        #10 write = 0;

        #10 nextWriteWord = 8'h22;
        #50 write = 1;
        #10 write = 0;

        #10 nextWriteWord = 8'hEE; // will be discarded
        #50 write = 1;
        #10 write = 0;

        #100 nextWriteWord = 8'hAB;
        #50 write = 1;
        #10 write = 0;

        #10 nextWriteWord = 8'hcd;
        #50 write = 1;
        #10 write = 0;

        #10 nextWriteWord = 8'h03;
        #50 write = 1;
        #10 write = 0;

        #10 nextWriteWord = 8'hEE; // will be discarded
        #50 write = 1;
        #10 write = 0;

        #200 readAddr = 0;
        #200 readAddr = 1;
        #200 readAddr = 2;
        #200 readAddr = 3;
        #200 readAddr = 4;

        #300 $finish;
    end    


endmodule
