  wire fire_2state_1;
  reg  fire_2state;
  wire fire_2state_comb;

  always @(posedge clk)
    if(`OVL_RESET_SIGNAL == 1'b0)
      fire_2state <= 1'b0;
    else if(enable)
      fire_2state <= fire_2state_1;

  assign fire_2state_1 = ~test_expr;
  assign fire_2state_comb = fire_2state_1 & `OVL_RESET_SIGNAL & enable;
  wire fire_xcheck = 1'b0;
  wire fire_cover = 1'b0;

   
