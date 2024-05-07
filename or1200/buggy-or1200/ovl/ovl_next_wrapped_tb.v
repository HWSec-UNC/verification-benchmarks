`define SMV

`include "ovl_next_wrapped.v"
`include "ovl_ported/ovl_next.v"
/*
 
 * File: ovl_next_wrapped_tb.v
 * Test bench for ovl_next_wrapped.v 
 * Configuration values for ovl_next_wrapped must match the 
 * hard-coded values used here.
 * Includes assertions for verification.
 * Created 2013-10-16
 * 
 */

module main();

   // Inputs to DUT
   reg clk;
   reg rst;
   reg enable;
   reg [2:0] num_cks;
   reg       start_event;
   reg       test_expr;
   reg       prevConfigInvalid;

   // Outputs of DUT
   wire      out;

   ovl_next_wrapped ovl_nw_t(.clk(clk),
                             .rst(rst),
                             .enable(enable),
                             .num_cks(num_cks),
                             .start_event(start_event),
                             .test_expr(test_expr),
                             .prevConfigInvalid(prevConfigInvalid),
                             .out(out));

   initial begin
      clk = 0;
      rst = 1;
      enable = 0;
      num_cks = 0;
      start_event = 0;
      test_expr = 0;
      prevConfigInvalid = 0;
   end

   always begin
      clk = #5 !clk;
   end

endmodule // main
/* *************** SMV Assertions *****************
//SMV-Assertions
# Verification is valid when num_cks_width=3 and num_cks_max=7
# Spec: 
#  @time t: 
#     IF start_event occurred at t-num_cks AND ~test_expr 
#     THEN @t+1, ~prevConfigInvalid -> out
 
  
  
# out and prevConfigInvalid are never both high.
\prevConfigInvalid_clears_out : assert \rst -> X(G(\out -> ~\prevConfigInvalid ));
 
# out is high only if test_expr was low in previous cycle.
\only_if_test_expr : assert \rst -> X(G(\test_expr -> X(~\out )));

# out is high only if there was a start_event in some previous cycle. Note that this can only be verified if num_cks is greater than 0. If num_cks = 0, the reg num_cks_1 wraps (num_cks_1 = num_cks - 1)  and the monitor array is accessed at an invalid index.
\only_if_start_event : assert \rst -> X(G((\num_cks > 0) && ~\start_event ) -> G(~\out ));

# implements the spec for num_cks_max = 1
\correct_1 : assert \rst -> X(G((~\rst && \start_event && X(~\rst && ~\test_expr && (\num_cks = 1))) -> X(X(~\prevConfigInvalid -> \out ))));
  
# implements the spec for num_cks_max = 2
\correct_2 : assert \rst -> X(G((~\rst && \start_event && X(~\rst && X(~\rst && ~\test_expr && (\num_cks = 2)))) -> X(X(X(~\prevConfigInvalid -> \out )))));
  
# implements the spec for num_cks_max = 3
\correct_3 : assert \rst -> X(G((~\rst && \start_event && X(~\rst && X(~\rst && X(~\rst && ~\test_expr && (\num_cks = 3))))) -> X(X(X(X(~\prevConfigInvalid -> \out ))))));

# implements the spec for num_cks_max = 4
\correct_4 : assert \rst -> X(G((~\rst && \start_event && X(~\rst && X(~\rst && X(~\rst && X(~\rst && ~\test_expr && (\num_cks = 4)))))) -> X(X(X(X(X(~\prevConfigInvalid -> \out )))))));

# implements the spec for num_cks_max = 5
\correct_5 : assert \rst -> X(G((~\rst && \start_event && X(~\rst && X(~\rst && X(~\rst && X(~\rst && X(~\rst && ~\test_expr && (\num_cks = 5))))))) -> X(X(X(X(X(X(~\prevConfigInvalid -> \out ))))))));

# implements the spec for num_cks_max = 6
\correct_6 : assert \rst -> X(G((~\rst && \start_event && X(~\rst && X(~\rst && X(~\rst && X(~\rst && X(~\rst && X(~\rst && ~\test_expr && (\num_cks = 6)))))))) -> X(X(X(X(X(X(X(~\prevConfigInvalid -> \out )))))))));

# implements the spec for num_cks_max = 7
\correct_7 : assert \rst -> X(G((~\rst && \start_event && X(~\rst && X(~\rst && X(~\rst && X(~\rst && X(~\rst && X(~\rst && X(~\rst && ~\test_expr && (\num_cks = 7))))))))) -> X(X(X(X(X(X(X(X(~\prevConfigInvalid -> \out ))))))))));

 
//SMV-Assertions
*/
