/*
    firFilter2.v
        - 17 taps
        
        FIR filter designed with
        http://t-filter.appspot.com
        
        sampling frequency: 25000 Hz
        
        * 0 Hz - 4000 Hz
          gain = 1
          desired ripple = 5 dB
          actual ripple = 2.544442537669994 dB
        
        * 6000 Hz - 12500 Hz
          gain = 0
          desired attenuation = -40 dB
          actual attenuation = -44.19998518331085 dB
*/    

/*
    faster implementation 
    
            - CAUTION: IMPLEMENTATION REPORTS SHOW THIS RUNS TOO HOT

*/



`timescale 1ns / 1ps

module firFilter2 #(parameter DataWidth = 10)
                   (input  Clock,
                    input  Load,
                    output Ready,
                    input  Clear,
                    input  signed [DataWidth-1:0] InputData,  
                    output reg signed [DataWidth-1:0] FilteredData);
                    
    reg signed [DataWidth-1:0] Buf0, Buf1,  Buf2,  Buf3,  Buf4,  Buf5,  Buf6,  Buf7, Buf8; 
    reg signed [DataWidth-1:0] Buf9, Buf10, Buf11, Buf12, Buf13, Buf14, Buf15, Buf16; 
             
    wire signed [DataWidth-1:0] h0, h1,  h2,  h3,  h4,  h5,  h6,  h7, h8; 
    wire signed [DataWidth-1:0] h9, h10, h11, h12, h13, h14, h15, h16; 
             
    localparam FixedPoint_One = (1 << DataWidth);
    
    assign h0  =  0.016344994571662934 * FixedPoint_One;
    assign h1  =  0.03153993235313417  * FixedPoint_One;
    assign h2  =  0.01812600557315812  * FixedPoint_One;
    assign h3  = -0.03679867254082173  * FixedPoint_One;
    assign h4  = -0.08778708616490631  * FixedPoint_One;
    assign h5  = -0.05390823923370393  * FixedPoint_One;
    assign h6  =  0.09516178407604953  * FixedPoint_One;
    assign h7  =  0.2800948491327079   * FixedPoint_One;
    assign h8  =  0.3643303038474168   * FixedPoint_One;
    assign h9  =  0.2800948491327079   * FixedPoint_One;
    assign h10 =  0.09516178407604953  * FixedPoint_One;
    assign h11 = -0.05390823923370393  * FixedPoint_One;
    assign h12 = -0.08778708616490631  * FixedPoint_One;
    assign h13 = -0.03679867254082173  * FixedPoint_One;
    assign h14 =  0.01812600557315812  * FixedPoint_One;
    assign h15 =  0.03153993235313417  * FixedPoint_One;
    assign h16 =  0.016344994571662934 * FixedPoint_One;
    
    reg [5:0] state = 0;
    assign Ready = (state == 0);    
    wire LoadSR = (state == 1);
                    
//*****************************************************************************
//*****************************************************************************
//*****************************************************************************

// adder tree, added for ver. 2

	// h * Buf 
    reg signed [2*DataWidth-1:0] P0, P1,  P2,  P3,  P4,  P5,  P6,  P7, P8; 
    reg signed [2*DataWidth-1:0] P9, P10, P11, P12, P13, P14, P15, P16; 

	// results of adding pairs
    reg signed [2*DataWidth-1:0] P01, P23, P45,  P67,  P89,  PAB, PCD, PEF; 
                    
	// results of adding pairs of those
    reg signed [2*DataWidth-1:0] P03, P47, P8B,  PCF;
                    
	// and those
    reg signed [2*DataWidth-1:0] P07, P8F;
                    
	// and those
    reg signed [2*DataWidth-1:0] P0F;
                				
    reg signed [2*DataWidth-1:0] FinalSum;
					
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************

// state machine
            
    always @ (posedge Clock)
    begin
        if (Clear == 1)
            state <= 0;
        else if (Load == 1)
            state <= 1;
        else
          begin
            case (state)
                5'd1 : begin 
				          P0  <= h0  * Buf0;
				          P1  <= h1  * Buf1;
				          P2  <= h2  * Buf2;
				          P3  <= h3  * Buf3;
				          P4  <= h4  * Buf4;
				          P5  <= h5  * Buf5;
				          P6  <= h6  * Buf6;
				          P7  <= h7  * Buf7;
				          P8  <= h8  * Buf8;
				          P9  <= h9  * Buf9;
				          P10 <= h10 * Buf10;
				          P11 <= h11 * Buf11;
				          P12 <= h12 * Buf12;
				          P13 <= h13 * Buf13;
				          P14 <= h14 * Buf14;
				          P15 <= h15 * Buf15;
				          P16 <= h16 * Buf16;
						  state <= 2;
					   end
                
                5'd2 : begin 
						  P01 <= P0 + P1;
						  P23 <= P2 + P3;
						  P45 <= P4 + P5;
						  P67 <= P6 + P7;
						  P89 <= P8 + P9;
						  PAB <= P10 + P11;
						  PCD <= P12 + P13;
						  PEF <= P14 + P15;
				          state <= 3; 
					   end

                5'd3 : begin 
						  P03 <= P01 + P23;
						  P47 <= P45 + P67;
						  P8B <= P89 + PAB;
						  PCF <= PCD + PEF;
						  state <= 4; 
					   end
					   					   					   					  					  
                5'd4 : begin 
						  P07 <= P03 + P47;
						  P8F <= P8B + PCF;
				          state <= 5; 
					   end
				
				5'd5 : begin 
						   P0F <= P07 + P8F;
				           state <= 6; 
					   end
										
                5'd6 : begin 
						   FinalSum <= P0F + P16;
					       state <= 7; 
					   end

                5'd7 : begin 
				           FilteredData <= FinalSum [2 * DataWidth - 1 : DataWidth]; 
						   state <= 0; 
					   end                
				
                default: state <= 0;
            endcase
          end
        end
    
    //***************************************************************************************
    //***************************************************************************************
    //***************************************************************************************

    // shift register
                            
    always @ (posedge Clock)
    begin
        if (Clear == 1)
        begin
            Buf0  <= 0;
            Buf1  <= 0;
            Buf2  <= 0;
            Buf3  <= 0;
            Buf4  <= 0;
            Buf5  <= 0;
            Buf6  <= 0;
            Buf7  <= 0;
            Buf8  <= 0;
            Buf9  <= 0;
            Buf10 <= 0;
            Buf11 <= 0;
            Buf12 <= 0;
            Buf13 <= 0;
            Buf14 <= 0;
            Buf15 <= 0;
            Buf16 <= 0;
        end    
        else if (LoadSR == 1) // load shift register
        begin
            Buf0  <= InputData;
            Buf1  <= Buf0;
            Buf2  <= Buf1;
            Buf3  <= Buf2;
            Buf4  <= Buf3;
            Buf5  <= Buf4;
            Buf6  <= Buf5;
            Buf7  <= Buf6;
            Buf8  <= Buf7;
            Buf9  <= Buf8;
            Buf10 <= Buf9;
            Buf11 <= Buf10;
            Buf12 <= Buf11;
            Buf13 <= Buf12;
            Buf14 <= Buf13;
            Buf15 <= Buf14;
            Buf16 <= Buf15;
        end
        else
        begin
            Buf0  <= Buf0;
            Buf1  <= Buf1;
            Buf2  <= Buf2;
            Buf3  <= Buf3;
            Buf4  <= Buf4;
            Buf5  <= Buf5;
            Buf6  <= Buf6;
            Buf7  <= Buf7;
            Buf8  <= Buf8;
            Buf9  <= Buf9;
            Buf10 <= Buf10;
            Buf11 <= Buf11;
            Buf12 <= Buf12;
            Buf13 <= Buf13;
            Buf14 <= Buf14;
            Buf15 <= Buf15;
            Buf16 <= Buf16;
        end
    end                                            
endmodule
