`ifdef SMV
 `include "../or1200/or1200_defines.v"
`else
 `include "or1200_defines.v"
`endif

module ovl_combo_wrapped(
    clk,
    rst,
    enable,
    num_cks,
    start_event,
    test_expr,
    select,
    prevConfigInvalid,
    out,
    out_delayed,
    configInvalid
);

    parameter num_cks_max = 7;
    parameter num_cks_width = 3;
   
    input clk;
    input rst;
    input enable;
    input [num_cks_width-1:0] num_cks;
    input start_event;
    input test_expr;
    input [1:0] select;
    input  prevConfigInvalid;
    output out;
    output out_delayed;
    output configInvalid;

    reg out_delayed;
    wire [2:0] 	result_3bit_comb;

`ifdef SMV
   ovl_combo ovl_combo (.num_cks_max(7),
	           .num_cks_width(3),
             .clock(clk),
	           .reset(rst),
             .enable(enable),
	           .num_cks(num_cks),
	           .start_event(start_event),
	           .test_expr(test_expr),
			.select(select),
	.fire_comb(result_3bit_comb)
             );
`else // !`ifdef SMV
   ovl_combo #(
        .num_cks_max(7),
	.num_cks_width(3)
   ) ovl_combo(
        .clock(clk),
	.reset(rst),
        .enable(enable),
	.num_cks(num_cks),
	.start_event(start_event),
	.test_expr(test_expr),
	.select(select),
	.fire_comb(result_3bit_comb)
   );
`endif // !`ifdef SMV


   always @(posedge clk)
     if(rst == `OR1200_RST_VALUE)
       out_delayed <= 1'b0;
     else if(enable)
       out_delayed <= result_3bit_comb[0];
     
    // It is invalid if num_cks == 0 and next or on edge format selected
   //(CKS) Fixed a bug! was prevConfigInvalid & ...
    assign configInvalid = prevConfigInvalid | (~|num_cks & ~select[1]);

   //(CKS) I added the &configInvalid
   assign out = result_3bit_comb[0];
   

endmodule
