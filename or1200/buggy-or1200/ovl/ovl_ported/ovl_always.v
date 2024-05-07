// Accellera Standard V2.5 Open Verification Library (OVL).
// Accellera Copyright (c) 2005-2010. All rights reserved.

`ifdef SMV
 `include "ovl_ported/std_ovl_defines.h"
`else
 `include "std_ovl_defines.h"
`endif

`module ovl_always (clock, reset, enable, test_expr, fire, fire_comb);

  parameter severity_level = `OVL_SEVERITY_DEFAULT;
  parameter property_type  = `OVL_PROPERTY_DEFAULT;
  parameter msg            = `OVL_MSG_DEFAULT;
  parameter coverage_level = `OVL_COVER_DEFAULT;

  parameter clock_edge     = `OVL_CLOCK_EDGE_DEFAULT;
  parameter reset_polarity = `OVL_RESET_POLARITY_DEFAULT;
  parameter gating_type    = `OVL_GATING_TYPE_DEFAULT;

  input                          clock, reset, enable;
  input                          test_expr;
  output [`OVL_FIRE_WIDTH-1:0]   fire;
  output [`OVL_FIRE_WIDTH-1:0]   fire_comb;

  // Parameters that should not be edited
  parameter assert_name = "OVL_ALWAYS";

`ifdef SMV
  `include "ovl_ported/std_ovl_reset.h"
  `include "ovl_ported/std_ovl_clock.h"
  `include "ovl_ported/std_ovl_cover.h"
  `include "ovl_ported/std_ovl_init.h"
`else
  `include "std_ovl_reset.h"
  `include "std_ovl_clock.h"
  `include "std_ovl_cover.h"
  `include "std_ovl_init.h"
  `include "std_ovl_task.h"
`endif

`ifdef OVL_VERILOG
 `ifdef SMV
  `include "./ovl_ported/vlog95/ovl_always_logic.v"
 `else
  `include "./vlog95/ovl_always_logic.v"
 `endif
`endif

`ifdef OVL_SVA
  `include "./sva05/ovl_always_logic.sv"
`endif

`ifdef OVL_PSL
  `include "./psl05/assert_always_psl_logic.v"
 `else

  assign fire = {fire_cover, fire_xcheck, fire_2state};
  assign fire_comb = {2'b0, fire_2state_comb};

  `endmodule // ovl_always
`endif
