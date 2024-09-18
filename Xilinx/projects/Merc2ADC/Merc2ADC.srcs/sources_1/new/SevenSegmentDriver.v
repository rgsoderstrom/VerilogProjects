
/*
    SevenSegmentDriver.v 
        - for Mercury2 Baseboard
        - 4 hex digits
        - IO8-11 select digit
        - IO12-18 low turns on segment of selected digit
        - IO19     "    "   "   dot    "   "        "
*/

`timescale 1ns / 1ps

module SevenSegmentDriver (output [11:0] SevenSeg,
                           input  [15:0] value,
                           input  [3:0]  dots,
                           input  [3:0]  brightness,
                           input  load,
                           input  Clock50MHz);

    reg  [6:0]  SegmentLUT [15:0];	
	reg  [15:0] latchedValue;
	reg  [3:0]  latchedBrightness;	
	reg  [3:0]  latchedDots;
    wire        loadValue      = load;
    wire        loadBrightness = load;
    wire        loadDots       = load;
	wire [3:0]  nybble3;
	wire [3:0]  nybble2;
	wire [3:0]  nybble1;
	wire [3:0]  nybble0;
	wire [3:0]  selectedNybble;
    wire        Enable;
    	
	reg  [5:0] freeCounter;
	wire [1:0] selectCounter     = freeCounter [5:4];
	wire [3:0] brightnessCounter = freeCounter [3:0];
	wire       decodeEnable;// = brightnessCounter < latchedBrightness;

	assign nybble3 = latchedValue [15:12];
	assign nybble2 = latchedValue [11:8];
	assign nybble1 = latchedValue [7:4];
	assign nybble0 = latchedValue [3:0];
                               								
    initial
    begin
        SegmentLUT [0]  = 7'b1111110; SegmentLUT [1]  = 7'b0110000; SegmentLUT [2]  = 7'b1101101; SegmentLUT [3]  = 7'b1111001;  
        SegmentLUT [4]  = 7'b0110011; SegmentLUT [5]  = 7'b1011011; SegmentLUT [6]  = 7'b1011111; SegmentLUT [7]  = 7'b1110000;
        SegmentLUT [8]  = 7'b1111111; SegmentLUT [9]  = 7'b1110011; SegmentLUT [10] = 7'b1110111; SegmentLUT [11] = 7'b0011111;
        SegmentLUT [12] = 7'b1001110; SegmentLUT [13] = 7'b0111101; SegmentLUT [14] = 7'b1001111; SegmentLUT [15] = 7'b1000111;
        
        freeCounter = 6'd0;
    end
                       
//************************************************************************************        
        
//   ClockDivider #(.Divisor (50_000_000 / 3125))
                           
    localparam Divisor = 50_000_000 / 3125;
    reg [31:0] ClockCounter;
       
    initial
        ClockCounter = 0;
                
	assign Enable = (ClockCounter == 0);
	
    always @ (posedge Clock50MHz) 
        begin
            if (ClockCounter == Divisor - 1)
                ClockCounter <= 0;                
            else
                ClockCounter <= ClockCounter + 1'b1;
        end
                                                      
//************************************************************************************        
                           
    always @ (posedge Clock50MHz)
        if (loadValue == 1)
            latchedValue <= value;
                                          
    always @ (posedge Clock50MHz)
        if (loadBrightness == 1)
            latchedBrightness <= brightness;

    always @ (posedge Clock50MHz)
        if (loadDots == 1)
            latchedDots <= dots;
                                          
    // 4:1 mux            
    assign selectedNybble = (selectCounter [1] == 0 ? (selectCounter [0] == 0 ? nybble0 : nybble1) 
                                                    : (selectCounter [0] == 0 ? nybble2 : nybble3));

    // segment outputs            
    assign SevenSeg[4]  = ~SegmentLUT [selectedNybble][6];  // active low
    assign SevenSeg[5]  = ~SegmentLUT [selectedNybble][5];
    assign SevenSeg[6]  = ~SegmentLUT [selectedNybble][4];
    assign SevenSeg[7]  = ~SegmentLUT [selectedNybble][3];
    assign SevenSeg[8]  = ~SegmentLUT [selectedNybble][2];
    assign SevenSeg[9]  = ~SegmentLUT [selectedNybble][1];
    assign SevenSeg[10] = ~SegmentLUT [selectedNybble][0];
    assign SevenSeg[11] = ~latchedDots [selectCounter] & decodeEnable;

    always @ (posedge Clock50MHz)
        if (Enable)
            freeCounter <= freeCounter + 6'd1;
                              
    // decoder                 
    assign SevenSeg[0] = ~(decodeEnable & (selectCounter == 0));  // active low
    assign SevenSeg[1] = ~(decodeEnable & (selectCounter == 1));
    assign SevenSeg[2] = ~(decodeEnable & (selectCounter == 2));
    assign SevenSeg[3] = ~(decodeEnable & (selectCounter == 3));
                      
    // comparator
    assign decodeEnable = (brightnessCounter < latchedBrightness);
endmodule





