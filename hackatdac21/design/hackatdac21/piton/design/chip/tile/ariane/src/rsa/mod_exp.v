`define UPDATE 2'd1
`define HOLD 2'd2
/* to calculate *** a^b mod n *** we use right to left binary exponentiation (by .BRUCE SCHIENER)
*/
module mod_exp
    #(parameter WIDTH = 1024)(
    input [WIDTH*2-1:0] base,//base here represents (a) 
	input [WIDTH*2-1:0] modulo,//modulo here is modulus (n)
	input [WIDTH*2-1:0] exponent,//exponent here is the power of base (b)
	input clk,
	input rst_n,//resets module
	output finish,//sends finish signal on completion
    output [WIDTH*2-1:0] result
    );
        
    reg [WIDTH*2-1:0] base_reg,modulo_reg,exponent_reg,result_reg;
    reg [1:0] state;
    
    wire [WIDTH*2-1:0] result_mul_base = result_reg * base_reg;
    wire [WIDTH*2-1:0] result_next;
    wire [WIDTH*2-1:0] base_squared = base_reg * base_reg;
    wire [WIDTH*2-1:0] base_next;
    wire [WIDTH*2-1:0] exponent_next = exponent_reg >> 1;
    
    assign finish = (state == `HOLD) ? 1'b1:1'b0;
    assign result = result_reg;
    
    mod base_squared_mod(base_squared,modulo_reg,base_next,);                   //  implementation of 
    defparam base_squared_mod.WIDTH = WIDTH*2;                                  //  right to left 
                                                                                //  binary exponentiation  
    mod result_mul_base_mod (result_mul_base,modulo_reg,result_next,);          //  by.
    defparam result_mul_base_mod.WIDTH = WIDTH*2;                               //  BRUCE SCHIEMER
    
   
    always @(posedge clk) begin
        if(!rst_n) begin                                                         //initialisation of values
            base_reg <= base;
            modulo_reg <= modulo;
            exponent_reg <= exponent;                
            result_reg <= 'd1;
            state <= `UPDATE;
        end
        else case(state)
            `UPDATE: begin
                if (exponent_reg != 'd0) begin
                    if (exponent_reg[0])
                        result_reg <= result_next;
                    base_reg <= base_next;
                    exponent_reg <= exponent_next;
                    state <= `UPDATE;
                end
                else state <= `HOLD;
            end
            
           `HOLD: begin
                end
       endcase
    end
endmodule
