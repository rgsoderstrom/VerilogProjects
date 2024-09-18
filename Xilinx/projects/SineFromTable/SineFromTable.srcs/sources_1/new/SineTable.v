/*
    SineTable.v
*/
    
`timescale 1ns / 1ps

module SineTable (input [15:0] phase, // fraction of a cycle. Bit 15 = 0.5, Bit 14 = 0.25, etc
                  output [15:0] sine, // (sin (phase) + 0.5) * 65535
                  input  Trigger,
                  input  Clock,
                  output Done,
                  output Zero);
                                   
    wire [15:0] offsetPhase; // adjust passed-in phase so sin (0) gives expected results
    assign offsetPhase = phase + (8 << 11); 
        
    wire [15:0] latchedTheta;
    assign Zero = (latchedTheta == (8 << 11));
    
    wire        fallingFlag;
    wire [3:0]  index;    
    wire [10:0] fraction;
    
    assign fallingFlag = latchedTheta [15];
    assign index       = latchedTheta [14:11];
    assign fraction    = latchedTheta [10:0];
        
    reg  [15:0] SineTable [0:15]; // == sin (index)
    reg  [15:0] StepTable [0:15]; // == sin (index+1) - sin (index), amount to add to get to next entry
    wire [15:0] SineTableOut;
    wire [15:0] StepTableOut;

    wire        loadTheta;
    wire        enableMult;
    wire        enableAdd;
    wire [15:0] stepProduct;
    
    ThetaRegister #(.Width (16))
                U1 (.Input (offsetPhase), .Clr (0), .Clk (Clock), .Load (loadTheta), .Output (latchedTheta));
      
    UnsignedMult #(.WidthA (16), .WidthB (11), .WidthOut (16))
               U2 (.out (stepProduct), .a (StepTableOut), .b (fraction), .Enable (enableMult), .Clock (Clock));    
                   
    AddSubt #(.Width (16))
          U3 (.out (sine), .a (SineTableOut), .b (stepProduct), .Enable (enableAdd), .SubtFlag (fallingFlag), .Clock (Clock));
          
    SineTableController 
          U4 (.Clock (Clock), .Trigger (Trigger), .LoadTheta (loadTheta), .MultEnable (enableMult), .AddEnable (enableAdd), .Done (Done));                            
          
    initial
    begin
        SineTable [0]  = 16'h0000;  SineTable [1]  = 16'h0275;  SineTable [2]  = 16'h09be;  SineTable [3]  = 16'h1592;  
        SineTable [4]  = 16'h257d;  SineTable [5]  = 16'h38e2;  SineTable [6]  = 16'h4f03;  SineTable [7]  = 16'h6706;  
        SineTable [8]  = 16'h7fff;  SineTable [9]  = 16'h98f8;  SineTable [10] = 16'hb0fb;  SineTable [11] = 16'hc71c;  
        SineTable [12] = 16'hda81;  SineTable [13] = 16'hea6c;  SineTable [14] = 16'hf640;  SineTable [15] = 16'hfd89;  

        StepTable [0]  = 16'h0275;  StepTable [1]  = 16'h0748;  StepTable [2]  = 16'h0bd4;  StepTable [3]  = 16'h0feb;  
        StepTable [4]  = 16'h1365;  StepTable [5]  = 16'h1621;  StepTable [6]  = 16'h1802;  StepTable [7]  = 16'h18f8;  
        StepTable [8]  = 16'h18f8;  StepTable [9]  = 16'h1802;  StepTable [10] = 16'h1621;  StepTable [11] = 16'h1365;  
        StepTable [12] = 16'h0feb;  StepTable [13] = 16'h0bd4;  StepTable [14] = 16'h0748;  StepTable [15] = 16'h0275;  
    end
     
    assign SineTableOut = SineTable [index];
    assign StepTableOut = StepTable [index];
    
//    always @ (posedge Clock)
//    begin

//    end    

endmodule
