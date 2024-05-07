 /*
 * Peripheral Key Table (PKT) takes peripheral id for the aes key and outputs location of key in the ROM2 
 */


module pkt #(
)(
   input  logic         clk_i,
   input  logic         rst_ni,
   input  logic         req_i,
   input  logic [31:0]  key_index, // peripheral index of the key
   output logic [31:0]  pkey_loc_o // peripheral key location in ROM2 as the output
);
    localparam int RomSize = 1;
    logic [31:0]  pkey_loc_id; // key location id. Programmer should give proper location id. Valid values are mentioned in ariane soc package.

    
    
    always_ff @ (posedge clk_i) begin
        if (~rst_ni) begin
            pkey_loc_id <= 32'hffffffff; // Reset to highvalue. This much big key location won't present.
        end 
        else begin
            pkey_loc_id <= key_index; 
        end
    end

    always_ff @ (pkey_loc_id) begin
        //if (req) begin
            case (pkey_loc_id) // Peripheral Key Table.
                ariane_soc::AESKey_0 : pkey_loc_o <= 32'h0; 
                ariane_soc::AESKey_1 : pkey_loc_o <= 32'h1; 
                ariane_soc::AESKey_2 : pkey_loc_o <= 32'h2; 
                ariane_soc::AESKey_3 : pkey_loc_o <= 32'h3; 
                ariane_soc::AESKey_4 : pkey_loc_o <= 32'h4; 
                ariane_soc::AESKey_5 : pkey_loc_o <= 32'h5;
                default:  pkey_loc_o <= 32'hffff;
            endcase
        //end
    end
endmodule
