
`timescale 1ns / 1ps

/*
	Loopback.v - top level for FIFO loopback test
*/

module Loopback (input  InputDataBit, // 
                 input  InputShiftClock,
                 input  InputDone,
                                  
                 output OutputDataBit,
                 input  OutputShiftClock,
                 output LastBit,
                 output FirstBit,
				 
                 input  Clk,
                 input  ClearBar); // active low

    localparam DataWidth = 8;
 
    assign Clear = !ClearBar;
       
    wire [DataWidth-1:0] InputDataWord;
    wire [DataWidth-1:0] OutputDataWord;

    wire InputReady;
    wire P2S_Empty;
    wire P2S_Load;
    
    wire FIFO_Empty;
    wire FIFO_ReadCycle;
    
    SyncOneShot 
        sync1 (.trigger (InputShiftClock),  .clk (Clk), .clr (Clear), .Q (SInputShiftClock)),
        sync2 (.trigger (InputDone),        .clk (Clk), .clr (Clear), .Q (SInputDone)),
        sync3 (.trigger (OutputShiftClock), .clk (Clk), .clr (Clear), .Q (SOutputShiftClock));
        
    FIFO1 #(.DataWidth (DataWidth), .AddrWidth (5))           
       fifo (.Clk (Clk),          
             .Clr (Clear),
             .Empty (FIFO_Empty), 
             .Full (),
             .WriteData  (InputDataWord), 
             .ReadData   (OutputDataWord),
             .WriteCycle (InputReady),      
             .ReadCycle  (FIFO_ReadCycle)); 

   SerializerPtoS #(.Width (DataWidth))
       p2S (.Input (OutputDataWord),
            .Clr (Clear),   // sync, active high
            .Clk (Clk),   // pos edge triggered
            .Empty (P2S_Empty),
            .Load (P2S_Load),
            .Shift (SOutputShiftClock),
		    .FirstBit (FirstBit),  // true when OutputBit is first bit of Input
		    .LastBit (LastBit),   //  "     "      "     "  last   "   "   "						
            .OutputBit (OutputDataBit));

   FifoController
       ctrl (.P2S_Empty (P2S_Empty),
  		     .P2S_Load (P2S_Load),
		     .Clk (Clk),
		     .Clear (Clear),
		     .FIFO_Empty (FIFO_Empty),
		     .FIFO_ReadCycle (FIFO_ReadCycle));
                 
    SerializerStoP #(.Width (DataWidth)) 
        s2P (.DataIn (InputDataBit),
             .Shift (SInputShiftClock),
             .Done (SInputDone),   // data source sets this true when antire word has been shifted in
             .Clr (Clear),         // sync, active high
             .Clk (Clk),           // pos edge trigger
             .Ready (InputReady),  // copy of "Done" input
             .DataOut (InputDataWord));
endmodule
                 
                 


