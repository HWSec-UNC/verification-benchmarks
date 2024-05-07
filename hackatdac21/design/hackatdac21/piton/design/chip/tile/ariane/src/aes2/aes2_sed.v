/*
 * Description:
 * AES is implemented in CTR mode.
 * Give 128 bit input to "p_c_text" (plain/cipher text).
 * Give 128 bit key to "key".
 * Give 128 initial vector to "state".
 *
 * Conditions: 
 * Don't give new inputs and start until assertion of out_valid.
 * Start has to go from 0 to 1 for the correct starting.
 * "state" value should be same for both encryption and decryption.
 *
 * sed: Serialized Encryption and Decryption
 */

module aes2_sed(clk, rst, start, p_c_text, key, out, out_valid); 
    input          clk;
    input          start;
    input          rst;
    input  [127:0] p_c_text; // input
    input  [127:0] key; // key
    output [127:0] out; // out
    output         out_valid; // out_valid
	
    wire    [127:0] out_temp;
    wire     out_valid;
    
    // Instantiate the Unit Under Test (UUT)
	aes_cipher_top uut (
        .clk(clk),
        .rst(rst),
        .ld(start),
        .done(out_valid),
        .key(key),
        .text_in(p_c_text),
        .text_out(out_temp)
	);
	
	assign out = out_valid ? out_temp : out;
	// assign done = out_valid ? out_valid : done;
	
    // Muxing p_c_text with output of AES core.
    // assign out = p_c_text ^ out_temp;

endmodule

