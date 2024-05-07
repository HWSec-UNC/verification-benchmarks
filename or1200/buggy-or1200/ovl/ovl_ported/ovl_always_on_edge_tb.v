`define SMV
`define SUBDIR

`ifdef SUBDIR
`include "ovl_always_on_edge.v"
`else
`include "ovl_ported/ovl_always_on_edge.v"
`endif

`define OVL_INIT_REG
/*
 
 * File: ovl_always_on_edge_tb.v
 * Test bench for ovl_alwaysZ_on_edge.v
 * Includes assertions for verification
 * Created: 2013-10-10
 * 
 * Verified for both vlog95/ovl_always_on_edge_logic.v and vlog95/ovl_always_on_edge_logic2.v.
 */

module main();

   // Inputs to DUT
   reg clk;
   reg reset;
   reg enable;
   reg sampling_event;
   reg test_expr;

   // Outputs of DUT
   //In the DUT module, this width is parameterized by OVL_FIRE_WIDTH-1. 
   wire [2:0] fire;

   ovl_always_on_edge ovl_aoe_t(.clock(clk),
                                .reset(reset),
                                .enable(enable),
                                .sampling_event(sampling_event),
                                .test_expr(test_expr),
                                .fire(fire),
                                .edge_type(1),
                                .property_type(3),
                                .clock_edge(1),
                                .reset_polarity(0),
                                .gating_type(0),
                                .severity_level(3));

   initial begin
      clk = 0;
      reset = 1;
      enable = 0;
      sampling_event = 0;
      test_expr = 0;
      
   end
   always begin
      clk = #5 !clk;
   end
   
endmodule // main

/* ***************** SMV Assertions ******************
//SMV-Assertions
# The ovl_always_on_edge is an assertion module that checks if sampling_event has a rising edge, then test_expr will be high. The spec states that if this check fails, then ovl_always_on_edge will "fire" an event. i.e. "~(pos_edge_sampling_event -> test_expr) -> X(fire)". This can be rewritten "(pos_edge_sampling_event && ~test_expr) -> X(fire)". 

# The first set of assertions verify that we correctly understand the semantics of the code. Using the variables in the "if" statement, these assertions verify that fire_2state is triggered exactly under the set of conditions that we expect.

# The code works as we expect. If the conditions of the "if" statement are satisfied, fire_2state is triggered.
\follow_code : assert ~\ovl_aoe_t .\reset_n  -> X(G((\ovl_aoe_t .\reset_n && \ovl_aoe_t .\sampling_event && ~\ovl_aoe_t .\test_expr && ~\ovl_aoe_t .\sampling_event_prev && \ovl_aoe_t .\r_reset_n )-> X(\ovl_aoe_t .\fire_2state )));
 
# The code works as we epxect. fire_2state never fires without a rising edge of sampling event.
\never_fires_wo_rising_sampling_edge : assert ~\ovl_aoe_t .\reset_n -> X(G((\ovl_aoe_t .\sampling_event_prev || ~\ovl_aoe_t .\sampling_event ) -> X(~\ovl_aoe_t .\fire_2state )));

# The code works as we expect. fire_2state never fires without test_expr low. 
\never_fires_wo_test_expr : assert ~\ovl_aoe_t .\reset_n -> X(G(\ovl_aoe_t .\test_expr -> X(~\ovl_aoe_t .\fire_2state )));
  
# The second set of assertions verify the code correctly implements the spec as given by the timing diagram "assert_always_on_edge" for a rising edge, pg 14 of assert_timing_diagram.pdf. These assertions use only the variables appearing in the timing diagram, plus reset.
 
# test_expr should always be high on a rising edge of sampling_event. If it is not, an event ("fire_2state") is triggered.
\trigger_if_low_test_and_rising_sampling_edge : assert reset -> X(G((~\reset && ~\sampling_event ) -> X((~\reset && \sampling_event && ~\test_expr ) -> X(\fire = 1))));

# Although not given in the spec, we would also like to verify that an event is triggered only when test_expr is low on a rising edge of sampling_event.
# An event is not triggered if there is no rising edge.
\never_fires_wo_rising_sampling_edge1 : assert reset -> X(G((~\sampling_event ) -> X(\fire = 0)));
\never_fires_wo_rising_sampling_edge2 : assert reset -> X(G((\sampling_event ) -> X(X(\fire = 0))));
 
# An event is not triggered if test_expr is high.
\never_fires_wo_test_expr1 : assert reset -> X(G(\test_expr -> X(\fire = 0)));
 
//SMV-Assertions
*/ 