`define SMV

`include "ovl_always_on_edge_wrapped.v"
`include "ovl_ported/ovl_always_on_edge.v"
/*
 
 * File: ovl_always_on_edge_wrapped_tb.v
 * Test bench for ovl_always_on_edge_wrapped.v
 * Includes assertions for verification
 * Created: 2013-10-10
 * 
 * 
 */

module main();

  // Inputs to DUT
   reg clk;
   reg rst;
   reg enable;
   reg sampling_event;
   reg test_expr;
   reg prevConfigInvalid;

   // Outputs of DUT
   wire out;

   ovl_always_on_edge_wrapped ovl_aoew_t(.clk(clk),
                                         .rst(rst),
                                         .enable(enable),
                                         .sampling_event(sampling_event),
                                         .test_expr(test_expr),
                                         .prevConfigInvalid(prevConfigInvalid),
                                         .out(out));
   
   initial begin
      clk = 0;
      rst = 1;
      enable = 0;
      sampling_event = 0;
      test_expr = 0;
      prevConfigInvalid = 0;
   end
   
   always begin
      clk = #5 !clk;
   end
   

endmodule
   


/* *************** SMV Assertions *****************
//SMV-Assertions
# Spec:
# Assert is sequential, not combinational. Output depends on current state + input. Verification proceeds in two parts: input X state -> state and input X state -> output.

# Spec:
#
# Specify function: 
# {reset, enable, sampling_event} X {r_reset_n, sampling_event_prev} --> {r_reset_n, sampling_event_prev}
#
#  a) IF @t, reset
#  THEN @t+1, ~ovl_aoew_t.ovl_always_on_edge.r_reset_n AND
#             ~ovl_aoew_t.ovl_always_on_edge.sampling_event_prev
#  b) ELSE IF @t, ~reset AND enable AND sampling_event
#  THEN @t+1, ovl_aoew_t.ovl_always_on_edge.r_reset_n AND
#             ovl_aoew_t.ovl_always_on_edge.sampling_event_prev
#  c) ELSE IF @t, ~reset AND enable AND ~sampling_event
#  THEN @t+1, ovl_aoew_t.ovl_always_on_edge.r_reset_n AND
#             ~ovl_aoew_t.ovl_always_on_edge.sampling_event_prev
#  d) ELSE //@t, ~reset AND ~enable
#       ovl_aoew_t.ovl_always_on_edge.r_reset_n@t = ovl_aoew_t.ovl_always_on_edge.r_reset_n@t+1 AND
#       ovl_aoew_t.ovl_always_on_edge.sampling_event_prev@t = ovl_aoew_t.ovl_always_on_edge.sampling_event_prev@t+1

# Specify function:
# {reset, enable, sampling_event, test_expr, prevConfigInvalid} X {r_reset_n, sampling_event_prev} --> {out}
#
#  e) IF @t, reset OR ~enable OR ~sampling_event OR prevConfigInvalid
#  THEN @t, ~out   
# 
#  f) ELSE IF @t, ~reset AND enable AND sampling_event AND ~sampling_event_prev AND r_reset_n AND ~test_expr AND ~prevConfigInvalid
#  THEN @t, out
#
#  g) ELSE
#       @t, ~out
 
# 
# Properties:
 
\e : assert \rst -> X(G((\rst || ~\enable || ~\sampling_event || \prevConfigInvalid ) -> ~\out ));
 
\f : assert \rst -> X(G((~\rst && \enable && \sampling_event && ~\ovl_aoew_t .\ovl_always_on_edge .\sampling_event_prev && \ovl_aoew_t .\ovl_always_on_edge .\r_reset_n && ~\test_expr && ~\prevConfigInvalid ) -> \out ));
 
\g : assert \rst -> X(G(~(~\rst && \enable && \sampling_event && ~\ovl_aoew_t .\ovl_always_on_edge .\sampling_event_prev && \ovl_aoew_t .\ovl_always_on_edge .\r_reset_n && ~\test_expr && ~\prevConfigInvalid ) -> ~\out ));
 
\a : assert G(\rst -> X(~\ovl_aoew_t .\ovl_always_on_edge .\r_reset_n && ~\ovl_aoew_t .\ovl_always_on_edge .\sampling_event_prev ));

\b : assert \rst -> X(G(~\rst && \enable && \sampling_event -> X(\ovl_aoew_t .\ovl_always_on_edge .\r_reset_n && \ovl_aoew_t .\ovl_always_on_edge .\sampling_event_prev ))); 

\c : assert \rst -> X(G(~\rst && \enable && ~\sampling_event -> X(\ovl_aoew_t .\ovl_always_on_edge .\r_reset_n && ~\ovl_aoew_t .\ovl_always_on_edge .\sampling_event_prev )));
 
\d1 : assert \rst -> X(G(~\rst && ~\enable && \ovl_aoew_t .\ovl_always_on_edge .\r_reset_n -> X(\ovl_aoew_t .\ovl_always_on_edge .\r_reset_n )));

\d2 : assert \rst -> X(G(~\rst && ~\enable && ~\ovl_aoew_t .\ovl_always_on_edge .\r_reset_n -> X(~\ovl_aoew_t .\ovl_always_on_edge .\r_reset_n )));

\d3 : assert \rst -> X(G(~\rst && ~\enable && \ovl_aoew_t .\ovl_always_on_edge .\sampling_event_prev -> X(\ovl_aoew_t .\ovl_always_on_edge .\sampling_event_prev )));

\d4 : assert \rst -> X(G(~\rst && ~\enable && ~\ovl_aoew_t .\ovl_always_on_edge .\sampling_event_prev -> X(~\ovl_aoew_t .\ovl_always_on_edge .\sampling_event_prev )));

//SMV-Assertions
*/