// Wrapper for sha_256

module hmac_wrapper #(
    parameter int unsigned AXI_ADDR_WIDTH = 64,
    parameter int unsigned AXI_DATA_WIDTH = 64,
    parameter int unsigned AXI_ID_WIDTH   = 10
)(
           clk_i,
           rst_ni,
           reglk_ctrl_i,
           acct_ctrl_i,
           debug_mode_i,
           axi_req_i, 
           axi_resp_o,
           rst_4
       );

    input  logic                   clk_i;
    input  logic                   rst_ni;
    input logic [7 :0]             reglk_ctrl_i; // register lock values
    input logic                    acct_ctrl_i;
    input logic                    debug_mode_i;
    input  ariane_axi::req_t       axi_req_i;
    output ariane_axi::resp_t      axi_resp_o;

    input logic rst_4;

// internal signals


// Internal registers
reg newMessage_r, startHash_r;
logic startHash;
logic newMessage;
logic key_hash_bypass; 
logic [31:0] data [0:15];
logic [31:0] key0 [0:7];
logic [31:0] ikey_hash_bytes [0:7];
logic [31:0] okey_hash_bytes [0:7];

logic [511:0] bigData; 
logic [255:0] hash;
logic ready;
logic hashValid;
logic [256-1:0] key, ikey_hash, okey_hash;

// signals from AXI 4 Lite
logic [AXI_ADDR_WIDTH-1:0] address;
logic                      en, en_acct;
logic                      we;
logic [63:0] wdata;
logic [63:0] rdata;

assign key    = debug_mode_i ? 256'b0 : {key0[0], key0[1], key0[2], key0[3], key0[4], key0[5], key0[6], key0[7]}; 
assign ikey_hash = {ikey_hash_bytes[0], ikey_hash_bytes[1], ikey_hash_bytes[2], ikey_hash_bytes[3], ikey_hash_bytes[4], ikey_hash_bytes[5], ikey_hash_bytes[6], ikey_hash_bytes[7]}; 
assign okey_hash = debug_mode_i ? 256'b0 : {okey_hash_bytes[0], okey_hash_bytes[1], okey_hash_bytes[2], okey_hash_bytes[3], okey_hash_bytes[4], okey_hash_bytes[5], okey_hash_bytes[6], okey_hash_bytes[7]}; 

assign bigData = {data[15], data[14], data[13], data[12], data[11], data[10], data[9], data[8], data[7], data[6], data[5], data[4], data[3], data[2], data[1], data[0]};

///////////////////////////////////////////////////////////////////////////
    // -----------------------------
    // AXI Interface Logic
    // -----------------------------
    axi_lite_interface #(
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
        .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
        .AXI_ID_WIDTH   ( AXI_ID_WIDTH    )
    ) axi_lite_interface_i (
        .clk_i      ( clk_i      ),
        .rst_ni     ( rst_ni     ),
        .axi_req_i  ( axi_req_i  ),
        .axi_resp_o ( axi_resp_o ),
        .address_o  ( address    ),
        .en_o       ( en_acct    ),
        .we_o       ( we         ),
        .data_i     ( rdata      ),
        .data_o     ( wdata      )
    );

    assign en = en_acct && acct_ctrl_i; 

always @(posedge clk_i)
  begin
    if(~(rst_ni && ~rst_4))
      begin
        startHash_r <= 1'b0;
        newMessage_r <= 1'b0;
      end
    else
      begin
        // Generate a registered versions of startHash and newMessage
        startHash_r         <= startHash;
        newMessage_r        <= newMessage;
      end
  end


