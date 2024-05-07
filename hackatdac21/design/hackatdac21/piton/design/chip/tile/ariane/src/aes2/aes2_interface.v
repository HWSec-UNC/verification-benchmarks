module aes2_interface(
	clk,
	rst,
	input_pc,
	iv,
	cii_K,
	start,
	ct_valid_out,
	Out_data_final
);

parameter s0 = 4'd0;
parameter s1 = 4'd1;
parameter s2 = 4'd2;
parameter s3 = 4'd3;
parameter s4 = 4'd4;
parameter s5 = 4'd5;
parameter s6 = 4'd6;
parameter s7 = 4'd7;
parameter s8 = 4'd8;
parameter s9 = 4'd9;
parameter s10 = 4'd10;
parameter s11 = 4'd11;
parameter s12 = 4'd12;
parameter s13 = 4'd13;
parameter s14 = 4'd14;
parameter s15 = 4'd15;


input			start;
input 			clk;
input			rst;
input 	[127:0]	cii_K;
input 	[127:0]	input_pc;
input	[127:0] iv;
output reg [127:0] Out_data_final;
output reg ct_valid_out = 0;

wire dii_data_not_ready;
wire [3:0] Out_data_size;
wire t_v;
wire Out_last_word;
wire [127:0] Out_data;
wire ct_valid;

reg [3:0] state = s0;
reg rst_internal = 0;
reg [127:0] dii_data = 0;
reg dii_data_vld = 0;
reg dii_data_type = 0;
reg dii_last_word = 0;
reg [3:0] dii_data_size = 0;
reg cii_IV_vld = 0;
reg cii_ctl_vld = 0;
reg [4:0] ctr = 0;


always @(posedge clk)
    begin
        if(~rst)
            begin
		state <= 0;
		ct_valid_out <= 1'b0;
		ctr <= 0;
		rst_internal <= 0;
		cii_IV_vld <= 0;
		cii_ctl_vld <= 0;
		dii_data_size <= 0;
		dii_data_vld <= 0;
		dii_data <= 0;
		dii_last_word <= 0;

	end
	else begin
		case (state)
		s0: begin // wait for start signal
			if (start == 1'b1) begin
				state <= s1;
				ctr <= 0;
			end
		end

		// initialize module
	    s1: begin
			rst_internal <= 1;
			state <= s2;
		end
	    s2: begin // reset high for 10 CC
			if (ctr == 10) begin
				rst_internal <= 0;
				state <= s3;
			end else begin 
				ctr <= ctr + 1;
			end
		end 
        s3: begin // valid high
			cii_ctl_vld <= 1'b1;
			state <= s4;
		end
	    s4: begin // valid low (pulse)
			cii_ctl_vld <= 1'b0;
			state <= s5;
	   end 
		s5: begin // sending Initial Vector
			cii_IV_vld <= 1'b1;
			dii_data <= iv;
			state <= s6;

		end
		s6: begin

			if(dii_data_not_ready == 0) begin
				state <= s7;
			end else begin
				state <= s6;
			end
		end
		s7: begin
			cii_IV_vld <= 1'b0;
			state <= s8;		
		end
		
		// sending AAD
		s8: begin
			dii_data_vld  <= 1'b1;	
			dii_data_size <= 4'd15;
			dii_data <= 128'b0;
			dii_data_type <= 1'b1;
			dii_last_word <= 1'b0;
			
			state <= s9;
		end

		s9: begin
			dii_data_vld  <= 1'b0;
			state <= s10;
		end 
		
		s10: begin		
			if(dii_data_not_ready == 0) begin
					state <= s11;
			end else begin
					state <= s10;
			end
		end
	
		s11: begin
			// sending text
			dii_data_vld  <= 1'b1;
			dii_data_size <= 4'd15;
			dii_data      <= input_pc;
			dii_data_type <= 1'b0; 
			dii_last_word <= 1'b1;
			state <= s12;

		end
		s12: begin
			dii_data_vld  <= 1'b0;
			state <= s14;
		end
		s14: begin
			if(ct_valid == 1) begin
					state <= s15;
			end else begin
					state <= s14;
			end
		end
		s15: begin
			Out_data_final <= Out_data;
			ct_valid_out <= 1'b1;
			
			state <= s0;
		end
	endcase
	end
end


gcm_aes_v0 aes2_gcm_top(
	.clk(clk),
	.rst(rst_internal),

	// data input interface
	.dii_data(dii_data),  // i/128-bit data input
	.dii_data_vld(dii_data_vld),    // i/data valid
	.dii_data_type(dii_data_type),   // i/data type
	.dii_last_word(dii_last_word),   // i/last word
	.dii_data_not_ready(dii_data_not_ready), // o/data not ready = !(ready)
	.dii_data_size(dii_data_size),      // i/size of input

	// control input interface
	.cii_ctl_vld(cii_ctl_vld), // i/cii_ctl_vld signal
	.cii_IV_vld(cii_IV_vld),       // i/valid input signal   
	.cii_K(cii_K),    //  i/key input

	// data output interfact
	.Out_data(Out_data),          // o/output data
	.Out_vld(ct_valid),     // o/output valid
	.Out_data_size(Out_data_size),       // o/output size
	.Out_last_word(Out_last_word),         // o/output_last_word

	// tag output interface
	.Tag_vld(t_v)             // o/tag_vld
);


endmodule
