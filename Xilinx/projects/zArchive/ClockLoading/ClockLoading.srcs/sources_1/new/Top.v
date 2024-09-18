
/*
    Top.v - 
*/
    
`timescale 1ns / 1ps

module Top (output select3, // select digit 3
            output select2,
            output select1,
            output select0,
            input  Clock50MHz);

    reg [3:0] bright = 7;  
    wire Clock5MHz;  
    
   ClockDivider #(.Divisor (10))
 			   U1 (.FastClock (Clock50MHz),  
                   .Clear (0),      // active high
                   .SlowClock (Clock5MHz),
				   .Pulse ());
				   
    Module1 U2 (.select3 (select3), // select digit 3
                .select2 (select2),
                .select1 (select1),
                .select0 (select0),
                .brightness (bright),
                .Clock (Clock50MHz));
    endmodule
