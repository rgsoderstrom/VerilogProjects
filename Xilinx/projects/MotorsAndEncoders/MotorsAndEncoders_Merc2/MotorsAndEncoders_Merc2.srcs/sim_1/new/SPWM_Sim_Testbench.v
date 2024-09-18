
/*
	Simulation system asserts hard "Clear" for first 100ns
*/	


/*
    SPWM_Sim_Testbench
*/  

`timescale 1ns / 1ps

module SPWM_Sim_Testbench;
    
    reg Load = 0;
    reg [4:0] level = -4;
    reg Clk = 0;
    reg Clr = 0;
    
    wire done;
    
    SPWM_Sim #(.Width (5))
           U1 (.Load (Load),
               .Level (level),
               .Clock (Clk),
               .Clear (Clr),
               .Done (done));

    //
    // test bench initializations
    //    
    initial
    begin
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

    initial
    begin

        #62 // wait for "clear"
    
        #10 Load = 1;
        #10 Load = 0;
            

        #1000 $finish;
    end
    
        
endmodule
