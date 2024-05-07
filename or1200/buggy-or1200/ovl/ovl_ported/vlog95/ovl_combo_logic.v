  // Make index 1 based, otherwise I would need subtraction
  reg  [num_cks_max:1] monitor;
  wire fire_2state_comb;

  always @(posedge clk)
    if (`OVL_RESET_SIGNAL == 1'b0)
      monitor <= {num_cks_max{1'b0}};
    else if(enable)
      monitor <= {monitor[num_cks_max-1:1], start_event};

  wire fire_gate = `OVL_RESET_SIGNAL & enable;

  wire fire_prop = ~test_expr;
  wire fire_always = fire_prop;
  wire fire_edge = monitor[1] & ~monitor[2] & fire_prop;
  wire fire_next = monitor[num_cks] & fire_prop;

  wire fire_selected = (select == 2) ? fire_prop : (select == 3) ? fire_always : (select == 0) ? fire_edge : fire_next;

  assign fire_2state_comb = fire_gate & fire_selected;
  wire fire_xcheck = 1'b0;
  wire fire_cover = 1'b0;