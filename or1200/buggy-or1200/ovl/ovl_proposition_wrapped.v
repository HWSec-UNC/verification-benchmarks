module ovl_proposition_wrapped(
    rst,
    enable,
    test_expr,
    prevConfigInvalid,
    out
);
    input rst;
    input enable;
    input test_expr;
    input  prevConfigInvalid;
    output out;

    wire [2:0]  result_3bit;
   
    ovl_proposition ovl_proposition(
	.reset(rst),
        .enable(enable),
	.test_expr(test_expr),
	.fire(result_3bit)
    );
   
    assign out = result_3bit[0] & ~prevConfigInvalid;
endmodule
