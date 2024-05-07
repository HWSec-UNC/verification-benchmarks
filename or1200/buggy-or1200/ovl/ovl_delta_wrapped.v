module ovl_delta_wrapped(
    clk,
    rst,
    min,
    max,
    test_expr,
    prevConfigInvalid,
    out
);

   //Explicit state space exploration not feasible for large values of test_expr
`ifdef SMV
   parameter width = 12;
   parameter limit_width = 3;
`else
   parameter width = 32;
   parameter limit_width = 8;
`endif
   
    input clk;
    input rst;
    input [limit_width-1:0] min;
    input [limit_width-1:0] max;
    input [width-1:0]       test_expr;
    input  prevConfigInvalid;
    output out;

    wire [2:0]  result_3bit;
    wire [2:0] 	result_3bit_comb;
   
`ifdef SMV
   ovl_delta ovl_delta(.width(width),
	                     .limit_width(limit_width),
                       .clock(clk),
	                     .reset(rst),
                       .enable(1'b1),
	                     .min(min),
	                     .max(max),
	                     .test_expr(test_expr),
	                     .fire(result_3bit),
	.fire_comb(result_3bit_comb)
                       );
`else // !`ifdef SMV
   ovl_delta #(
    	.width(width),
	.limit_width(limit_width)
    )
    ovl_delta(
        .clock(clk),
	.reset(rst),
        .enable(1'b1),
	.min(min),
	.max(max),
	.test_expr(test_expr),
	.fire(result_3bit),
	.fire_comb(result_3bit_comb)
    );
`endif // !`ifdef SMV
   
   
    assign out = result_3bit_comb[0] & ~prevConfigInvalid;
endmodule
