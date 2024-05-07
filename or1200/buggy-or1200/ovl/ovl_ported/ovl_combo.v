`ifdef SMV
 `include "ovl_ported/std_ovl_defines.h"
`else
 `include "std_ovl_defines.h"
`endif

`module ovl_combo (clock, reset, enable, num_cks, start_event, test_expr, select, fire_comb);
  parameter severity_level      = `OVL_SEVERITY_DEFAULT;
  parameter check_overlapping   = 1;
  parameter check_missing_start = 0;
  parameter num_cks_max         = 7;
  parameter num_cks_width       = 3;
  parameter property_type       = `OVL_PROPERTY_DEFAULT;
  parameter msg                 = `OVL_MSG_DEFAULT;
  parameter coverage_level      = `OVL_COVER_DEFAULT;

  parameter clock_edge          = `OVL_CLOCK_EDGE_DEFAULT;
  parameter reset_polarity      = `OVL_RESET_POLARITY_DEFAULT;
  parameter gating_type         = `OVL_GATING_TYPE_DEFAULT;

  input                          clock, reset, enable;
  input	 [num_cks_width-1:0]     num_cks;
  input                          start_event, test_expr;
  input	[1:0]				 select;
  output [`OVL_FIRE_WIDTH-1:0]   fire_comb;

  // Parameters that should not be edited
  parameter assert_name = "OVL_COMBO";

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

`ifdef SMV
  `include "./ovl_ported/vlog95/ovl_combo_logic.v"
`else
  `include "./vlog95/ovl_combo_logic.v"
`endif

assign fire_comb = {2'b0, fire_2state_comb};

`endmodule