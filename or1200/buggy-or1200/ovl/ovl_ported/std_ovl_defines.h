// Accellera Standard V2.5 Open Verification Library (OVL).
// Accellera Copyright (c) 2005-2010. All rights reserved.

`ifdef OVL_STD_DEFINES_H
// do nothing
`else
`define OVL_STD_DEFINES_H

`define OVL_VERSION "V2.5"

`ifdef SMV
`ifdef SUBDIR
`include "../globalDefines.vh"
`else
`include "globalDefines.vh"
`endif
`else
`include "../globalDefines.vh"
`endif

`define OVL_SYNTHESIS
`define OVL_VERILOG
`define OVL_ASSERT_ON
`define OVL_SHARED_CODE

`define module module
`define endmodule endmodule

// active edges
`define OVL_NOEDGE  0
`define OVL_POSEDGE 1
`define OVL_NEGEDGE 2
`define OVL_ANYEDGE 3

`define OVL_EDGE_TYPE_DEFAULT `OVL_POSEDGE

// severity levels
`define OVL_FATAL   0
`define OVL_ERROR   1
`define OVL_WARNING 2
`define OVL_INFO    3

`define OVL_SEVERITY_DEFAULT `OVL_WARNING

// coverage levels (note that 3 would set both SANITY & BASIC)
`define OVL_COVER_NONE      0
`define OVL_COVER_SANITY    1
`define OVL_COVER_BASIC     2
`define OVL_COVER_CORNER    4
`define OVL_COVER_STATISTIC 8
`define OVL_COVER_ALL       15

`define OVL_COVER_DEFAULT `OVL_COVER_NONE

// property type
`define OVL_ASSERT        0
`define OVL_ASSUME        1
`define OVL_IGNORE        2
`define OVL_ASSERT_2STATE 3
`define OVL_ASSUME_2STATE 4

`define OVL_PROPERTY_DEFAULT `OVL_ASSERT_2STATE

// fire bit positions (first two also used for xcheck input to error_t)
`define OVL_FIRE_2STATE 0
`define OVL_FIRE_XCHECK 1
`define OVL_FIRE_COVER  2

// auto_bin_max for covergroups, default value is set as per LRM recommendation
`define OVL_AUTO_BIN_MAX_DEFAULT 64
`define OVL_AUTO_BIN_MAX `OVL_AUTO_BIN_MAX_DEFAULT 

`define OVL_MSG_DEFAULT "VIOLATION"

// necessary condition
`define OVL_TRIGGER_ON_MOST_PIPE    0
`define OVL_TRIGGER_ON_FIRST_PIPE   1
`define OVL_TRIGGER_ON_FIRST_NOPIPE 2

// default necessary_condition (ovl_cycle_sequence)
`define OVL_NECESSARY_CONDITION_DEFAULT `OVL_TRIGGER_ON_MOST_PIPE

// action on new start
`define OVL_IGNORE_NEW_START   0
`define OVL_RESET_ON_NEW_START 1
`define OVL_ERROR_ON_NEW_START 2

// default action_on_new_start (e.g. ovl_change)
`define OVL_ACTION_ON_NEW_START_DEFAULT `OVL_IGNORE_NEW_START

// inactive levels
`define OVL_ALL_ZEROS 0
`define OVL_ALL_ONES  1
`define OVL_ONE_COLD  2

// default inactive (ovl_one_cold)
`define OVL_INACTIVE_DEFAULT `OVL_ONE_COLD

// new interface (ovl 2)
`define OVL_ACTIVE_LOW  0
`define OVL_ACTIVE_HIGH 1

`define OVL_GATE_NONE  0
`define OVL_GATE_CLOCK 1
`define OVL_GATE_RESET 2

`define OVL_FIRE_WIDTH   3

`define OVL_CLOCK_EDGE_DEFAULT `OVL_POSEDGE

// Selecting global reset or local reset for the checker reset signal
// Use the polarity of the input reset signal as used by the rest of the system
`ifdef OR1200_RST_ACT_LOW
    `define OVL_RESET_POLARITY_DEFAULT `OVL_ACTIVE_LOW
`else
    `define OVL_RESET_POLARITY_DEFAULT `OVL_ACTIVE_HIGH
`endif

`define OVL_RESET_SIGNAL reset_n

`define OVL_GATING_TYPE_DEFAULT `OVL_GATE_NONE

// ovl runtime after fatal error
`define OVL_RUNTIME_AFTER_FATAL 100

// Ensure x-checking logic disabled if ASSERTs are off
`define OVL_XCHECK_OFF
`define OVL_IMPLICIT_XCHECK_OFF

`endif // OVL_STD_DEFINES_H
