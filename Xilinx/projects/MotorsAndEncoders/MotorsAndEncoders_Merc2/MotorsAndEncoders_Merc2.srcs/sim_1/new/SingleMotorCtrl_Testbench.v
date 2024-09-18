
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	



/*
    SingleMotorCtrl_Testbench
*/

`timescale 1ns / 1ps

module SingleMotorCtrl_Testbench;

    localparam SW = 8;
    localparam DW = 8;
    
    reg Clr = 0;    
    reg Clk = 0;
    wire pulse10Hz;
    
    reg [SW-1:0] speedIn = 4;
    reg [DW-1:0] durationIn = 10;
    reg write = 0;
    reg runProfile = 0, clearProfile = 0, stopProfile = 0;
    wire profileDone;
            
    wire pwmLoad, pwmDone;
    wire [SW-1:0] pwmLevel;
    
    SingleMotorController #(.SpeedWidth (SW), .DurationWidth (DW))
                        U1 (.SpeedIn (speedIn),    // actually velocity, 2's complement
                            .DurationIn (durationIn),

                            .LoadSegment (write),
                            .ClearProfile (clearProfile),
                            .RunProfile (runProfile),
                            .StopProfile (stopProfile),
                               
                            .ProfileDone (profileDone),
                               
                            .PwmLoad  (pwmLoad),
                            .PwmLevel (pwmLevel),
                            .PwmDone  (pwmDone),
    
                            .Clear (Clr), // active high
                            .Pulse10Hz (pulse10Hz),
                            .Clock12MHz (Clk));

    SPWM_Sim #(.Width (SW))
        U2 (.Load  (pwmLoad),
            .Level (pwmLevel),
            .Clock (Clk),
            .Clear (Clr),
            .Done  (pwmDone));
            
    ClockDivider #(.Divisor (4))
 			   U3 (.FastClock (Clk),  
                   .Clear (Clr),      // active high
                   .SlowClock (),  // FastClock / Divisor, 50% duty cycle
				   .Pulse (pulse10Hz));            

    //
    // test bench initializations
    //    
    initial
    begin
        $display ("module: %m");
        $monitor ($time, " state %d: %d %d %d",
                U1.state,  profileDone, U1.PwmLoad, U1.U4.Count);
                        
        Clr = 1'b1;
        #50 Clr = 0;  // clear is active high
    end
    
    //
    // clock period
    //
    always
        #5 Clk = ~Clk;  
        
    //
    // test run
    //
    
    integer i;
        
    initial
    begin
        #62   // wait for "clear" to go away

        for (i=0; i<2; i=i+1)
        begin                
            #10 write = 1;
            #10 write = 0;
            speedIn = speedIn + 3;
            durationIn = durationIn + 5;
        end
                    
        #10 runProfile = 1;
        #10 runProfile = 0;
            

        #3000 $finish;
    end    
endmodule
