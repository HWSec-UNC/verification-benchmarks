module ovl_always_wrapped(
    clk,
    rst,
    enable,
    test_expr,
    prevConfigInvalid,
    out
);

    input clk;
    input rst;
    input enable;
    input test_expr;
    input  prevConfigInvalid;
    output out;

    wire [2:0]  result_3bit;
    wire [2:0] 	result_3bit_comb;
   
    ovl_always ovl_always(
        .clock(clk),
	.reset(rst),
        .enable(enable),
	.test_expr(test_expr),
	.fire(result_3bit),
	.fire_comb(result_3bit_comb)
    );
   
    assign out = result_3bit_comb[0] & ~prevConfigInvalid;
endmodule
