  wire [num_cks_width-1:0] num_cks_1 = num_cks-1;
  reg  [num_cks_max-1:0] monitor;
  wire [num_cks_max-1:0] monitor_1 = (monitor << 1);
  wire fire_2state_comb;

  always @(posedge clk)
    if (`OVL_RESET_SIGNAL == 1'b0)
      monitor <= {num_cks_max{1'b0}};
    else if(enable)
      monitor <= (monitor_1 | start_event);

  wire fire_2state_1, fire_2state_2, fire_2state_3;
  reg  fire_2state;
   
  always @(posedge clk)
     if(`OVL_RESET_SIGNAL == 1'b0)
       fire_2state <= 1'b0;
     else if(enable)
       fire_2state <= fire_2state_1 | fire_2state_2 | fire_2state_3;

  assign fire_2state_1 = ((check_overlapping == 0) && (monitor_1 != {num_cks_max{1'b0}}) && start_event); // new start_event can occur in cycle test_expr is checked
  assign fire_2state_2 = ((check_missing_start != 0) && ~monitor[num_cks_1] && test_expr);
  assign fire_2state_3 = (monitor[num_cks_1] && ~test_expr);

  wire fire_xcheck = 1'b0;
  wire fire_cover = 1'b0;
  assign fire_2state_comb = `OVL_RESET_SIGNAL & enable & (fire_2state_1 | fire_2state_2 | fire_2state_3);
   
