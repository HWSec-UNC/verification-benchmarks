

module aes2_wrapper #(
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
           rst_11
       );

    input  logic                   clk_i;
    input  logic                   rst_ni;
    input logic [7 :0]             reglk_ctrl_i; // register lock values
    input logic                    acct_ctrl_i;
    input logic                    debug_mode_i;
    input  ariane_axi::req_t       axi_req_i;
    output ariane_axi::resp_t      axi_resp_o;
    input logic rst_11;

// internal signals
logic start;
logic ct_valid;

logic [31:0] p_c [0:3];
logic [31:0] state [0:3];
logic [31:0] key0 [0:3]; 
logic [31:0] key1 [0:3]; 
logic [31:0] key2 [0:3]; 

logic [1:0] key_sel; 

logic   [127:0] state_big;
logic   [127:0] dii_data   ;
logic   [127:0] cii_K;
logic   [127:0] cii_K0, cii_K1, cii_K2 ;  
logic   [127:0] ct;


// signals from AXI 4 Lite
logic [AXI_ADDR_WIDTH-1:0] address;
logic                      en, en_acct;
logic                      we;
logic [63:0] wdata;
logic [63:0] rdata;

assign state_big = {state[0], state[1], state[2], state[3]};
assign dii_data = {p_c[0], p_c[1], p_c[2], p_c[3]};
assign cii_K0    = debug_mode_i ? 128'b0 : {key0[0], key0[1], key0[2], key0[3]}; 
assign cii_K1    = debug_mode_i ? 128'b0 : {key1[0], key1[1], key1[2], key1[3]}; 
assign cii_K2    = debug_mode_i ? 128'b0 : {key2[0], key2[1], key2[2], key2[3]};

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


// Implement APB I/O map to AES interface
// Write side
always @(posedge clk_i)
    begin
        if (~(rst_ni && ~rst_11))
            begin
                start <= 0;
                p_c[0] <= 0;
                p_c[1] <= 0;
                p_c[2] <= 0;
                p_c[3] <= 0;
                state[0] <= 0;
                state[1] <= 0;
                state[2] <= 0;
                state[3] <= 0;
                
            end
        else if(en && we)
            case(address[8:3]) // different signals will have a different address base.
                0:
                    start  <= reglk_ctrl_i[1] ? start  : wdata[0];
                1:
                    p_c[3] <= reglk_ctrl_i[3] ? p_c[3] : wdata[31:0];
                2:
                    p_c[2] <= reglk_ctrl_i[3] ? p_c[2] : wdata[31:0];
                3:
                    p_c[1] <= reglk_ctrl_i[3] ? p_c[1] : wdata[31:0];
                4:
                    p_c[0] <= reglk_ctrl_i[3] ? p_c[0] : wdata[31:0];
                5:
                    key0[3] <= reglk_ctrl_i[5] ? key0[3] : wdata[31:0];
                6:                                        
                    key0[2] <= reglk_ctrl_i[5] ? key0[2] : wdata[31:0];
                7:                                        
                    key0[1] <= reglk_ctrl_i[5] ? key0[1] : wdata[31:0];
                8:
                    key0[0] <= reglk_ctrl_i[5] ? key0[0] : wdata[31:0];
                14:
                    state[3] <= reglk_ctrl_i[3] ? state[3] : wdata[31:0];
                15:                                        
                    state[2] <= reglk_ctrl_i[3] ? state[2] : wdata[31:0];
                16:                                        
                    state[1] <= reglk_ctrl_i[3] ? state[1] : wdata[31:0];
                17:
                    state[0] <= reglk_ctrl_i[3] ? state[0] : wdata[31:0];                   
                18:                                       
                    key1[3] <= reglk_ctrl_i[5] ? key1[3] : wdata[31:0];
                19:                                       
                    key1[2] <= reglk_ctrl_i[5] ? key1[2] : wdata[31:0];
                20:                                       
                    key1[1] <= reglk_ctrl_i[5] ? key1[1] : wdata[31:0];
                21:                                        
                    key1[0] <= reglk_ctrl_i[5] ? key1[0] : wdata[31:0];
                22:                                       
                    key2[3] <= reglk_ctrl_i[5] ? key2[3] : wdata[31:0];
                23:                                       
                    key2[2] <= reglk_ctrl_i[5] ? key2[2] : wdata[31:0];
                24:                                       
                    key2[1] <= reglk_ctrl_i[5] ? key2[1] : wdata[31:0];
                25:                            
                    key2[0] <= reglk_ctrl_i[5] ? key2[0] : wdata[31:0];
                26: 
                    key_sel <= reglk_ctrl_i[1] ? key_sel : wdata[31:0];
                default:
                    ;
            endcase
    end // always @ (posedge wb_clk)

// Implement MD5 I/O memory map interface
// Read side
//always @(~write)
always @(*)
    begin
      rdata = 64'b0; 
      if (en) begin
        rdata = key0[address[8:3]]; 
        case(address[8:3])
            0:
                rdata = reglk_ctrl_i[0] ? 'b0 : {31'b0, start};
            1:
                rdata = reglk_ctrl_i[2] ? 'b0 : p_c[3];
            2:
                rdata = reglk_ctrl_i[2] ? 'b0 : p_c[2];
            3:
                rdata = reglk_ctrl_i[2] ? 'b0 : p_c[1];
            4:
                rdata = reglk_ctrl_i[2] ? 'b0 : p_c[0];
            9:
                rdata = reglk_ctrl_i[6] ? 'b0 : {31'b0, ct_valid};
            10:
                rdata = reglk_ctrl_i[4] ? 'b0 : ct[31:0];
            11:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : ct[63:32];
            12:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : ct[95:64];
            13:                                                 
                rdata = reglk_ctrl_i[4] ? 'b0 : ct[127:96];
            default:
                if (ct_valid)
                    rdata = 32'b0;
        endcase
      end // if
    end // always @ (*)


// select the proper key

assign cii_K = key_sel[1] ? cii_K2 : ( key_sel[0] ? cii_K1 : cii_K0 );

aes2_interface aes2_interface(
    .clk(clk_i),
    .iv(state_big),
    .rst(rst_ni && ~rst_11),
    .start(start),
    .cii_K(cii_K),
    .input_pc(dii_data),
    
    .Out_data_final(ct),
    .ct_valid_out(ct_valid)
    );

endmodule
