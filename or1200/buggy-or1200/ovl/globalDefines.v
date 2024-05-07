//`default net_type none
`ifndef FABRIC_GLOBAL
 `define FABRIC_GLOBAL

 `ifdef SUBDIR
  `include "../../or1200/or1200_defines.v"
 `else
  `include "../or1200/or1200_defines.v"
 `endif
 `ifdef SMV
  `define LTEQ =<
 `else
  `define LTEQ <=
 `endif

 
`endif

// `define ROUTING_INPUT_BITS 544
// `define ROUTING_NUM_INPUTS 17
// `define ROUTING_NUM_INPUTS_LOG_2 5
 `define ROUTING_INPUT_BITS 119
 `define ROUTING_NUM_INPUTS 6
 `define ROUTING_NUM_INPUTS_LOG_2 3
 `define ROUTING_INPUT_WIDTH 32