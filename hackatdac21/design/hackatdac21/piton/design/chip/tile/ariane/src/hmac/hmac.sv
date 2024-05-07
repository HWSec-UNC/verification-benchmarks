module hmac(
           key_i, ikey_hash_i, okey_hash_i, key_hash_bypass_i, message_i,
           hash_o, ready_o, hash_valid_o,
           clk_i, rst_ni, init_i
       );

parameter IDLE = 4'd0, 
          HASHI_1 = 4'd1, HASHI_1_WAIT = 4'd2,
          HASHI_2 = 4'd3, HASHI_2_WAIT = 4'd4,
          HASHI_3 = 4'd5, HASHI_3_WAIT = 4'd6,
          HASHO_1 = 4'd7, HASHO_1_WAIT = 4'd8,
          HASHO_2 = 4'd9, HASHO_2_WAIT = 4'd10,
          LAST = 4'd11;

input [256-1:0] key_i, ikey_hash_i, okey_hash_i;
input [512-1:0] message_i;

input   clk_i;
input   rst_ni;
input   init_i; //starts the hmac
input key_hash_bypass_i; 

output logic [256-1:0]  hash_o;
output logic ready_o, hash_valid_o;  

// Internal registers
logic [512-1:0] ipad;
logic [512-1:0] opad;
logic [3:0] state;

//SHA signals
logic sha_init;
logic sha_ready;
logic sha_new_msg;
logic sha_digest_valid;
logic [512-1:0] sha_msg;
logic [256-1:0] sha_digest;
logic [256-1:0] sha_idigest; 
logic [255 : 0] sha_h_block;
logic           sha_h_block_update;

assign opad = {key_i, 256'h0} ^ {64{8'h5c}};
assign ipad = {key_i, 256'h0} ^ {64{8'h36}};

// Implement SHA256 I/O memory map interface
// Write side
always @(posedge clk_i) begin
    if(~rst_ni) begin
        state = IDLE;
        hash_o = 0;
        ready_o = 0;
        hash_valid_o = 0;
        sha_h_block_update = 0; 
        sha_init = 0;
        sha_new_msg = 0;
    end else begin
        case(state)
            IDLE: begin
                sha_init = 0;
                sha_new_msg = 0;
                sha_msg = 0;
                ready_o = 1;
                if (init_i) begin
                    hash_valid_o = 1'b0;
                    state = HASHI_1;
                end else begin
                    state = IDLE;
                end
            end
            HASHI_1: begin
                if(sha_ready) begin
                    sha_msg = ipad;
                    sha_h_block = ikey_hash_i; 
                    sha_init = ~key_hash_bypass_i;
                    sha_h_block_update = key_hash_bypass_i; 
                    sha_new_msg = 1'b0;
                    state = HASHI_1_WAIT;
                end else begin
                    state = HASHI_1;
                end
            end
            HASHI_1_WAIT: begin
                state = HASHI_2;
                sha_h_block_update = 0; 
                sha_init = 0; 
            end
            HASHI_2: begin
                if(sha_ready) begin
                    //$display("ikey_hash, %x", sha_digest);  // RRR
                    sha_msg = message_i;
                    sha_new_msg = 1'b1; //tell SHA to start
                    state = HASHI_2_WAIT;
                end else begin
                    state = HASHI_2;
                end
            end
            HASHI_2_WAIT: begin
                state = HASHI_3;
                sha_new_msg = 0; 
            end
            HASHI_3: begin
                if(sha_ready) begin
                    sha_msg = {1'h1,447'h0, 64'd1024};
                    sha_new_msg = 1'b1; //tell SHA to start
                    state = HASHI_3_WAIT;
                end else begin
                    state = HASHI_3;
                end
            end
            HASHI_3_WAIT: begin
                state = HASHO_1;
                sha_new_msg = 0; 
            end
            HASHO_1: begin
                if (sha_digest_valid) begin
                    sha_idigest = sha_digest; 
                    sha_msg = opad;
                    sha_h_block = okey_hash_i; 
                    sha_init = ~key_hash_bypass_i;
                    sha_h_block_update = key_hash_bypass_i; 
                    sha_new_msg = 1'b0;
                    state = HASHO_1_WAIT;
                end else begin
                    state = HASHO_1;
                end
            end
            HASHO_1_WAIT: begin
                state = HASHO_2;
                sha_h_block_update = 0; 
                sha_init = 0; 
            end
            HASHO_2: begin
                if(sha_ready) begin
                    //$display("okey_hash, %x", sha_digest);  // RRR
                    sha_msg = {sha_idigest, 1'h1, 191'h0, 64'd768}; 
                    sha_new_msg = 1'b1; //tell SHA to start
                    state = HASHO_2_WAIT;
                end else begin
                    state = HASHO_2;
                end
            end
            HASHO_2_WAIT: begin
                state = LAST;
                sha_new_msg = 0; 
            end
            LAST: begin
                if (sha_digest_valid) begin
                    hash_o = sha_digest;
                    hash_valid_o = 1;  
                    state = IDLE;
                end else begin
                    state = LAST;
                end
            end
            default: state = IDLE;
        endcase
    end
end


sha256 sha256(
           .clk(clk_i),
           .rst(rst_ni),
           .init(sha_init),
           .next(sha_new_msg),
           .block(sha_msg),
           .h_block(sha_h_block),
           .h_block_update(sha_h_block_update),
           .digest(sha_digest),
           .digest_valid(sha_digest_valid),
           .ready(sha_ready)
       );

endmodule

