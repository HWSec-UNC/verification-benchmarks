  reg fire_2state;

  always @(`OVL_RESET_SIGNAL or test_expr or enable)
     if (`OVL_RESET_SIGNAL == 1'b0)
       fire_2state = 1'b0;
     else
       fire_2state = ~test_expr & ~enable;
