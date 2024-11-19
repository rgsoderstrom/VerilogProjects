
/*
    Testbench_Top - for top-level Sonar1Chan test
*/

`timescale 1ns / 1ps

module Testbench_Top;

    reg  Clock = 0;
    reg  ClearBar = 1;

	//*************************************************
	
	// simulate Arduino slowly shifting bits in
	reg inputDataBit = 0;
	reg inputShiftClock = 0;
	reg inputByteReady = 0;  // all bits have been shifted in

	//*************************************************
	
	// simulate Arduino gathering bits shifted out
	wire outputBit;
	reg  outputBitShiftClock = 0;
	wire lastBit;
	wire firstBit;
	

    Sonar1Chan #(.RamAddrBits (6), 
                 .MaxSamplesPerMsg (20), //(16), // doesn't have to be a power of 2
                 .ResetCount (50))
				U1 (.Clock50MHz (Clock),        
			  	    .ClearBar (ClearBar),
					   
                    //output TP39,
                    //output TP38,
                    //output TP37,
                    //output TP36,
                       
                     .InputBit           (inputDataBit),
                     .InputBitShiftClock (inputShiftClock),
                     .InputByteDone      (inputByteReady),
                     					   
                     .OutputBit           (outputBit),
                     .OutputBitShiftClock (outputBitShiftClock),
                     .LastBit             (lastBit),
                     .FirstBit            (firstBit),
                       
					 .adc_miso ('h0), // ADC controls
                     .adc_mosi (),
                     .adc_csn  (),
                     .adc_sck  (),               
					 
					 .dac_csn  (),   // DAC controls
                     .dac_sdi  (),  
                     .dac_ldac (), 
                     .dac_sck  ());
                     
	//*************************************************

    //
    // test bench initializations
    //    
	
	reg  [7:0] M1 [0:7]; // ClearSampleBufferMsg
    reg  [7:0] M2 [0:7]; // BeginSamplingMsg    
    reg  [7:0] M3 [0:7]; // SendSamplesMsg    	
	
    initial
    begin
        M1 [0] = 8'h34; M1 [1] = 8'h12; M1 [2] = 8'h08; M1 [3] = 8'h00; M1 [4] = 8'd100; M1 [5] = 8'd00; M1 [6] = 8'h01; M1 [7] = 8'h00; 
        M2 [0] = 8'h34; M2 [1] = 8'h12; M2 [2] = 8'h08; M2 [3] = 8'h00; M2 [4] = 8'd101; M2 [5] = 8'd00; M2 [6] = 8'h02; M2 [7] = 8'h00; 
        M3 [0] = 8'h34; M3 [1] = 8'h12; M3 [2] = 8'h08; M3 [3] = 8'h00; M3 [4] = 8'd102; M3 [5] = 8'd00; M3 [6] = 8'h03; M3 [7] = 8'h00; 
    end		

    initial
    begin
        $display ("module: %m");
    //    $monitor ($time, " state %d, msgByte 0x%h, WriteByte %h", U1.state, U1.MessageByte, U1.WriteDataByte);
                            
            ClearBar = 0;
        #50 ClearBar = 1;
    end
    		         

    //
    // clock period
    //
    always
        #10 Clock = ~Clock;  
        
    integer i, j, p;
		
    initial
    begin
		#50_000 
		
		//******************************************
		//
		// Clear - send ClearSampleBufferMsg 
		//
//        for (j=0; j<8; j=j+1) // 8 bytes
//        begin
//			for (i=0; i<8; i=i+1) // 8 bits per byte
//			  begin
//				#10 inputDataBit <= M1 [j][7-i];                    
//				#10 inputShiftClock <= 1'b1;
//				#50 inputShiftClock <= 1'b0;
//			  end
		
//			  #10 inputByteReady <= 1;
//			  #20 inputByteReady <= 0;
//        end
        
        //
        // Ping - send Ping message
        //
//        #25_000
        for (j=0; j<8; j=j+1) // 8 bytes
        begin
			for (i=0; i<8; i=i+1) // 8 bits per byte
			  begin
				#10 inputDataBit <= M2 [j][7-i];                   
				#10 inputShiftClock <= 1'b1;
				#50 inputShiftClock <= 1'b0;
			  end
		
			  #10 inputByteReady <= 1;
			  #20 inputByteReady <= 0;
        end

        #10_000_000 // $finish;



        //
        // Send - SendSamples message
        //
        for (p=0; p<2; p=p+1) // send the "send" message this many times
        begin        
            #120_000        
            for (j=0; j<8; j=j+1) // 8 bytes
            begin
                for (i=0; i<8; i=i+1) // 8 bits per byte
                  begin
                    #10 inputDataBit <= M3 [j][7-i];  // SendSamplesMsg                    
                    #10 inputShiftClock <= 1'b1;
                    #50 inputShiftClock <= 1'b0;
                  end
            
                  #10 inputByteReady <= 1;
                  #20 inputByteReady <= 0;
            end
        end        

    end
	 
	//*****************************************************
	//*****************************************************
	//*****************************************************

    // accept and print bytes received from UUT
    
	reg [7:0] rxByte = 0;
	integer k;
	
    reg [10:0] rxByteCount = 0;
    	
	always @ (posedge Clock) begin
		if (firstBit == 1) begin
		    rxByte <= 8'h00;
			for (k=0; k<8; k=k+1) begin
				rxByte [7-k] <= outputBit;
				#100 outputBitShiftClock <= 1'b1;
				#150 outputBitShiftClock <= 1'b0;
		
			end
			
            rxByteCount <= rxByteCount + 1;
            $display ($time, " %d: byte: %h", rxByteCount, rxByte);
		end		
	end
	

endmodule








