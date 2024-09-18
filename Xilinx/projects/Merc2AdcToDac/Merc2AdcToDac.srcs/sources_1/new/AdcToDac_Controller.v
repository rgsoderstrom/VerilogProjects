//*******************************************************************************
//
// AdcToDac_Controller
//

`timescale 1ns / 1ps

module AdcToDac_Controller #(parameter ClockDivisor = (50_000_000 / 25_000),
                             parameter ADC_Delay = 12'd500)
                           (input      Clock50MHz,
                            input      Clear,
                            output reg adcTrigger,
                            output reg dacTrigger,
                            output reg dacChannel,
                       //   input      adcDataValid,
                            input      dacBusy,
                            output reg dacMuxSelect,
                            input      filterReady,
                            output reg filterLoad,
                            output     sampleClock_tp);

    reg [7:0] State;    
    wire sampleClock;
    assign sampleClock_tp = sampleClock;
                                
    initial
    begin
        State = 'h0;
        adcTrigger = 0;
        dacTrigger = 0;
        dacChannel = 0;
        dacMuxSelect = 0;
        filterLoad = 0;
    end
                            
    ClockDivider #(.Divisor (ClockDivisor))
 			   U1 (.FastClock (Clock50MHz),  
                   .Clear (Clear),
                   .SlowClock (), // sampleClock_tp),
				   .Pulse (sampleClock));
    
    reg [11:0] delayCounter;
    
    always @ (posedge Clock50MHz)
        begin
            case (State)
                'h0: if (sampleClock == 1) State <= 'h10;
                     else                  State <= 0;
                       
                'h10: State <= 'h1a;  


//
//				  This constant-delay implementation fixes the scope jitter caused by the original
//                version's variable ADC trigger -> valid time
//
                'h1a: begin
                         delayCounter <= ADC_Delay; // 12'd500; 
                         State <= 'h20;
                      end

                'h20: begin
                        delayCounter <= delayCounter - 1;
                        
                        if (delayCounter == 0) State <= 'h30;
                        else                   State <= 'h20;
                        end
                        

//                'h1a: if (adcDataValid == 0) State <= 'h20;
//                      else                   State <= 'h1a;
//
//                'h20: if (adcDataValid == 1) State <= 'h30;
//                      else                   State <= 'h20;




                'h30: begin
                        dacMuxSelect <= 0;
                        dacChannel <= 0;
                        State <= 'h40;
                      end 

                'h40: State <= 'h50;

                'h50: if (dacBusy == 0) State <= 'h60;
                     else               State <= 'h50;

                'h60: if (filterReady == 1) State <= 'h70;
                     else                   State <= 'h60;

                'h70: begin
                        dacMuxSelect <= 1;
                        dacChannel <= 1;
                        State <= 'h80;
                      end 

                'h80: State <= 0;

                default: State <= 'h0;
            endcase
        end
        
    always @ (*)
        begin
            adcTrigger    <= (State == 'h10);
            dacTrigger    <= (State == 'h40) || (State == 'h80);
            filterLoad    <= (State == 'h40);
        end
endmodule