// Implement SHA256 I/O memory map interface
// Write side
always @(posedge clk_i)
    begin
        if(~(rst_ni && ~rst_4))
            begin
                startHash <= 0;
                newMessage <= 0;
                data[0] <= 0;
                data[1] <= 0;
                data[2] <= 0;
                data[3] <= 0;
                data[4] <= 0;
                data[5] <= 0;
                data[6] <= 0;
                data[7] <= 0;
                data[8] <= 0;
                data[9] <= 0;
                data[10] <= 0;
                data[11] <= 0;
                data[12] <= 0;
                data[13] <= 0;
                data[14] <= 0;
                data[15] <= 0;
            end
        else if(en && we)
            begin
                case(address[9:3])
                    0:
                        begin
                            startHash <= reglk_ctrl_i[1] ? startHash : wdata[0];
                            newMessage <= reglk_ctrl_i[1] ? newMessage : wdata[1];
                            key_hash_bypass <= reglk_ctrl_i[1] ? key_hash_bypass : wdata[2];
                        end
                    1:
                        data[0] <= reglk_ctrl_i[3] ? data[0] : wdata;
                    2:                                        
                        data[1] <= reglk_ctrl_i[3] ? data[1] : wdata;
                    3:                                        
                        data[2] <= reglk_ctrl_i[3] ? data[2] : wdata;
                    4:                                        
                        data[3] <= reglk_ctrl_i[3] ? data[3] : wdata;
                    5:                                        
                        data[4] <= reglk_ctrl_i[3] ? data[4] : wdata;
                    6:                                         
                        data[5] <= reglk_ctrl_i[3] ? data[5] : wdata;
                    7:
                        data[6] <= reglk_ctrl_i[3] ? data[6] : wdata;
                    8:                                        
                        data[7] <= reglk_ctrl_i[3] ? data[7] : wdata;
                    9:                                        
                        data[8] <= reglk_ctrl_i[3] ? data[8] : wdata;
                    10:                                       
                        data[9] <= reglk_ctrl_i[3] ? data[9] : wdata;
                    11:                                       
                        data[10] <= reglk_ctrl_i[3] ? data[10] : wdata;
                    12:                                        
                        data[11] <= reglk_ctrl_i[3] ? data[11] : wdata;
                    13:
                        data[12] <= reglk_ctrl_i[3] ? data[12] : wdata;
                    14:                                        
                        data[13] <= reglk_ctrl_i[3] ? data[13] : wdata;
                    15:                                        
                        data[14] <= reglk_ctrl_i[3] ? data[14] : wdata;
                    16:                                         
                        data[15] <= reglk_ctrl_i[3] ? data[15] : wdata;
                    26:   
                        key0[7] <= reglk_ctrl_i[5] ? key0[7] : wdata;
                    27:                                        
                        key0[6] <= reglk_ctrl_i[5] ? key0[6] : wdata;
                    28:   
                        key0[5] <= reglk_ctrl_i[5] ? key0[5] : wdata;
                    29:                                        
                        key0[4] <= reglk_ctrl_i[5] ? key0[4] : wdata;
                    30:                                        
                        key0[3] <= reglk_ctrl_i[5] ? key0[3] : wdata;
                    31:                                        
                        key0[2] <= reglk_ctrl_i[5] ? key0[2] : wdata;
                    32:                                        
                        key0[1] <= reglk_ctrl_i[5] ? key0[1] : wdata;
                    33:
                        key0[0] <= reglk_ctrl_i[5] ? key0[0] : wdata;
                    34:   
                        ikey_hash_bytes[7] <= reglk_ctrl_i[5] ? ikey_hash_bytes[7] : wdata;
                    35:                                        
                        ikey_hash_bytes[6] <= reglk_ctrl_i[5] ? ikey_hash_bytes[6] : wdata;
                    36:   
                        ikey_hash_bytes[5] <= reglk_ctrl_i[5] ? ikey_hash_bytes[5] : wdata;
                    37:                                        
                        ikey_hash_bytes[4] <= reglk_ctrl_i[5] ? ikey_hash_bytes[4] : wdata;
                    38:                                        
                        ikey_hash_bytes[3] <= reglk_ctrl_i[5] ? ikey_hash_bytes[3] : wdata;
                    39:                                        
                        ikey_hash_bytes[2] <= reglk_ctrl_i[5] ? ikey_hash_bytes[2] : wdata;
                    40:                                        
                        ikey_hash_bytes[1] <= reglk_ctrl_i[5] ? ikey_hash_bytes[1] : wdata;
                    41:
                        ikey_hash_bytes[0] <= reglk_ctrl_i[5] ? ikey_hash_bytes[0] : wdata;
                    42:   
                        okey_hash_bytes[7] <= reglk_ctrl_i[5] ? okey_hash_bytes[7] : wdata;
                    43:                                        
                        okey_hash_bytes[6] <= reglk_ctrl_i[5] ? okey_hash_bytes[6] : wdata;
                    44:   
                        okey_hash_bytes[5] <= reglk_ctrl_i[5] ? okey_hash_bytes[5] : wdata;
                    45:                                        
                        okey_hash_bytes[4] <= reglk_ctrl_i[5] ? okey_hash_bytes[4] : wdata;
                    46:                                        
                        okey_hash_bytes[3] <= reglk_ctrl_i[5] ? okey_hash_bytes[3] : wdata;
                    47:                                        
                        okey_hash_bytes[2] <= reglk_ctrl_i[5] ? okey_hash_bytes[2] : wdata;
                    48:                                        
                        okey_hash_bytes[1] <= reglk_ctrl_i[5] ? okey_hash_bytes[1] : wdata;
                    49:
                        okey_hash_bytes[0] <= reglk_ctrl_i[5] ? okey_hash_bytes[0] : wdata;
                    default:
                        ;
                endcase
            end
    end

