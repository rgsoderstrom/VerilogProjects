
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	


`timescale 1ns / 1ps

module MandE_testbench;

    reg PhaseA1 = 0;
    reg PhaseA2 = 0;
    reg PhaseB1 = 0;
    reg PhaseB2 = 0;

    reg DataIn = 0;   // 1 bit, from Arduino
    reg SampleEnc = 0;
    reg ShiftOut = 0;
    reg LoadPWM = 0;
    reg ShiftIn = 0;
    reg Clr = 0;       // active high, connected to button 0
    reg CLK12MHZ = 0;

    wire DataOut;
    reg [21:0] serialIn = 0;
    
    wire [9:0] E1 = serialIn [21 : 12];
    wire [9:0] E2 = serialIn [11 : 2];
    wire P1 = serialIn [1];
    wire P2 = serialIn [0];
    wire interrupt = 0;
    
    reg [7:0] serialOut = 0; // PWM values

    
    MotorsAndEncoders ME (.PhaseA1 (PhaseA1), .PhaseB1 (PhaseB1), .PhaseA2 (PhaseA2), .PhaseB2 (PhaseB2),
                          .PWM1Out (PWM1Out), .PWM2Out (PWM2Out), .DataOut (DataOut), .DataIn (DataIn),
                          .SampleEnc (SampleEnc), .ShiftOut (ShiftOut), .LoadPWM (LoadPWM), .ShiftIn (ShiftIn),
                          .triggerInterrupt (interrupt),
                          .Clr (Clr), .CLK12MHZ (CLK12MHZ));
                       
    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        Clr = 1'b1;
        #50 Clr = 0;  // clear is active high
    end
    
    //
    // clock period
    //
    always
        #5 CLK12MHZ = ~CLK12MHZ;  
        

    //
    // test run
    //
    
    //
    // stimulate the shaft encoder interfaces, then shift out their contents
    //
    /***********
    initial
    begin
        #82 
        for (integer i=0; i<4; i=i+1)
        begin
            #40 PhaseA1 = 1'b1;
                PhaseB2 = 1'b1;
            #40 PhaseB1 = 1'b1;
                PhaseA2 = 1'b1;
            #40 PhaseA1 = 1'b0;
                PhaseB2 = 1'b0;
            #40 PhaseB1 = 1'b0;
                PhaseA2 = 1'b0;
                        
            #40 PhaseA1 = 1'b1;
            #40 PhaseB1 = 1'b1;
            #40 PhaseA1 = 1'b0;
            #40 PhaseB1 = 1'b0;                        
        end
               
        //------------------------------       
               
        //#40 PhaseA1 = 1'b1;
               
        //------------------------------       
               
        #40 SampleEnc = 1'b1;
        #40 SampleEnc = 1'b0;
        
        #40 serialIn = 0;
        
        for (integer i=0; i<22; i=i+1)
        begin
            #20 serialIn [21-i] = DataOut;
            #20 ShiftOut = 1;
            #20 ShiftOut = 0;
        end
        
        #40 SampleEnc = 1'b1;
        #40 SampleEnc = 1'b0;
        
        #40 serialIn = 0;

        
        for (integer i=0; i<22; i=i+1)
        begin
            #20 serialIn [21-i] = DataOut;
            #20 ShiftOut = 1;
            #20 ShiftOut = 0;
        end
        
    end
    ************/

    //
    // Shift data into PWMs
    //
    /*****/
    initial
    begin
        serialOut [7:4] = 4'h3;
        serialOut [3:0] = 4'hf;
        
        #82 for (integer i=0; i<8; i=i+1)
        begin
            DataIn = serialOut [7-i];
            #40 ShiftIn = 1;
            #40 ShiftIn = 0;
        end

        #40 LoadPWM = 1;
        #40 LoadPWM = 0;            
    end
    /*****/
    
endmodule



