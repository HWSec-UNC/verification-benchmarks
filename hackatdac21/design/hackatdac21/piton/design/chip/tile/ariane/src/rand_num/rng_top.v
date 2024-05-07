module rng_top(
	input               clk,
	input             rst_n,
	input             load_i,
	input      [127:0]	seed_i,
	input 	   [127:0]	poly128_i,
	input	   [63:0]   poly64_i,
	input	   [31:0]   poly32_i,
	input	   [15:0]   poly16_i,
	output     [63:0]	rand_num_o,
    output              rand_num_valid_o,

    //signal for debug mode
    //seed segment for each entropy source
	output [127:0] seed128_o,
	output [63:0] seed64_o,
	output [31:0] seed32_o,
	output [15:0] seed16_o,

	//rand num segment from each entropy source
	output [15:0] rand_seg128_o,
	output [15:0] rand_seg64_o,
	output [15:0] rand_seg32_o,
	output [15:0] rand_seg16_o,
	output [3:0] cs_state_o
);

//tap location for each lfsr
  wire 	   [127:0]	poly128;
  wire	   [63:0]   poly64;
  wire	   [31:0]   poly32;
  wire	   [15:0]   poly16;

//seed segment for each entropy source
reg [127:0] seed128;
reg [63:0] seed64;
reg [31:0] seed32;
reg [15:0] seed16;

//rand num segments from each entropy source
wire [15:0] rand_seg128;
wire [15:0] rand_seg64;
wire [15:0] rand_seg32;
wire [15:0] rand_seg16;

//local signals
wire load;
wire [127:0] seed;
wire [127:0] entropy128;
wire [63:0] entropy64;
wire [31:0] entropy32;
wire [15:0] entropy16;
wire entropy128_valid;
wire entropy64_valid;
wire entropy32_valid;
wire entropy16_valid;
wire [63:0] rand_num;
wire rand_num_valid;
wire [3:0] cs_state;

//assign value from local signals to ports
assign seed = seed_i;
assign load = load_i;

assign poly128 = poly128_i;
assign poly64 = poly64_i;
assign poly32 = poly32_i;
assign poly16 = poly16_i;

assign rand_num_o = rand_num;
assign rand_num_valid_o = rand_num_valid;


assign seed128_o = seed128;
assign seed64_o = seed64;
assign seed32_o = seed32;
assign seed16_o = seed16;

assign rand_seg128_o = rand_seg128;
assign rand_seg64_o = rand_seg64;
assign rand_seg32_o = rand_seg32;
assign rand_seg16_o = rand_seg16;

assign cs_state_o = cs_state;

reg [1:0] seed_ct;

always @ (posedge clk)
begin
	if (!rst_n)
	begin
		seed_ct <= 2'b0;
	end
	else
	begin
		seed_ct <= seed_ct + 1;
	end
end


always @(*)
begin
	seed128 = seed;
	case(seed_ct)
		0:begin
			seed16 <= seed[127:112];
			seed32 <= seed[127:96];
			seed64 <= seed[127:64];
		end
		1:begin
			seed16 <= seed[111:96];
			seed32 <= seed[111:80];
			seed64 <= seed[111:48];
		end
		2:begin
			seed16 <= seed[95:80];
			seed32 <= seed[95:64];
			seed64 <= seed[95:32];
		end
		3:begin
			seed16 <= seed[79:64];
			seed32 <= seed[79:48];
			seed64 <= seed[79:16];
		end
		default:begin
			seed16 <= 0;
			seed32 <= 0;
			seed64 <= 0;
		end
	endcase // seed_ct
end


rng_cs CS0(
			.clk(clk),
		    .rst_n(rst_n),
		    .entropy128_i(entropy128),
		    .entropy128_valid_i(entropy128_valid),		   
	   	    .entropy64_i(entropy64),
	   	    .entropy64_valid_i(entropy64_valid),
	        .entropy32_i(entropy32),
	        .entropy32_valid_i(entropy32_valid),
	        .entropy16_i(entropy16),
	        .entropy16_valid_i(entropy16_valid),
		    .rand_num_o(rand_num),
    		.rand_num_valid_o(rand_num_valid),
			.rand_seg128_o(rand_seg128),
	    	.rand_seg64_o(rand_seg64),
	    	.rand_seg32_o(rand_seg32),
	    	.rand_seg16_o(rand_seg16),
	    	.cs_state_o(cs_state));


rng_128 RNG128(
			.clk(clk),
			.rst_n(rst_n),
			.load_i(load),
		 	.seed_i(seed128),
			.poly_i(poly128),
			.entropy128_o(entropy128),
    		.entropy128_valid_o(entropy128_valid)
	);

rng_64 RNG64(
			.clk(clk),
			.rst_n(rst_n),
			.load_i(load),
		 	.seed_i(seed64),
			.poly_i(poly64),
			.entropy64_o(entropy64),
    		.entropy64_valid_o(entropy64_valid)
	);

rng_32 RNG32(
			.clk(clk),
			.rst_n(rst_n),
			.load_i(load),
		 	.seed_i(seed32),
			.poly_i(poly32),
			.entropy32_o(entropy32),
    		.entropy32_valid_o(entropy32_valid)
	);

rng_16 RNG16(
			.clk(clk),
			.rst_n(rst_n),
			.load_i(load),
		 	.seed_i(seed16),
			.poly_i(poly16),
			.entropy16_o(entropy16),
    		.entropy16_valid_o(entropy16_valid)
	);

endmodule : rng_top