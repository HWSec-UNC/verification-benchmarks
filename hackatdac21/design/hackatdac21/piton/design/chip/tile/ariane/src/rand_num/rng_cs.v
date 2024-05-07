module rng_cs(
	input               clk,
	input             	rst_n,
	//input             	load_i,
	input 	   [127:0]	entropy128_i,
	input				entropy128_valid_i,
	input	   [63:0]   entropy64_i,
	input				entropy64_valid_i,
	input	   [31:0]   entropy32_i,
	input				entropy32_valid_i,
	input	   [15:0]   entropy16_i,
	input				entropy16_valid_i,

	output     [63:0]   rand_num_o,
    output              rand_num_valid_o,

    //signal for debug mode
	output [15:0] rand_seg128_o,
	output [15:0] rand_seg64_o,
	output [15:0] rand_seg32_o,
	output [15:0] rand_seg16_o,
	output [3:0] cs_state_o
);

// random sources from each entropy
wire [127:0] entropy128;
wire [63:0] entropy64;
wire [31:0] entropy32;
wire [15:0] entropy16;

// random source valid signal
wire entropy128_valid;
wire entropy64_valid;
wire entropy32_valid;
wire entropy16_valid;

//final random number and valid signal
reg [63:0] rand_num;
wire rand_num_valid;

// random segements from each entropy source
wire [15:0] rand_seg [0:3];

//local signals
reg [3:0] cs_state;

assign entropy128 = entropy128_i;
assign entropy64 = entropy64_i;
assign entropy32 = entropy32_i;
assign entropy16 = entropy16_i;

assign entropy128_valid = entropy128_valid_i;
assign entropy64_valid = entropy64_valid_i;
assign entropy32_valid = entropy32_valid_i;
assign entropy16_valid = entropy16_valid_i;

assign rand_num_o = rand_num;
assign rand_num_valid_o = rand_num_valid;

assign rand_seg128_o = rand_seg[0];
assign rand_seg64_o = rand_seg[1];
assign rand_seg32_o = rand_seg[2];
assign rand_seg16_o = rand_seg[3];

assign cs_state_o = cs_state;


assign rand_num_valid = entropy128_valid & entropy64_valid & entropy32_valid & entropy16_valid;
//always take from the MSB of each source
assign rand_seg[0] = entropy128[127:112];
assign rand_seg[1] = entropy64[63:48];
assign rand_seg[2] = entropy32[31:16];
assign rand_seg[3] = entropy16;

always @ (posedge clk)
begin
	if (rst_n)
	begin
		cs_state <= 4'b0;
	end
	else
	begin
		cs_state <= cs_state + 1;
	end
end

always @(*)
begin
	rand_num = 64'b0;
	if(rand_num_valid) begin
		case(cs_state)
			0:
				rand_num = {rand_seg[0], rand_seg[1], rand_seg[2], rand_seg[3]};
			1:
				rand_num = {rand_seg[0], rand_seg[1], rand_seg[3], rand_seg[2]};
			2:
				rand_num = {rand_seg[0], rand_seg[3], rand_seg[1], rand_seg[2]};
			3:
				rand_num = {rand_seg[0], rand_seg[2], rand_seg[3], rand_seg[1]};
			4:
				rand_num = {rand_seg[1], rand_seg[2], rand_seg[3], rand_seg[0]};
			5:
				rand_num = {rand_seg[1], rand_seg[2], rand_seg[0], rand_seg[3]};
			6:
				rand_num = {rand_seg[1], rand_seg[0], rand_seg[2], rand_seg[3]};
			7:
				rand_num = {rand_seg[1], rand_seg[3], rand_seg[0], rand_seg[2]};
			8:
				rand_num = {rand_seg[2], rand_seg[3], rand_seg[0], rand_seg[1]};
			9:
				rand_num = {rand_seg[2], rand_seg[3], rand_seg[1], rand_seg[0]};
			10:
				rand_num = {rand_seg[2], rand_seg[1], rand_seg[3], rand_seg[0]};
			11:
				rand_num = {rand_seg[2], rand_seg[0], rand_seg[1], rand_seg[3]};
			12:
				rand_num = {rand_seg[3], rand_seg[0], rand_seg[3], rand_seg[2]};
			13:
				rand_num = {rand_seg[3], rand_seg[0], rand_seg[3], rand_seg[2]};
			14:
				rand_num = {rand_seg[3], rand_seg[2], rand_seg[3], rand_seg[2]};
			15:
				rand_num = {rand_seg[3], rand_seg[1], rand_seg[3], rand_seg[2]};
			default:
				rand_num = 64'b0;
		endcase // cs_state
	end
end 

endmodule