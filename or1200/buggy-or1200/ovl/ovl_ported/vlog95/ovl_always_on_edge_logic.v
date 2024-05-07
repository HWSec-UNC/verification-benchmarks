  reg sampling_event_prev;
  reg r_reset_n;

  reg fire_2state;

  always @(posedge clk) begin
    fire_2state <= 1'b0;

    if(`OVL_RESET_SIGNAL != 1'b0) begin
       if((!sampling_event_prev) && (sampling_event) && (!test_expr) && r_reset_n) begin
	        fire_2state <= 1'b1;
       end

       //(CKS) Moved these statements here. Used to be above the "if((!sampling..."
       r_reset_n <= `OVL_RESET_SIGNAL;
       sampling_event_prev <= sampling_event;
    end
    else begin
      r_reset_n <= 1'b0;
      sampling_event_prev <= 1'b0;
    end
  end

