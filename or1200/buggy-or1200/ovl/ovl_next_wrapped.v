module ovl_next_wrapped(
    clk,
    rst,
    enable,
    num_cks,
    start_event,
    test_expr,
    prevConfigInvalid,
    out
);

    parameter num_cks_max = 7;
    parameter num_cks_width = 3;
   
    input clk;
    input rst;
    input enable;
    input [num_cks_width-1:0] num_cks;
    input start_event;
    input test_expr;
    input  prevConfigInvalid;
    output out;

    wire [2:0]  result_3bit;
    wire [2:0] 	result_3bit_comb;


`ifdef SMV
   ovl_next ovl_next (.num_cks_max(7),
	           .num_cks_width(3),
             .clock(clk),
	           .reset(rst),
             .enable(enable),
	           .num_cks(num_cks),
	           .start_event(start_event),
	           .test_expr(test_expr),
	           .fire(result_3bit),
	.fire_comb(result_3bit_comb)
             );
`else // !`ifdef SMV
   ovl_next #(
        .num_cks_max(7),
	.num_cks_width(3)
   ) ovl_next(
        .clock(clk),
	.reset(rst),
        .enable(enable),
	.num_cks(num_cks),
	.start_event(start_event),
	.test_expr(test_expr),
	.fire(result_3bit),
	.fire_comb(result_3bit_comb)
   );
`endif // !`ifdef SMV

    assign out = result_3bit_comb[0] & ~prevConfigInvalid;
endmodule
