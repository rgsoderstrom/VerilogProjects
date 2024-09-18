`timescale 1ns / 1ps

/*
    FIFO1 - FIFO implmented with a Verilog array
*/
  
module FIFO1 #(parameter DataWidth = 8,  // number of data bits wide
               parameter AddrWidth = 6)  // number of address bus bits
              (input Clk,
               input Clr,
               
               output Empty,
               output Full,
               
               input      [DataWidth-1:0] WriteData,
               output reg [DataWidth-1:0] ReadData,
               output reg [AddrWidth:0]   NumberStored,
               
               input WriteCycle, // if high on Clk rising edge, WriteData written into Memory
               input ReadCycle); // if high on Clk rising edge next word is written to ReadData and ReadAddr is advanced  

    localparam Depth = 1 << AddrWidth;       // number of "Width"-wide words that can be stored  

    reg [DataWidth-1:0] Memory [0:Depth-1];
    reg [AddrWidth-1:0] ReadAddr;
    reg [AddrWidth-1:0] WriteAddr;
	//reg [AddrWidth:0]   NumberStored; // 1 bit wider than address
	
	initial
    begin
        ReadAddr = 0; //Depth - 1;
        WriteAddr = 0;
        NumberStored = 0;
    end

    always @ (posedge Clk)
    begin
        if (Clr == 1'b1)
        begin
            ReadAddr = 0;
            WriteAddr = 0;
			NumberStored = 0;
        end
        
		else begin
            if (WriteCycle == 1'b1 && Full != 1'b1)
            begin
               Memory [WriteAddr] <= WriteData;
               WriteAddr <= WriteAddr + 1;
               NumberStored = NumberStored + 1;
            end
          
            if (ReadCycle == 1'b1 && Empty != 1'b1)
            begin
               ReadData <= Memory [ReadAddr];
               ReadAddr <= ReadAddr + 1;
               NumberStored = NumberStored - 1;
            end                   
        end
    end
    
    assign Empty = (NumberStored == 0);
    assign Full  = (NumberStored == Depth); 
endmodule




