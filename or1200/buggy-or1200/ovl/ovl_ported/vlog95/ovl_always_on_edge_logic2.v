    reg sampling_event_prev;
    reg r_reset_n;
    reg fire_2state;
    wire fire_2state_comb;

    //assign r_reset_n
    always @(posedge clk)
      if(`OVL_RESET_SIGNAL == 1'b0)
	r_reset_n <= 1'b0;
      else if(enable)
	r_reset_n <= 1'b1;
   
   //assign sampling_event_prev
   always @(posedge clk)
      if(`OVL_RESET_SIGNAL == 1'b0)
         sampling_event_prev <= 1'b0;
      else if(enable)
         sampling_event_prev <= sampling_event;
   
   //assign fire_2state
   always @(posedge clk)
      if(`OVL_RESET_SIGNAL == 1'b0)
	fire_2state <= 1'b0;
      else if(enable)
        fire_2state <= ~sampling_event_prev & sampling_event & ~test_expr & r_reset_n;

   assign fire_2state_comb = `OVL_RESET_SIGNAL & enable & ~sampling_event_prev & sampling_event & ~test_expr & r_reset_n;
