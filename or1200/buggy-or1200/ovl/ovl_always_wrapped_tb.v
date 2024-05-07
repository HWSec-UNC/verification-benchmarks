`define SMV

`include "ovl_always_wrapped.v"
`include "ovl_ported/ovl_always.v"
/*
 
 * File: ovl_always_wrapped_tb.v
 * Test bench for ovl_always_wrapped.v
 * Includes assertions for verification
 * Created: 2013-10-14
 * 
 */

module main();


   //Inputs to DUT
   reg clk;
   reg rst;
   reg enable;
   reg test_expr;
   reg prevConfigInvalid;

   //Outputs of DUT
   wire out;

   ovl_always_wrapped ovl_aw_t(.clk(clk),
                               .rst(rst),
                               .enable(enable),
                               .test_expr(test_expr),
                               .prevConfigInvalid(prevConfigInvalid),
                               .out(out));
   initial begin
      clk = 0;
      rst = 1;
      enable = 0;
      test_expr = 0;
      prevConfigInvalid = 0;
   end

   always begin
      clk = #5 !clk;
   end

endmodule // main

/* *************** SMV Assertions *****************
//SMV-Assertions
# Spec:
#
#   IF @t, ~reset AND ~test_expr AND enable AND ~prevConfigInvalid 
#   THEN @t, out
#   ELSE @t, ~out
#
 
# verify then branch of spec
\spec_then : assert \rst -> X(G((~\rst && ~\test_expr && \enable && ~\prevConfigInvalid ) -> \out ));

# verify else branch of spec 
\spec_else : assert \rst -> X(G((\rst || \test_expr || ~\enable || \prevConfigInvalid ) -> ~\out ));
//SMV-Assertions
*/