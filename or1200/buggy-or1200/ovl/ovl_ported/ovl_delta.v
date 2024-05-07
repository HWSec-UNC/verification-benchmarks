// Accellera Standard V2.5 Open Verification Library (OVL).
// Accellera Copyright (c) 2005-2010. All rights reserved.

`ifdef SMV
 `include "ovl_ported/std_ovl_defines.h"
 `include "globalDefines.vh"
`else
 `include "std_ovl_defines.h"
 `include "../globalDefines.vh"
`endif

`module ovl_delta (clock, reset, enable, min, max, test_expr, fire, fire_comb);

  parameter severity_level = `OVL_SEVERITY_DEFAULT;
  parameter width          = 1;
  parameter limit_width    = 1;
  parameter property_type  = `OVL_PROPERTY_DEFAULT;
  parameter msg            = `OVL_MSG_DEFAULT;
  parameter coverage_level = `OVL_COVER_DEFAULT;
  parameter clock_edge     = `OVL_CLOCK_EDGE_DEFAULT;
  parameter reset_polarity = `OVL_RESET_POLARITY_DEFAULT;
  parameter gating_type    = `OVL_GATING_TYPE_DEFAULT;

  input                          clock, reset, enable;
  input  [limit_width-1:0]       min, max;
  input  [width-1:0]             test_expr;
  output [`OVL_FIRE_WIDTH-1:0]   fire;
  output [`OVL_FIRE_WIDTH-1:0]   fire_comb;

  // Parameters that should not be edited
  parameter assert_name = "OVL_DELTA";

`ifdef SMV
  `include "ovl_ported/std_ovl_reset.h"
  `include "ovl_ported/std_ovl_clock.h"
  `include "ovl_ported/std_ovl_cover.h"
  `include "ovl_ported/std_ovl_init.h"
 `else
  `include "std_ovl_reset.h"
  `include "std_ovl_clock.h"
  `include "std_ovl_cover.h"
  `include "std_ovl_task.h"
  `include "std_ovl_init.h"
 `endif // !`ifdef SMV

 `ifdef OVL_VERILOG
  `ifdef SMV
   `include "./ovl_ported/vlog95/assert_delta_logic.v"
  `else
   `include "./vlog95/assert_delta_logic.v"
  `endif
assign fire = {1'b0, 1'b0, fire_2state};
assign fire_comb = {2'b0, fire_2state_comb};
 `endif


`ifdef OVL_SVA
  `include "./sva05/assert_delta_logic.sv"
  assign fire = {`OVL_FIRE_WIDTH{1'b0}}; // Tied low in V2.3
`endif

`ifdef OVL_PSL
  assign fire = {`OVL_FIRE_WIDTH{1'b0}}; // Tied low in V2.3
  `include "./psl05/assert_delta_psl_logic.v"
`else
  `endmodule // ovl_delta
`endif
