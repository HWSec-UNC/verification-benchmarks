/*
 * Description:
 * AES is implemented in CTR mode.
 * Give 128 bit input to "p_c_text" (plain/cipher text).
 * Give 192 bit key to "key".
 * Give 128 initial vector to "state".
 *
 * Conditions: 
 * Don't give new inputs and start until assertion of out_valid.
 * Start has to go from 0 to 1 for the correct starting.
 * "state" value should be same for both encryption and decryption.
 *
 * sed: Serialized Encryption and Decryption
 */

module aes_192_sed(clk, start, state, p_c_text, key, out, out_valid); 
    input          clk;
    input          start;
    input  [127:0] state, p_c_text;
    input  [191:0] key;
    output [127:0] out;
    output         out_valid;
	
    wire    [127:0] out_temp;
    wire     out_valid;
    
    // Instantiate the Unit Under Test (UUT)
	aes_192 uut (
		.clk(clk), 
		.start(start), 
		.state(state), 
		.key(key), 
		.out(out_temp),
		.out_valid(out_valid)
	);

    // Muxing p_c_text with output of AES core.
    assign out = p_c_text ^ out_temp;

endmodule

