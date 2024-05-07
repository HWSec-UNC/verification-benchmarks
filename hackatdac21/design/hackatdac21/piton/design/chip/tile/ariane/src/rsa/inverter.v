`define UPDATING 3'd1
`define CHECK 3'd2
`define HOLDING 3'd3
/*to calculate decryption key 'd' and encryption key 'e' we use extended euclidian algorithm  
i.e                 d * e = 1 mod (phi)
*/
module inverter
#(parameter WIDTH = 1024
    )(
  input [WIDTH-1:0] p,//prime number 1
	input [WIDTH-1:0] q,//prime number 2
	input clk,
	input rst_n,
	output finish,//indicates finish for operation
	output [WIDTH*2-1:0] e,//encryption key
	output [WIDTH*2-1:0] d//decryption key
    );
    
    reg [WIDTH*2-1:0] totient_reg,a,b,y,y_prev;//totient here represents phi
    reg [2:0] state;
    reg [WIDTH*2-1:0] e_reg;
    
    wire [WIDTH*2-1:0] totient = (p-1)*(q-1);
    wire [WIDTH*2-1:0] quotient,b_next;
    wire [WIDTH*2-1:0] y_next = y_prev - quotient * y;
    wire [WIDTH*2-1:0] e_plus3 = e_reg + 2;
    assign finish = (state == `HOLDING) ? 1'b1 : 1'b0;
    assign e = e_reg;
    assign d = (e_reg == 1)? (totient+1) : y_prev;
    
    mod x_mod_y(a,b,b_next,quotient);//divider module
    defparam x_mod_y.WIDTH = WIDTH*2;
    
    always @(posedge clk) begin
        if(!rst_n) begin
            totient_reg <= totient;
            a <= totient;
            b <= 1;
            e_reg <=1;
            y <= 1;
            y_prev <= 0;
            state <= `UPDATING;
        end 
              case(state)
                `UPDATING: begin
                    if(b != 'd0) begin
                        a <= b;
                        b <= b_next;
                        y <= y_next;
                        y_prev <= y;
                        state <= `UPDATING;
                    end
                    else state <= `CHECK;
                 end
                `CHECK: begin
                    if(a == 'd1 && y_prev[WIDTH*2-1] == 1'b0) 
                        state <= `HOLDING;
                    else begin
                         a <= totient_reg;
                         b <= e_plus3;
                         e_reg <= e_plus3;
                         y <= 1;
                         y_prev <= 0;
                         state <= `UPDATING;
                   end
                 end
                `HOLDING: begin
                    end
           endcase 
    end
    
endmodule
