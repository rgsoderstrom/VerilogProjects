/*
    LocalOscIQ
*/

`timescale 1ns / 1ps

module LocalOscIQ #(parameter _PhaseStep = 16'h671e)
                   (input  wire Clock,
                    input  wire Clear,
                    input  wire Step,
                    output wire signed [31:0] I, // (1, 7, 24) fixed point
                    output wire signed [31:0] Q,
                    output reg  Valid);

    localparam PhaseWidth         = 16; // this many bits in BAM (binary angle measurement) phase values    
    localparam TableAddrWidth     = 5;  // sine & step lookup tables    
    localparam IndexFractionWidth = PhaseWidth - TableAddrWidth;
    
    // shorter aliases    
    localparam PW = PhaseWidth;
    localparam TW = TableAddrWidth;
    localparam IW = IndexFractionWidth;

    //****************************************************

    reg [15:0] PhaseStep = _PhaseStep; // unsigned BAM
    
    reg  LoadSinPhase = 0;
    reg  [PW-1:0] SinePhase = 16'b0;
    wire [PW-1:0] CosinePhase = SinePhase + 16'h4000;
    reg           PhaseSelect = 0;
    wire [PW-1:0] Phase;
    assign Phase = (PhaseSelect == 0 ? SinePhase : CosinePhase);
    
    wire [TW-1:0] TableIndex    = Phase [PW-1-:TW];  // [15:11] ; //
    wire [IW-1:0] IndexFraction = Phase [PW-1-TW:0]; // [10:0] ; //
    
    reg  ReadSine = 0, ReadStep = 0;
    reg  signed  [31:0] SineTableOut, StepTableOut;
    wire signed  [31:0] Increment; 


    reg signed [31:0] Sine, Cosine; 
    reg LoadSine = 0, LoadCosine = 0;
    reg RunAdd = 0, RunMult = 0;
    
    assign I = Sine;
    assign Q = Cosine;    
    
    wire signed [11:0] TableFraction; // will always be 0 or positive
    assign TableFraction [11] = 1'b0; 
    assign TableFraction [10:0] = IndexFraction; 

//    wire signed [31:0] TableFraction; // will always be 0 or positive
//    assign TableFraction [31:24] = 8'b0; 
//    assign TableFraction [23:13] = IndexFraction; 
//    assign TableFraction [12:0]  = 13'b0; 

    //***********************************************************************

    localparam TableSize = (1 << TW);        
    reg signed [31:0] SineTable [0:TableSize-1]; // == sin (index)
    reg signed [31:0] StepTable [0:TableSize-1]; // == sin (index+1) - sin (index), amount to add to get to next entry

    always @ (posedge Clock) if (LoadSinPhase == 1) SinePhase   <= SinePhase + PhaseStep;
         
    always @ (posedge Clock) if (ReadSine == 1) SineTableOut <= SineTable [TableIndex];     
    always @ (posedge Clock) if (ReadStep == 1) StepTableOut <= StepTable [TableIndex];     

    initial
    begin
        SineTable [0]  = 32'h00000000;  SineTable [1]  = 32'h0031f170;  SineTable [2]  = 32'h0061f78a;  SineTable [3]  = 32'h008e39d9;  
        SineTable [4]  = 32'h00b504f3;  SineTable [5]  = 32'h00d4db31;  SineTable [6]  = 32'h00ec835e;  SineTable [7]  = 32'h00fb14be;  
        SineTable [8]  = 32'h01000000;  SineTable [9]  = 32'h00fb14be;  SineTable [10] = 32'h00ec835e;  SineTable [11] = 32'h00d4db31;  
        SineTable [12] = 32'h00b504f3;  SineTable [13] = 32'h008e39d9;  SineTable [14] = 32'h0061f78a;  SineTable [15] = 32'h0031f170;  
        SineTable [16] = 32'h00000000;  SineTable [17] = 32'hffce0e90;  SineTable [18] = 32'hff9e0876;  SineTable [19] = 32'hff71c627;  
        SineTable [20] = 32'hff4afb0d;  SineTable [21] = 32'hff2b24cf;  SineTable [22] = 32'hff137ca2;  SineTable [23] = 32'hff04eb42;  
        SineTable [24] = 32'hff000000;  SineTable [25] = 32'hff04eb42;  SineTable [26] = 32'hff137ca2;  SineTable [27] = 32'hff2b24cf;  
        SineTable [28] = 32'hff4afb0d;  SineTable [29] = 32'hff71c627;  SineTable [30] = 32'hff9e0876;  SineTable [31] = 32'hffce0e90;  

        StepTable [0]  = 32'h0031f170;  StepTable [1]  = 32'h0030061a;  StepTable [2]  = 32'h002c424f;  StepTable [3]  = 32'h0026cb1a;  
        StepTable [4]  = 32'h001fd63e;  StepTable [5]  = 32'h0017a82d;  StepTable [6]  = 32'h000e9160;  StepTable [7]  = 32'h0004eb42;  
        StepTable [8]  = 32'hfffb14be;  StepTable [9]  = 32'hfff16ea0;  StepTable [10] = 32'hffe857d3;  StepTable [11] = 32'hffe029c2;  
        StepTable [12] = 32'hffd934e6;  StepTable [13] = 32'hffd3bdb1;  StepTable [14] = 32'hffcff9e6;  StepTable [15] = 32'hffce0e90;  
        StepTable [16] = 32'hffce0e90;  StepTable [17] = 32'hffcff9e6;  StepTable [18] = 32'hffd3bdb1;  StepTable [19] = 32'hffd934e6;  
        StepTable [20] = 32'hffe029c2;  StepTable [21] = 32'hffe857d3;  StepTable [22] = 32'hfff16ea0;  StepTable [23] = 32'hfffb14be;  
        StepTable [24] = 32'h0004eb42;  StepTable [25] = 32'h000e9160;  StepTable [26] = 32'h0017a82d;  StepTable [27] = 32'h001fd63e;  
        StepTable [28] = 32'h0026cb1a;  StepTable [29] = 32'h002c424f;  StepTable [30] = 32'h0030061a;  StepTable [31] = 32'h0031f170;  
    end
    
    wire signed [31:0] Interpolated;
    always @ (posedge Clock) if (LoadSine   == 1) Sine   <= Interpolated;     
    always @ (posedge Clock) if (LoadCosine == 1) Cosine <= Interpolated;     
    
    //**********************************************************************************
        
//    FixedPoint Add  (.Clock  (Clock),
//                     .Enable (RunAdd),
//                     .Clear  (Clear),
//                     .a      (SineTableOut),
//                     .b      (Increment),
//                     .Sum  (Interpolated),
//                     .Diff (),
//                     .Prod ());

    localparam FixedPtWidth = 32;
    localparam FixedPtFract = 24;
    
    reg signed [FixedPtWidth:0] fullSum;                    
    assign Interpolated  = fullSum  [FixedPtWidth-1:0];
    
    always @(posedge Clock) begin
        if (Clear == 1) begin
            fullSum  <= 0;
        end 
        else if (RunAdd == 1) begin
            fullSum  <= SineTableOut + Increment;
        end
    end
    
    //**********************************************************************************
        
//    FixedPoint Mult (.Clock  (Clock),
//                     .Enable (RunMult),
//                     .Clear  (Clear),
//                     .a      (StepTableOut),
//                     .b      (TableFraction),
//                     .Sum  (),
//                     .Diff (),
//                     .Prod (Increment));


//    reg signed [2*FixedPtWidth-1:0] fullProd;    
//    assign Increment = fullProd >> FixedPtFract; 

    reg signed [32+11-1:0] fullProd;    
    assign Increment = fullProd >> 11; 

    always @(posedge Clock) begin
        if (Clear == 1) begin
            fullProd <= 0;
        end 
        else if (RunMult == 1) begin
            fullProd <= StepTableOut * TableFraction;
        end
    end






                     
    localparam Idle   = 5'd0;                         
    localparam Phase1 = 5'd1;    
    localparam Table1 = 5'd3;                     
    localparam Mult1  = 5'd4;                     
    localparam Add1   = 5'd5;                     
    localparam Load1  = 5'd6;  
                           
    localparam Phase2 = 5'd7;        
    localparam Table2 = 5'd8;                     
    localparam Mult2  = 5'd9;                     
    localparam Add2   = 5'd10;                     
    localparam Load2  = 5'd11;                     

    reg [4:0] State = Idle;
    
    always @ (posedge Clock) begin
        if (Clear == 1)
            State <= Idle;
        else
            case (State)		
                Idle:    if (Step == 1) State <= Phase1;

                Phase1:  begin PhaseSelect <= 0; State <= Table1; end
                Table1:  State <= Mult1;
                Mult1:   State <= Add1;
                Add1:    State <= Load1;
                Load1:   State <= Phase2;			
                
                Phase2:  begin PhaseSelect <= 1; State <= Table2; end                
                Table2:  State <= Mult2;			
                Mult2:   State <= Add2;
                Add2:    State <= Load2;
                Load2:   State <= Idle;
                
                default: State <= Idle;
            endcase
    end
        
    always @ (*) begin
        Valid        <= (State == Idle);
        LoadSinPhase <= (State == Phase1);
        ReadSine     <= (State == Table1 || State == Table2);
        ReadStep     <= (State == Table1 || State == Table2);
        RunMult      <= (State == Mult1  || State == Mult2);
        RunAdd       <= (State == Add1   || State == Add2);
        LoadSine     <= (State == Load1);
        LoadCosine   <= (State == Load2);		
    end        
endmodule



