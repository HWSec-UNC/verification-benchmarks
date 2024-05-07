  reg [width-1:0] last_test_expr;
  reg [width:0] temp_expr1;
  reg [width:0] temp_expr2;
  reg r_reset_n;
  reg fire_2state;
  wire fire_2state_comb;

  always @(last_test_expr or test_expr or `OVL_RESET_SIGNAL or r_reset_n)begin
     if(`OVL_RESET_SIGNAL == 1'b0 || r_reset_n)begin
	temp_expr1 = {(width+1){1'b0}};
	temp_expr2 = {(width+1){1'b0}};
     end
     else begin
	temp_expr1 = {1'b0,last_test_expr} - {1'b0,test_expr};
        temp_expr2 = {1'b0,test_expr} - {1'b0,last_test_expr};
     end
  end
   
   // assign fire_2state
  always @(posedge clk) begin
     fire_2state <= 1'b0;
     if(`OVL_RESET_SIGNAL != 1'b0)
       if(r_reset_n && (last_test_expr != test_expr))
         // 2's complement result
         if(!((temp_expr1 >= min && temp_expr1 `LTEQ max) || (temp_expr2 >= min && temp_expr2 `LTEQ max)))
	   fire_2state <= 1'b1;
  end

   // assign r_reset_n, the previous value of reset_n
   always @(posedge clk)
     if (`OVL_RESET_SIGNAL != 1'b0)
       r_reset_n <= `OVL_RESET_SIGNAL;
     else
       r_reset_n <= 0;

   // assign last_test_expr, the previous value of test_expr
   always @(posedge clk)
     if (`OVL_RESET_SIGNAL != 1'b0)
       last_test_expr <= test_expr;
     else
       last_test_expr <= {width{1'b0}};

   assign fire_2state_comb = `OVL_RESET_SIGNAL & enable & r_reset_n & (last_test_expr != test_expr) & !((temp_expr1 >= min && temp_expr1 `LTEQ max) | (temp_expr2 >= min && temp_expr2 `LTEQ max));
   
