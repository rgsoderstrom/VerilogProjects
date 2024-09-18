`timescale 1ns / 1ps

module DirectionFF (input NextDir,
                    input Load,
                    input Clock,
                    input Clear,
                    output reg Dir);

    initial Dir = 0;
                            
    always @ (posedge Clock)
        if (Clear)
            Dir = 0;
            
        else
            if (Load)
                Dir = NextDir;                            
endmodule
