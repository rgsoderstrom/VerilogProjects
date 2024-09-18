

// PWM_Controller.v - for unsigned PWM

`timescale 1ns / 1ps

module PWM_Controller #(parameter Width = 7,
                                  Deadband = 1)
                (input             load,
                 input [Width-1:0] targetLevel,
                 input [Width-1:0] currentLevel,
                 input             ILR,  // intermediate level reached 
                 
                 output reg clrTLMS, // TargetLevelMuxSel
                 output reg setTLMS,
                 
                 output reg clrCL,   // current level
                 output reg setCL,
                 
                 output reg clrTL,   // target level
                 output reg setTL,
                 
                 output reg setAL,   // at requested level
                 output reg clrAL,
                 
                 input  Clear,
                 input  Clock);
                 
reg [7:0] pwmState;
reg isRunning;
reg willBeRunning;

initial
    begin
        pwmState = 0;
        isRunning = 0;
        willBeRunning = 0;
    end
    
always @ (posedge Clock)
	begin
		if (Clear == 1'b1)
            begin
			    pwmState <= 0;
		    end
		    
		else
		  begin		  
		     if (load == 1)
				begin
                   isRunning     <= (currentLevel > Deadband);
                   willBeRunning <= (targetLevel  > Deadband);
                   pwmState <= 1;
                end

			case (pwmState)
			    0: begin 
			       end
			       
                1: begin
                      if      (isRunning == 0 && willBeRunning == 0) pwmState <= 'h10;                          
                      else if (isRunning == 0 && willBeRunning == 1) pwmState <= 'h20;                            
                      else if (isRunning == 1 && willBeRunning == 0) pwmState <= 'h30;                            
                      else if (isRunning == 1 && willBeRunning == 1) pwmState <= 'h40;                                                      
				   end
								
				'h10: pwmState <= 'h11;
				'h11: pwmState <= 'h12;
				'h12: pwmState <= 'h13;
				'h13: pwmState <= 'h14;
				'h14: pwmState <= 0;

				'h20: pwmState <= 'h21;
				'h21: pwmState <= 'h22;
				'h22: pwmState <= 'h23;
				'h23: if (ILR == 1'b1) pwmState <= 'h24;
				'h24: pwmState <= 0;

				'h30: pwmState <= 'h31;
				'h31: pwmState <= 'h32;
				'h32: if (ILR == 1'b1) pwmState <= 'h33;
				'h33: pwmState <= 'h34;
				'h34: pwmState <= 'h35;
				'h35: pwmState <= 0;

				'h40: pwmState <= 'h41;
				'h41: if (ILR == 1) pwmState <= 'h42;
				'h42: pwmState <= 0;
				
				default: pwmState <= 0;
		    endcase
		  end
    end
    
always @ (*)
	begin
		setTLMS <= (pwmState == 'h12) || (pwmState == 'h21) || (pwmState == 'h33);
        clrTLMS <= (pwmState == 'h31); 
        
        clrCL   <= (pwmState == 'h13) || (pwmState == 'h34);
        setCL   <= (pwmState == 'h22);
        
        clrTL   <= (pwmState == 'h11) || (pwmState == 'h31);
        setTL   <= 0;
        
		clrAL   <= (pwmState == 'h10) || (pwmState == 'h20) || (pwmState == 'h30) || (pwmState == 'h40);
        setAL   <= (pwmState == 'h14) || (pwmState == 'h24) || (pwmState == 'h35) || (pwmState == 'h42);		
	end
                 
endmodule
