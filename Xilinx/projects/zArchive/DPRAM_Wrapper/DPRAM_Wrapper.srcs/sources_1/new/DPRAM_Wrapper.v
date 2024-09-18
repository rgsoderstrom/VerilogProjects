
/*
    DPAM_Wrapper.v 
        - connect DPRAM pins to Merc 2 I/O
        - this is not intended to run, only to compare
          different DPRAM implementations
*/

`timescale 1ns / 1ps


module DPRAM_Wrapper (input  Clock50MHz,
                      input  Clear,
					  input  ByteWriteData_Bit,
					  input  ByteWriteData_Shift,
					  input  WordWriteData_Bit,
					  input  WordWriteData_Shift,
					  input  WordAddr_Bit,
					  input  WordAddr_Shift,
					  input  WordReadData_Load,
					  input  WordReadData_Shift,
					  input  ByteReadData_Load,
					  input  ByteReadData_Shift,
					  output ByteReadData_Empty,
					  output ByteReadData_FirstBit,
					  output ByteReadData_LastBit,
					  output ByteReadData_Bit,
					  output WordReadData_Empty,
					  output WordReadData_FirstBit,
					  output WordReadData_LastBit,
					  output WordReadData_Bit,
					  input  ByteWrite,
					  input  ByteRead,
					  input  ByteAddrClear,
//					  input  ByteReadNext,
					  input  WordWrite,
					  input  WordRead);

					  wire [7:0]  ByteWriteData;
					  wire [7:0]  ByteReadData;
					  wire [15:0] WordWriteData;
					  wire [15:0] WordReadData;
					  wire [9:0]  WordAddr;	

					  wire ByteReadValid;
					  wire WordReadValid;
    
    DualPortRAM2 //#(.L2Width (1), .L2Depth (10)) 
              U1 (.Clk            (Clock50MHz),
				  
                  .ByteWriteData  (ByteWriteData),
                  .ByteWrite      (ByteWrite),
                  
                  .ByteReadData  (ByteReadData),
                  .ByteRead      (ByteRead),
                  .ByteClearAddr (ByteAddrClear),				      
						 
                  .WordWriteData  (WordWriteData),
                  .WordWrite      (WordWrite),
                  .WordWriteAddr  (WordAddr),                         
                  
                  .WordReadData   (WordReadData), 
                  .WordReadAddr   (WordAddr),
                  .WordRead       (WordRead));
			  
	SerializerStoP #(.Width (8)) 
                 U2 (.DataIn  (ByteWriteData_Bit),
                     .Shift   (ByteWriteData_Shift),
                     .Done    (),             // ByteWriteData_Done),
                     .Clr     (Clear),  
                     .Clk     (Clock50MHz),                        
                     .Ready   (), // copy of "Done" input
                     .DataOut (ByteWriteData));
										  
	SerializerStoP #(.Width (16)) 
                 U3 (.DataIn  (WordWriteData_Bit),
                     .Shift   (WordWriteData_Shift),
                     .Done    (),             // WordWriteData_Done),
                     .Clr     (Clear),  
                     .Clk     (Clock50MHz),                        
                     .Ready   (), // copy of "Done" input
                     .DataOut (WordWriteData));
						
	SerializerStoP #(.Width (10)) 
                 U4 (.DataIn  (WordAddr_Bit),
                     .Shift   (WordAddr_Shift),
                     .Done    (),            // WordAddr_Done),
                     .Clr     (Clear),  
                     .Clk     (Clock50MHz),                        
                     .Ready   (), // copy of "Done" input
                     .DataOut (WordAddr));
						
	SerializerPtoS #(.Width (16))
                 U5 (.Input     (WordReadData),
                     .Clr       (Clear),
                     .Clk       (Clock50MHz),
                     .Load      (WordReadData_Load),
                     .Shift     (WordReadData_Shift),
				     .Empty     (WordReadData_Empty),
					 .FirstBit  (WordReadData_FirstBit),
					 .LastBit   (WordReadData_LastBit),
                     .OutputBit (WordReadData_Bit));
    
	SerializerPtoS #(.Width (8))
                 U6 (.Input     (ByteReadData),
                     .Clr       (Clear),
                     .Clk       (Clock50MHz),
                     .Load      (ByteReadData_Load),
                     .Shift     (ByteReadData_Shift),
				     .Empty     (ByteReadData_Empty),
					 .FirstBit  (ByteReadData_FirstBit),
					 .LastBit   (ByteReadData_LastBit),
                     .OutputBit (ByteReadData_Bit));
endmodule
