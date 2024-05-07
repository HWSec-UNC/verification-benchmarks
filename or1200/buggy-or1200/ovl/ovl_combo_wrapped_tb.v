`define SMV

`include "ovl_combo_wrapped.v"
`include "ovl_ported/ovl_combo.v"

/*
 
 * File: ovl_combo_wrapped_tb.v
 * Verification driver for ovl_combo_wrapped.v
 * Includes assertions for verification
 * 
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
   reg [1:0] select;
   reg       prevConfigInvalid;

   // Outputs of DUT
   wire      out;
   wire      out_delayed;
   wire      configInvalid;

   ovl_combo_wrapped ovl_cw_t(.clk(clk),
                              .rst(rst),
                              .enable(enable),
                              .num_cks(num_cks),
                              .start_event(start_event),
                              .test_expr(test_expr),
                              .select(select),
                              .prevConfigInvalid(prevConfigInvalid),
                              .out(out),
                              .out_delayed(out_delayed),
                              .configInvalid(configInvalid));

   initial begin
      clk = 0;
      rst = 1;
      enable = 0;
      num_cks = 0;
      start_event = 0;
      test_expr = 0;
      select = 0;
      prevConfigInvalid = 0;
   end

   always begin
      clk = #5 !clk;
   end

endmodule // main

/* *************** SMV Assertions *****************
//SMV-Assertions
# Spec:
# Select = 0, works like ovl_edge
# Select = 1, works like ovl_next
# Select = 2, works like fire_always
# Select = 3, works like fire_always

# Select = *
# IF @t, prevConfigInvalid OR (num_cks = 0 AND (select=0 OR select=1))
# THEN @t, configInvalid
# ELSE @t, ~configInvalid  

# verify then branch
\spec_thenstar : assert \rst -> X(G((prevConfigInvalid || ((\num_cks = 0 ) && ((\select = 0) || (\select = 1)))) -> \configInvalid ));
# verify else branch  
\spec_elsestar : assert \rst -> X(G(((~\prevConfigInvalid ) && (~(\num_cks = 0) || (~(\select = 0) && ~(\select = 1)))) -> ~\configInvalid ));
 
################ Select = 2,3. Always ################# 
# Select = 2, 3. always
# IF @t, ~reset AND ~test_expr AND enable
# THEN @t, out
# ELSE @t, ~out
 
# verify then branch of spec
\spec_then2 : assert \rst -> X(G(((\select = 2) && (~\rst ) && (~\test_expr ) && \enable ) -> \out ));
\spec_then3 : assert \rst -> X(G(((\select = 3) && (~\rst ) && (~\test_expr ) && \enable ) -> \out ));

# verify else branch of spec  
\spec_else23 : assert \rst -> X(G(( \rst || \test_expr || ~\enable ) -> ~\out ));

################ Select = 1. Next ############## 
#With assume G(enable)
# Select = 1. Next
#  @time t: 
#     IF start_event occurred at t-num_cks AND ~test_expr 
#     THEN @t out

\select1 : assert G(\select = 1);


# implements the spec for num_cks_max = 1
\spec_then1cks1 : assert \rst -> X(G((~\rst && \start_event && X(~\rst && ~\test_expr && (\num_cks = 1))) -> X(X(\out ))));
   
\spec_else1cks1 : assert \rst -> X(G((~(~\rst && \start_event && X(~\rst && ~\test_expr && (\num_cks = 1)))) -> X(X(~\out ))));
  
# implements the spec for num_cks_max = 2
\spec_then1cks2 : assert \rst -> X(G((~\rst && \start_event && X(~\rst && X(~\rst && ~\test_expr && (\num_cks = 2)))) -> X(X(X(\out )))));
\spec_else1cks2 : assert \rst -> X(G((~(~\rst && \start_event && X(~\rst && X(~\rst && ~\test_expr && (\num_cks = 2))))) -> X(X(X(~\out ))))); 
  
# implements the spec for num_cks_max = 3
\spec_then1cks3 : assert \rst -> X(G((~\rst && \start_event && X(~\rst && X(~\rst && X(~\rst && ~\test_expr && (\num_cks = 3))))) -> X(X(X(X(\out ))))));
\spec_else1cks3 : assert \rst -> X(G((~(~\rst && \start_event && X(~\rst && X(~\rst && X(~\rst && ~\test_expr && (\num_cks = 3)))))) -> X(X(X(X(~\out ))))));
 
using \global_enable ,\select1 prove \spec_then1cks1 , \spec_then1cks2 ,\spec_then1cks3 ,\spec_else1cks1 ,\spec_else1cks2 ,\spec_else1cks3 ;
#assume \global_enable ,\select1 ;

# Show output (out) is deterministic function of input and state. Showing w/num_cks=3.
#OUTPUT: out
#INPUT: rst, assume G(enable), start_event, test_expr, select=1, num_cks=3
#STATE: monitor[7:1] 
numcks3 : assert G(num_cks = 3);
 
\det1 : assert \rst -> X(G(~\start_event -> (~\out )));
\det2 : assert \rst -> X(G(\test_expr -> (~\out )));
\det3 : assert \rst -> X(G((~\rst ) && \start_event && (~\test_expr ) && (~\ovl_cw_t .\ovl_combo .\monitor [4]) -> (~\out )));
\det4 : assert \rst -> X(G((~\rst ) && \start_event && (~\test_expr ) && (\ovl_cw_t .\ovl_combo .\monitor [4]) -> (\out )));
using \numcks3 ,\select1 ,\global_enable prove \det1 ,\det2 ,\det3 ,\det4 ; 
assume \numcks3 ,\select1 ,\global_enable ;
 
################ Select = 0. On edge ############## 
#With assume G(enable)
# Select = 0. on edge
# IF @t, ~reset AND ~start_event AND enable
# AND @t+1 ~reset AND start_event AND enable AND ~test_expr 
# THEN @t+1 out
# ELSE @t+1 ~out

\select0 : assert G(\select = 0);
  
\global_enable : assert G(\enable );
\spec_then0 : assert \rst -> X(G((~\rst && ~\start_event && \enable ) -> X((~\rst && \start_event && enable && ~\test_expr ) -> \out )));
\spec_else0 : assert \rst -> X(G(((~\rst && ~\start_event && \enable ) && X(~\rst && \start_event && \enable && ~\test_expr )) || X(~\out )));
using \global_enable prove \spec_then0 ,\spec_else0 ;
#assume \global_enable ;
 
#Show reset clears state
\reset_clears_state : assert G(\rst -> X((\ovl_cw_t .\ovl_combo .\monitor = 0) && (~\ovl_cw_t .\out_delayed )));
  
#Show output is always ~out when stuttering is present 
\no_out_stutter : assert \rst -> X(G(~\enable -> ~\out ));
 
#Show output (out) is determnistic function of input and state.
#OUTPUT: out
#INPUT: rst, assume G(enable), start_event, test_expr, select=0
#STATE: monitor[7:1]
\deterministic1 : assert \rst -> X(G(\rst -> ~\out ));
using \global_enable ,\select0 prove \deterministic1 ;
\deterministic2 : assert \rst -> X(G(\test_expr -> ~\out ));
\deterministic3 : assert \rst -> X(G((~\rst && ~\start_event ) -> ~\out )); 
using \global_enable ,\select0 prove deterministic3 ;
\deterministic4 : assert \rst -> X(G((~\rst && \start_event && ~\test_expr && (~(\ovl_cw_t .\ovl_combo .\monitor [2]))) -> \out ));
using \global_enable ,\select0 prove \deterministic4 ; 
\deterministic5 : assert \rst -> X(G((~\rst && \start_event && ~\test_expr && (\ovl_cw_t .\ovl_combo .\monitor [2])) -> ~\out ));
using \global_enable ,\select0 prove \deterministic5 ;
#assume \global_enable ,\select0 ;
  
#Show state (out_delayed, monitor[7:1]) does not change when ~enable and ~reset.
\stutter_out_delayed : assert \rst -> X(G((\ovl_cw_t .\out_delayed && (~\enable ) && (~\rst )) -> X(\ovl_cw_t .\out_delayed )));
\stutter_out_delayedn : assert \rst -> X(G((~\ovl_cw_t .\out_delayed && (~\enable && (~\rst ))) -> X(~\ovl_cw_t .\out_delayed )));
 
\stutter_monitor1 : assert \rst -> X(G(((\ovl_cw_t .\ovl_combo .\monitor [1]) && (~\enable ) && (~\rst )) -> X(\ovl_cw_t .\ovl_combo .\monitor [1])));
\stutter_monitor1n : assert \rst -> X(G(((~\ovl_cw_t .\ovl_combo .\monitor [1]) && (~\enable ) && (~\rst )) -> X((~\ovl_cw_t .\ovl_combo .\monitor [1]))));

\stutter_monitor2 : assert \rst -> X(G(((\ovl_cw_t .\ovl_combo .\monitor [2]) && (~\enable ) && (~\rst )) -> X(\ovl_cw_t .\ovl_combo .\monitor [2])));
\stutter_monitor2n : assert \rst -> X(G(((~\ovl_cw_t .\ovl_combo .\monitor [2]) && (~\enable ) && (~\rst )) -> X((~\ovl_cw_t .\ovl_combo .\monitor [2]))));

\stutter_monitor3 : assert \rst -> X(G(((\ovl_cw_t .\ovl_combo .\monitor [3]) && (~\enable ) && (~\rst )) -> X(\ovl_cw_t .\ovl_combo .\monitor [3])));
\stutter_monitor3n : assert \rst -> X(G(((~\ovl_cw_t .\ovl_combo .\monitor [3]) && (~\enable ) && (~\rst )) -> X((~\ovl_cw_t .\ovl_combo .\monitor [3]))));

\stutter_monitor4 : assert \rst -> X(G(((\ovl_cw_t .\ovl_combo .\monitor [4]) && (~\enable ) && (~\rst )) -> X(\ovl_cw_t .\ovl_combo .\monitor [4])));
\stutter_monitor4n : assert \rst -> X(G(((~\ovl_cw_t .\ovl_combo .\monitor [4]) && (~\enable ) && (~\rst )) -> X((~\ovl_cw_t .\ovl_combo .\monitor [4]))));

\stutter_monitor5 : assert \rst -> X(G(((\ovl_cw_t .\ovl_combo .\monitor [5]) && (~\enable ) && (~\rst )) -> X(\ovl_cw_t .\ovl_combo .\monitor [5])));
\stutter_monitor5n : assert \rst -> X(G(((~\ovl_cw_t .\ovl_combo .\monitor [5]) && (~\enable ) && (~\rst )) -> X((~\ovl_cw_t .\ovl_combo .\monitor [5]))));

\stutter_monitor6 : assert \rst -> X(G(((\ovl_cw_t .\ovl_combo .\monitor [6]) && (~\enable ) && (~\rst )) -> X(\ovl_cw_t .\ovl_combo .\monitor [6])));
\stutter_monitor6n : assert \rst -> X(G(((~\ovl_cw_t .\ovl_combo .\monitor [6]) && (~\enable ) && (~\rst )) -> X((~\ovl_cw_t .\ovl_combo .\monitor [6]))));

\stutter_monitor7 : assert \rst -> X(G(((\ovl_cw_t .\ovl_combo .\monitor [7]) && (~\enable ) && (~\rst )) -> X(\ovl_cw_t .\ovl_combo .\monitor [7])));
\stutter_monitor7n : assert \rst -> X(G(((~\ovl_cw_t .\ovl_combo .\monitor [7]) && (~\enable ) && (~\rst )) -> X((~\ovl_cw_t .\ovl_combo .\monitor [7]))));

//SMV-Assertions
*/
      
      
    