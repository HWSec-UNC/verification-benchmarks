`define SMV

`include "ovl_delta_wrapped.v"
`include "ovl_ported/ovl_delta.v"
//`include "globalDefines.vh"
/*
 
 * File: ovl_delta_wrapped_tb.v
 * Test bench for ovl_delta_wrapped.v
 * Includes assertions for verification.
 * Created 2013-10-16
 * 
 * Verified with the following parameters:
 * test_expr width    min/max width    user time     system time
 * 4 bits             2 bits           0.01 sec      0
 * 5 bits             3 bits           0.08 sec      0
 * 6 bits             3 bits           0.22 sec      0
 * 7 bits             3 bits           0.83 sec      0
 * 8 bits             3 bits           2.74 sec      0.01 sec
 * 9 bits             3 bits           11.5 sec      0.02 sec
 * 10 bits            3 bits           57.42 sec     0.04 sec
 * 11 bits            3 bits           249.75 sec    0.06 sec ~2.7M BDD nodes
 * 12 bits            3 bits           1070.17 sec   0.1 sec  ~5.4M BDD noes
 * 15 bits            3 bits             Error at ~9M BDD nodes
 */

module main();


   //Inputs to DUT
   reg clk;
   reg rst;
//   reg [7:0] min;
//   reg [7:0] max;
//   reg [31:0] test_expr;
   reg [2:0] min;
   reg [2:0] max;
   reg [11:0] test_expr;
   reg        prevConfigInvalid;

   //Outputs to DUT
   wire       out;

   reg [11:0] test_expr_prev;
   
   ovl_delta_wrapped ovl_dw_t(.clk(clk),
                              .rst(rst),
                              .min(min),
                              .max(max),
                              .test_expr(test_expr),
                              .prevConfigInvalid(prevConfigInvalid),
                              .out(out));

   initial begin
      clk = 0;
      rst = 1;
      min = 0;
      max = 0;
      test_expr = 0;
      test_expr_prev = 0;
      
      prevConfigInvalid = 0;
   end

   always begin
      clk = #5 !clk;
   end

   always @(posedge clk) begin
      test_expr_prev <= test_expr;
   end
   

endmodule // main
/* *************** SMV Assertions *****************
//SMV-Assertions
# Spec:
# Let diff = |test_expr@t - test_expr@t-1|.
# diff is only valid when ~reset@t AND ~reset@t-1
# precondition: min <= max
# @time t:
#    IF diff != 0 AND (diff < min OR diff > max)
#    THEN @t+1, ~prevConfigInvalid -> out

# out is low in the cycle following reset.
\reset_clears_out : assert G(\rst -> X(~\out ));
 
# prevConfigInvalid and out are never both high.
\prevConfigInvalid_clears_out : assert \rst -> X(G(\out -> ~\prevConfigInvalid ));
 
# test_expr_prev captures previous value as expected
\test_expr_prev_spec1 : assert \rst -> X(G((\test_expr [0]) -> X(\test_expr_prev [0]))); 
\test_expr_prev_spec2 : assert \rst -> X(G(~\test_expr [0] -> X(~\test_expr_prev [0])));
 
# implements the spec
\large_delta_triggers : assert \rst -> X(G(~\rst -> X((\min <= max ) -> (~\rst && (~((((\test_expr_prev - \test_expr ) >= \min ) && ((\test_expr_prev - \test_expr ) <= \max )) || (((\test_expr - \test_expr_prev ) >= \min ) && ((\test_expr - \test_expr_prev ) <= \max )) || (\test_expr_prev = \test_expr ) ))-> X(~\prevConfigInvalid -> \out )))));
  
# out is never triggered when delta = 0
\delta_0_doesnot_trigger : assert \rst -> X(G((\test_expr = \test_expr_prev ) -> X(~\out ))); 
//SMV-Assertions
  
*/
   