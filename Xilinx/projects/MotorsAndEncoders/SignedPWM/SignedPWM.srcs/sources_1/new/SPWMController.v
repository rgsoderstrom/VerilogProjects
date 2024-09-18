`timescale 1ns / 1ps

module SPWMController (input  Load,
                       input  NextDir,
                       input  Dir,
                       input  MagAtZero,
                   
                       input  Clk,   // 12 MHz
                       input  Clear, //  active high
                   
                       output reg MuxSel,
                       output reg LoadMag,
                       output reg LoadDir);
                   
reg [7:0] spwmState;

initial
    spwmState = 0;
    
always @ (posedge Clk)
	begin
		if (Clear == 1'b1)
            begin
			    spwmState <= 0;
		    end

        else
            if (Load == 1) 
                spwmState <= 1;
                 		  
		else
			case (spwmState)
				'h01: if (NextDir == Dir) spwmState <= 'h20; else spwmState <= 'h10;
			
                'h10: spwmState <= 'h11;
                'h11: if (MagAtZero == 1) spwmState <= 'h20;
                
                'h20: spwmState <= 0;
        			
				default: spwmState <= 0;
		endcase
	end
	
always @ (*)
	begin
		MuxSel      <= (spwmState == 'h20);
		LoadMag     <= (spwmState == 'h10 || spwmState == 'h20);
		LoadDir     <= (spwmState == 'h20);
	end
	
endmodule
