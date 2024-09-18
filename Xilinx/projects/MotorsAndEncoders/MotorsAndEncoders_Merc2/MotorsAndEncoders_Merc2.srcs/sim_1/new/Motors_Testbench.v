
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	



/*
    Motors_Testbench
*/    

`timescale 1ns / 1ps

module Motors_Testbench;

    reg clearBar = 1;    
    reg Clock50MHz = 0;
    
    reg [7:0] MsgByte;
    reg       MsgBit;
    reg       InputShiftClock;
    reg       InputByteDone;
    
    wire PWM1, Dir1, PWM2, Dir2;
    
    reg [7:0] HeaderBytes [0:2];
    reg [7:0] ProfileBytes [0:19];
    
    
    MotorsAndEncoders U1 (.InputBit (MsgBit),  
                          .InputShiftClock (InputShiftClock),
                          .InputByteDone   (InputByteDone),
                          
                          .PWM1 (PWM1),
                          .Dir1 (Dir1),
                          .PWM2 (PWM2),
                          .Dir2 (Dir2),
                          
                          .ProfileDone (),
                                                   
                          .ClearBar (clearBar),    // active low
                          .Clock50MHz (Clock50MHz));
                                                                                                
    //
    // test bench initializations
    //    
    initial
    begin
            $display ("module: %m");
//          $monitor ($time, " state %d: %d, %d, %d %d %d",
//                U1.state, U1.Clock12MHz, U1.SRun, U1.SClear, U1.SStop, U1.SLoad);
                       
            HeaderBytes [0] = 8'hAB;
            HeaderBytes [1] = 8'h2;  // ID
            HeaderBytes [2] = 8'd23; // byte count
                               
            ProfileBytes [0] = 8'h11; ProfileBytes [1] = 8'h21;
            ProfileBytes [2] = 8'h12; ProfileBytes [3] = 8'h22;

            ProfileBytes [4] = 8'h13; ProfileBytes [5] = 8'h23;
            ProfileBytes [6] = 8'h14; ProfileBytes [7] = 8'h24;
        
            ProfileBytes [8]  = 8'h15; ProfileBytes [9]  = 8'h25;
            ProfileBytes [10] = 8'h16; ProfileBytes [11] = 8'h26;

            ProfileBytes [12] = 8'h17; ProfileBytes [13] = 8'h27;
            ProfileBytes [14] = 8'h18; ProfileBytes [15] = 8'h28;

            ProfileBytes [16] = 8'h19; ProfileBytes [17] = 8'h29;
            ProfileBytes [18] = 8'h1a; ProfileBytes [19] = 8'h2a;
                                
            MsgByte = 8'b0;
            InputShiftClock = 0;
            InputByteDone = 0;
    
            clearBar = 1'b0; 
        #50 clearBar = 1;  
    end
    
    //
    // clock period
    //
    always
        #5 Clock50MHz = ~Clock50MHz;  
        
    //
    // test run
    //

    integer i, j;

    initial
    begin
        
        #112   // wait for "clear" to go away

            // send 3 header bytes
            for (j=0; j<3; j=j+1)
            begin
                MsgByte = HeaderBytes [j]; // Sync byte
                
                for (i=0; i<8; i=i+1)
                begin
                    MsgBit <= MsgByte [7 - i];
    
                    #100 InputShiftClock <= 1;         
                    #100 InputShiftClock <= 0;         
                end
    
                #100 InputByteDone <= 1;
                #100 InputByteDone <= 0;
            end
            
            
            // send 20 profile bytes
            for (j=0; j<20; j=j+1)
            begin
                MsgByte = ProfileBytes [j]; // Sync byte
                
                for (i=0; i<8; i=i+1)
                begin
                    MsgBit <= MsgByte [7 - i];
    
                    #100 InputShiftClock <= 1;         
                    #100 InputShiftClock <= 0;         
                end
    
                #100 InputByteDone <= 1;
                #100 InputByteDone <= 0;
            end
            
            
        #1000 $finish;
    end
    

endmodule
