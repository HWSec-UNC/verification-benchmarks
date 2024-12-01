module tempsen(clk, in, out);

input clk;
input  [127:0] in;
output [127:0] out;

assign out = (in[127] == 1)? in : ~in;


endmodule
