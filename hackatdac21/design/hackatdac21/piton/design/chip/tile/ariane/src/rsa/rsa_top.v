module rsa_top
#(parameter WIDTH=1024
	)(
    input clk,//system wide clock
    input rst_n,//resets inverter module
    input rst1_n,//resets modular exponentiation module
    input encrypt_decrypt_i,//1 for encryption and 0 for decryption
    input [WIDTH-1:0] p_i,q_i, //Input Random Primes
    input [WIDTH*2-1:0] msg_in,//input either message or cipher
    output [WIDTH*2-1:0] msg_out,//output either decrypted message or cipher
    output mod_exp_finish_o//finish signal indicator of mod exp module
    );
    
    wire inverter_finish;
    wire [WIDTH*2-1:0] e,d;
    wire [WIDTH*2-1:0] exponent = encrypt_decrypt_i?e:d;
    wire [WIDTH*2-1:0] modulo = p_i*q_i;
    wire mod_exp_reset  = 1'b0;
    

    //Signla will delay one cycle to module
    //after we set signal value, we need to delay one cycle to reset signal
    reg [WIDTH*2-1:0] exp_reg,msg_reg;
    reg [WIDTH*2-1:0] mod_reg;
    
    always @(posedge clk)begin
         exp_reg <= exponent;
         mod_reg <= modulo;
         msg_reg <= msg_in;
    end
    
    inverter i(p_i,q_i,clk,rst_n,inverter_finish,e,d);
    defparam i.WIDTH = WIDTH;
    mod_exp m(msg_reg,mod_reg,exp_reg,clk,rst1_n,mod_exp_finish_o,msg_out);
    defparam m.WIDTH = WIDTH;
    
endmodule