// Implement SHA256 I/O memory map interface
// Read side
always @(*)
    begin
      rdata = 64'b0; 
      if (en) begin
        case(address[9:3])
            0:
                rdata = reglk_ctrl_i[0] ? 'b0 : {31'b0, ready};
            1:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[0];
            2:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[1];
            3:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[2];
            4:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[3];
            5:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[4];
            6:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[5];
            7:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[6];
            8:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[7];
            9:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[8];
            10:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[9];
            11:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[10];
            12:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[11];
            13:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[12];
            14:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[13];
            15:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[14];
            16:
                rdata = reglk_ctrl_i[2] ? 'b0 : data[15];
            17:
                rdata = reglk_ctrl_i[0] ? 'b0 : {31'b0, hashValid};
            18:
                rdata = reglk_ctrl_i[6] ? 'b0 : hash[31:0];
            19:                                                 
                rdata = reglk_ctrl_i[6] ? 'b0 : hash[63:32];
            20:                                                 
                rdata = reglk_ctrl_i[6] ? 'b0 : hash[95:64];
            21:                                                 
                rdata = reglk_ctrl_i[6] ? 'b0 : hash[127:96];
            22:                                                 
                rdata = reglk_ctrl_i[6] ? 'b0 : hash[159:128];
            23:                                                 
                rdata = reglk_ctrl_i[6] ? 'b0 : hash[191:160];
            24:                                                 
                rdata = reglk_ctrl_i[6] ? 'b0 : hash[223:192];
            25:                                                 
                rdata = reglk_ctrl_i[6] ? 'b0 : hash[255:224];
            34:
                rdata = reglk_ctrl_i[4] ? 'b0 : ikey_hash_bytes[7];
            35:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : ikey_hash_bytes[6];
            36:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : ikey_hash_bytes[5];
            37:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : ikey_hash_bytes[4];
            38:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : ikey_hash_bytes[3];
            39:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : ikey_hash_bytes[2];
            40:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : ikey_hash_bytes[1];
            41:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : ikey_hash_bytes[0];
            42:
                rdata = reglk_ctrl_i[4] ? 'b0 : okey_hash_bytes[7];
            43:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : okey_hash_bytes[6];
            44:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : okey_hash_bytes[5];
            45:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : okey_hash_bytes[4];
            46:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : okey_hash_bytes[3];
            47:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : okey_hash_bytes[2];
            48:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : okey_hash_bytes[1];
            49:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : okey_hash_bytes[0];
            default:
                rdata = 32'b0;
        endcase
      end // if
    end


hmac hmac(
        .clk_i(clk_i),
        .rst_ni(rst_ni && ~rst_4),
        .init_i(startHash && ~startHash_r),
        .key_i(key),
        .ikey_hash_i(ikey_hash), 
        .okey_hash_i(okey_hash), 
        .key_hash_bypass_i(key_hash_bypass),
        .message_i(bigData),
        .hash_o(hash),
        .ready_o(ready),
        .hash_valid_o(hashValid)   
);

endmodule

